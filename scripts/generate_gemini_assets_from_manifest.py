import json
import os
import time
from pathlib import Path

from dotenv import load_dotenv
from google import genai
from google.genai import types

# ---------------- CONFIG ----------------

PROJECT_ROOT = Path(__file__).resolve().parents[1]

MANIFEST_PATH = PROJECT_ROOT / "Flame_Fleur/Flame_Fleur/Resources/ImagePrompts/gemini_asset_manifest_home_planner_subcategory_v2.json"

OUTPUT_ROOT = PROJECT_ROOT / "Flame_Fleur/Flame_Fleur/Resources/GeneratedAssets/Gemini/raw"

REPORT_PATH = PROJECT_ROOT / "Flame_Fleur/Flame_Fleur/Resources/GeneratedAssets/Gemini/generation_report.json"

# Use fast first for testing. You can change to imagen-4.0-generate-001 later.
MODEL_NAME = "imagen-4.0-fast-generate-001"

# Start small first. Change to None when ready to generate all.
MAX_IMAGES = None

SLEEP_SECONDS = 2.0

# ---------------- SETUP ----------------

load_dotenv(dotenv_path=PROJECT_ROOT / ".env")

api_key = os.environ.get("GEMINI_API_KEY")
if not api_key:
    raise RuntimeError("GEMINI_API_KEY is not set. Add it to .env in the project root.")

client = genai.Client(api_key=api_key)

if not MANIFEST_PATH.exists():
    raise FileNotFoundError(f"Manifest not found: {MANIFEST_PATH}")

OUTPUT_ROOT.mkdir(parents=True, exist_ok=True)
REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)


def load_manifest():
    with open(MANIFEST_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    if not isinstance(data, list):
        raise ValueError("Manifest must be a JSON list.")

    return data


def generate_image(prompt: str):
    response = client.models.generate_images(
        model=MODEL_NAME,
        prompt=prompt,
        config=types.GenerateImagesConfig(
            number_of_images=1,
            aspect_ratio="1:1"
        )
    )

    if not response.generated_images:
        raise RuntimeError("Gemini/Imagen returned no images.")

    return response.generated_images[0].image


def main():
    manifest = load_manifest()

    if MAX_IMAGES is not None:
        manifest = manifest[:MAX_IMAGES]

    report = []

    print(f"Manifest: {MANIFEST_PATH}")
    print(f"Output root: {OUTPUT_ROOT}")
    print(f"Model: {MODEL_NAME}")
    print(f"Items to process: {len(manifest)}")
    print()

    for index, item in enumerate(manifest, start=1):
        asset_name = item["asset_name"]
        filename = item.get("filename", f"{asset_name}.png")
        output_folder = item.get("output_folder", "misc")
        prompt = item["prompt"]

        output_dir = OUTPUT_ROOT / output_folder
        output_dir.mkdir(parents=True, exist_ok=True)

        output_path = output_dir / filename

        if output_path.exists():
            print(f"[{index}] Skipping existing: {output_path}")
            report.append({
                "asset_name": asset_name,
                "status": "skipped_existing",
                "path": str(output_path)
            })
            continue

        print(f"[{index}] Generating {asset_name}")
        print(f"    -> {output_path}")

        try:
            image = generate_image(prompt)
            image.save(output_path)

            report.append({
                "asset_name": asset_name,
                "asset_type": item.get("asset_type"),
                "filename": filename,
                "output_folder": output_folder,
                "status": "generated",
                "path": str(output_path)
            })

            print("    Saved")

        except Exception as e:
            report.append({
                "asset_name": asset_name,
                "asset_type": item.get("asset_type"),
                "filename": filename,
                "output_folder": output_folder,
                "status": "error",
                "error": str(e)
            })

            print(f"    ERROR: {e}")

        time.sleep(SLEEP_SECONDS)

    with open(REPORT_PATH, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2, ensure_ascii=False)

    print()
    print(f"Done. Report saved to: {REPORT_PATH}")


if __name__ == "__main__":
    main()
