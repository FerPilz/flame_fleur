import os
import json
import base64
import time
from pathlib import Path
from openai import OpenAI

# -------- CONFIG --------
BASE_DIR = Path.home() / "Desktop/Projects/flame_fleur"
MANIFEST_PATH = BASE_DIR / "Flame_Fleur/Flame_Fleur/Resources/ImagePrompts/category_image_manifest.json"
OUTPUT_DIR = BASE_DIR / "Flame_Fleur/Flame_Fleur/Resources/GeneratedAssets/Categories/raw"
REPORT_PATH = BASE_DIR / "Flame_Fleur/Flame_Fleur/Resources/GeneratedAssets/Categories/category_generation_report.json"

MODEL_NAME = "gpt-image-1"
IMAGE_SIZE = "1024x1024"
SLEEP_BETWEEN_REQUESTS = 1.0

# -------- CLIENT --------
api_key = os.environ.get("OPENAI_API_KEY")
if not api_key:
    raise RuntimeError(
        "OPENAI_API_KEY is not set.\n"
        "Run in Terminal:\n"
        'export OPENAI_API_KEY="your_api_key_here"'
    )

client = OpenAI(api_key=api_key)

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)


def build_prompt(entry: dict) -> str:
    return f"""
Create a hyperrealistic premium food photograph for a cooking app category image.

Category: {entry['title']}
Group: {entry['group']}
Subject: {entry['prompt_hint']}

Visual style:
hyperrealistic food photography, premium editorial cookbook style, warm natural daylight, soft shadows, elegant plating, realistic textures, artistic composition, clean bright neutral background, appetizing, refined, luxurious, high-end culinary photography.

Composition:
square image, centered subject, clear focal point, enough breathing room for circular crop, shallow depth of field, crisp food detail, balanced composition.

Important constraints:
no illustration, no cartoon style, no digital painting, no icon style, no collage, no text, no labels, no logos, no watermark, no border.
""".strip()

def load_manifest():
    if not MANIFEST_PATH.exists():
        raise FileNotFoundError(f"Manifest not found: {MANIFEST_PATH}")

    with open(MANIFEST_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    if not isinstance(data, list):
        raise ValueError("Manifest must be a JSON array/list.")

    return data


def generate_image(prompt: str) -> bytes:
    result = client.images.generate(
        model=MODEL_NAME,
        prompt=prompt,
        size=IMAGE_SIZE
    )

    image_base64 = result.data[0].b64_json
    return base64.b64decode(image_base64)


def main():
    manifest = load_manifest()
    report = []

    print(f"Loaded {len(manifest)} manifest entries.")
    print(f"Output directory: {OUTPUT_DIR}")
    print("Starting generation...\n")

    for i, entry in enumerate(manifest, start=1):
        title = entry.get("title", "Untitled")
        filename = entry.get("filename")
        image_id = entry.get("id", title.lower().replace(" ", "_"))

        if not filename:
            print(f"[{i}] Skipping '{title}' - missing filename")
            report.append({
                "id": image_id,
                "title": title,
                "status": "skipped",
                "reason": "missing filename"
            })
            continue

        output_path = OUTPUT_DIR / filename

        if output_path.exists():
            print(f"[{i}] Skipping existing file: {filename}")
            report.append({
                "id": image_id,
                "title": title,
                "filename": filename,
                "status": "skipped",
                "reason": "already exists",
                "path": str(output_path)
            })
            continue

        prompt = build_prompt(entry)

        print(f"[{i}] Generating '{title}' -> {filename}")
        try:
            image_bytes = generate_image(prompt)
            output_path.write_bytes(image_bytes)

            print(f"    Saved: {output_path}")
            report.append({
                "id": image_id,
                "title": title,
                "filename": filename,
                "status": "generated",
                "path": str(output_path)
            })

        except Exception as e:
            print(f"    ERROR generating '{title}': {e}")
            report.append({
                "id": image_id,
                "title": title,
                "filename": filename,
                "status": "error",
                "error": str(e)
            })

        time.sleep(SLEEP_BETWEEN_REQUESTS)

    with open(REPORT_PATH, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2, ensure_ascii=False)

    print("\nDone.")
    print(f"Report saved to: {REPORT_PATH}")


if __name__ == "__main__":
    main()