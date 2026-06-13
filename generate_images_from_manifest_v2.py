import argparse
import json
import os
import time
from pathlib import Path

from google import genai
from google.genai import types

ROOT = Path("Flame_Fleur/Flame_Fleur")
MANIFEST_PATH = ROOT / "Resources/GeneratedAssets/Gemini/image_generation_manifest_v2.json"
RAW_ROOT = ROOT / "Resources/GeneratedAssets/Gemini/raw/v2"

MODEL = "imagen-4.0-generate-001"

def get_client() -> genai.Client:
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        raise RuntimeError("Missing GEMINI_API_KEY. Run: export GEMINI_API_KEY='YOUR_KEY'")
    return genai.Client(api_key=api_key)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--limit", type=int, default=None, help="Generate only N images.")
    parser.add_argument("--type", choices=["recipe", "subcategory", "all"], default="all")
    parser.add_argument("--overwrite", action="store_true")
    parser.add_argument("--sleep", type=float, default=2.0)
    args = parser.parse_args()

    items = json.loads(MANIFEST_PATH.read_text())

    if args.type != "all":
        items = [item for item in items if item.get("type") == args.type]

    if args.limit is not None:
        items = items[:args.limit]

    client = get_client()

    generated = 0
    skipped = 0
    failed = 0

    for index, item in enumerate(items, start=1):
        asset_name = item["asset_name"]
        output_folder = item["output_folder"]
        prompt = item["prompt"]

        out_dir = RAW_ROOT / output_folder
        out_dir.mkdir(parents=True, exist_ok=True)
        out_path = out_dir / f"{asset_name}.png"

        if out_path.exists() and not args.overwrite:
            print(f"[{index}/{len(items)}] Skip existing: {out_path}")
            skipped += 1
            continue

        print(f"[{index}/{len(items)}] Generating {item['type']}: {asset_name}")

        try:
            response = client.models.generate_images(
                model=MODEL,
                prompt=prompt,
                config=types.GenerateImagesConfig(
                    number_of_images=1,
                    aspect_ratio="1:1",
                ),
            )

            if not response.generated_images:
                print(f"  WARNING: No image returned for {asset_name}")
                failed += 1
                continue

            image = response.generated_images[0].image
            image.save(out_path)
            print(f"  Saved: {out_path}")
            generated += 1

        except Exception as error:
            print(f"  ERROR: {asset_name}: {error}")
            failed += 1

        time.sleep(args.sleep)

    print()
    print("Done.")
    print("Generated:", generated)
    print("Skipped:", skipped)
    print("Failed:", failed)

if __name__ == "__main__":
    main()
