#!/usr/bin/env python3
import argparse
import base64
import io
import json
import os
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MANIFEST_PATH = PROJECT_ROOT / "Flame_Fleur/Flame_Fleur/Resources/ImagePrompts/ingredient_image_manifest.json"
DEFAULT_PROMPT_TEMPLATE_PATH = PROJECT_ROOT / "Flame_Fleur/Flame_Fleur/Resources/ImagePrompts/ingredient_gemini_prompt_template.txt"
DEFAULT_OUTPUT_DIR = PROJECT_ROOT / "Flame_Fleur/Flame_Fleur/Resources/GeneratedAssets/Gemini/ingredient_catalog_staging"
ALLOWED_STATUSES = {"pending", "generated", "approved", "rejected"}
DEFAULT_MODEL = "gemini-2.5-flash-image"
DEFAULT_FIRST_BATCH = [
    "Greek Yogurt",
    "Quinoa",
    "Smoked Paprika",
    "Shallot",
    "Tomatoes",
    "Brown Rice",
    "Cucumber",
    "Lemon",
    "Honey",
    "Soy Sauce",
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate ingredient images from the ingredient manifest using Gemini.")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Preview generation work without calling Gemini or mutating the manifest.",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=None,
        help="Optional maximum number of entries to process after filtering.",
    )
    parser.add_argument(
        "--status",
        choices=sorted(ALLOWED_STATUSES),
        default="pending",
        help="Manifest status to process. Default: pending",
    )
    parser.add_argument(
        "--overwrite",
        nargs="?",
        const="true",
        default="false",
        choices=("true", "false"),
        help="Overwrite existing files and allow regeneration when explicitly set to true.",
    )
    parser.add_argument(
        "--manifest",
        type=Path,
        default=DEFAULT_MANIFEST_PATH,
        help="Optional manifest path override.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=DEFAULT_OUTPUT_DIR,
        help="Optional staging output directory override.",
    )
    parser.add_argument(
        "--prompt-template",
        type=Path,
        default=DEFAULT_PROMPT_TEMPLATE_PATH,
        help="Optional prompt template path override.",
    )
    parser.add_argument(
        "--model",
        default=DEFAULT_MODEL,
        help=f"Gemini image model name. Default: {DEFAULT_MODEL}",
    )
    parser.add_argument(
        "--names",
        nargs="+",
        default=None,
        help="Optional exact ingredient display names to process.",
    )
    parser.add_argument(
        "--first-batch",
        action="store_true",
        help="Process the recommended first batch of 10 high-frequency ingredients.",
    )
    return parser.parse_args()


def normalize_flag(value: str) -> bool:
    return str(value).strip().lower() == "true"


def load_manifest(path: Path) -> list[dict]:
    with path.open("r", encoding="utf-8") as handle:
        data = json.load(handle)

    if not isinstance(data, list):
        raise ValueError("Ingredient manifest must be a JSON array.")

    return data


def save_manifest(path: Path, entries: list[dict]) -> None:
    with path.open("w", encoding="utf-8") as handle:
        json.dump(entries, handle, indent=2, ensure_ascii=False)
        handle.write("\n")


def load_prompt_template(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def render_prompt(template: str, entry: dict) -> str:
    return (
        template.replace("{promptSubject}", entry["promptSubject"].strip())
        + "\n\nIngredient name:\n"
        + entry["name"].strip()
        + "\n\nStrict output requirements:\nPNG, 1:1 square, no text, no labels, no brand packaging, no watermark, no hands, no people, ingredient should be recognizable at small cart thumbnail size."
    )


def resolve_api_key() -> str:
    key = os.environ.get("GEMINI_API_KEY")
    if not key or key.strip() in {"", "YOUR_KEY_HERE"}:
        raise RuntimeError("GEMINI_API_KEY is not set.")
    return key.strip().strip('"').strip("'")


def load_sdk():
    try:
        from google import genai
        from google.genai import types
        from PIL import Image

        return genai, types, Image
    except Exception as exc:
        raise RuntimeError(
            "google-genai is required. Install it with: python3 -m pip install google-genai pillow"
        ) from exc


_gemini_client = None


def get_gemini_client():
    global _gemini_client
    if _gemini_client is None:
        genai, _, _ = load_sdk()
        _gemini_client = genai.Client(api_key=resolve_api_key())
    return _gemini_client


def decode_image_data(data: object) -> bytes | None:
    if isinstance(data, bytes):
        return data or None

    if isinstance(data, str):
        stripped = data.strip()
        if not stripped:
            return None

        try:
            return base64.b64decode(stripped)
        except Exception:
            return None

    return None


def iter_response_parts(response: object):
    response_parts = getattr(response, "parts", None) or []
    for part in response_parts:
        yield part

    candidates = getattr(response, "candidates", None) or []
    for candidate in candidates:
        content = getattr(candidate, "content", None)
        parts = getattr(content, "parts", None) or []
        for part in parts:
            yield part


def extract_image_bytes(response: object) -> bytes:
    for part in iter_response_parts(response):
        inline_data = getattr(part, "inline_data", None)
        mime_type = str(getattr(inline_data, "mime_type", "") or "").lower()
        data = decode_image_data(getattr(inline_data, "data", None))

        if data and (not mime_type or mime_type.startswith("image/")):
            return data

    generated_images = getattr(response, "generated_images", None) or []
    for generated_image in generated_images:
        image = getattr(generated_image, "image", None)
        image_bytes = decode_image_data(getattr(image, "image_bytes", None))
        if image_bytes:
            return image_bytes

    raise RuntimeError("No image data returned by Gemini.")


def write_png(image_bytes: bytes, output_path: Path) -> None:
    _, _, image_module = load_sdk()

    output_path.parent.mkdir(parents=True, exist_ok=True)
    temp_path = output_path.with_suffix(f"{output_path.suffix}.tmp")

    with image_module.open(io.BytesIO(image_bytes)) as image:
        image.save(temp_path, format="PNG")

    if temp_path.stat().st_size == 0:
        temp_path.unlink(missing_ok=True)
        raise RuntimeError("Gemini returned empty image data.")

    temp_path.replace(output_path)


def generate_with_gemini(prompt: str, output_path: Path, model_name: str) -> None:
    _, types, _ = load_sdk()

    response = get_gemini_client().models.generate_content(
        model=model_name,
        contents=[prompt],
        config=types.GenerateContentConfig(
            response_modalities=["IMAGE"],
            image_config=types.ImageConfig(aspect_ratio="1:1"),
        ),
    )
    write_png(extract_image_bytes(response), output_path)


def matches_name_filter(entry: dict, requested_names: set[str] | None) -> bool:
    if not requested_names:
        return True
    return entry.get("name", "") in requested_names


def build_selected_entries(
    entries: list[dict],
    status: str,
    requested_names: list[str] | None,
) -> list[dict]:
    requested_name_set = set(requested_names) if requested_names else None
    filtered = [entry for entry in entries if entry.get("status") == status and matches_name_filter(entry, requested_name_set)]

    if not requested_names:
        return filtered

    order = {name: index for index, name in enumerate(requested_names)}
    return sorted(filtered, key=lambda entry: order.get(entry.get("name", ""), len(order)))


def main() -> int:
    args = parse_args()
    overwrite = normalize_flag(args.overwrite)
    manifest_path = args.manifest.resolve()
    output_dir = args.output_dir.resolve()
    prompt_template_path = args.prompt_template.resolve()

    manifest = load_manifest(manifest_path)
    prompt_template = load_prompt_template(prompt_template_path)
    if not args.dry_run:
        output_dir.mkdir(parents=True, exist_ok=True)

    requested_names: list[str] | None = None
    if args.first_batch:
        requested_names = DEFAULT_FIRST_BATCH
    elif args.names:
        requested_names = args.names

    selected_entries = build_selected_entries(manifest, args.status, requested_names)

    if requested_names:
        missing_names = [name for name in requested_names if name not in {entry.get("name", "") for entry in selected_entries}]
        if missing_names:
            raise RuntimeError(f"Requested ingredient names not available for status '{args.status}': {missing_names}")

    if args.limit is not None:
        selected_entries = selected_entries[: args.limit]

    print(f"Manifest: {manifest_path}")
    print(f"Prompt template: {prompt_template_path}")
    print(f"Output dir: {output_dir}")
    print(f"Status filter: {args.status}")
    print(f"Dry run: {args.dry_run}")
    print(f"Overwrite: {overwrite}")
    print(f"Model: {args.model}")
    print(f"Selected entries: {len(selected_entries)}")

    changed = False

    for index, entry in enumerate(selected_entries, start=1):
        output_path = output_dir / entry["outputFilename"]
        prompt = render_prompt(prompt_template, entry)

        print(f"[{index}/{len(selected_entries)}] {entry['name']} -> {output_path.name}")

        if entry.get("status") == "approved" and not overwrite:
            print("    Skipping approved entry because overwrite is false")
            continue

        if output_path.exists() and not overwrite:
            print("    Skipping existing output because overwrite is false")
            continue

        if args.dry_run:
            print(f"    DRY RUN: would call Gemini and write {output_path}")
            continue

        try:
            generate_with_gemini(prompt, output_path, args.model)
            entry["status"] = "generated"
            entry["notes"] = ""
            changed = True
            print("    Generated")
        except Exception as exc:
            entry["status"] = "approved" if entry.get("status") == "approved" else "pending"
            entry["notes"] = f"Generation error: {exc}"
            changed = True
            print(f"    ERROR: {exc}")

    if changed:
        save_manifest(manifest_path, manifest)
        print("Manifest updated")

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise
