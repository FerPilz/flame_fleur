import json
import shutil
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]

APPROVED_ROOT = PROJECT_ROOT / "Flame_Fleur/Flame_Fleur/Resources/GeneratedAssets/Gemini/approved"

ASSETS_DIR = PROJECT_ROOT / "Flame_Fleur/Flame_Fleur/Assets.xcassets"

def write_contents_json(imageset_dir: Path, filename: str):
    contents = {
        "images": [
            {
                "filename": filename,
                "idiom": "universal",
                "scale": "1x"
            },
            {
                "idiom": "universal",
                "scale": "2x"
            },
            {
                "idiom": "universal",
                "scale": "3x"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }

    with open(imageset_dir / "Contents.json", "w", encoding="utf-8") as f:
        json.dump(contents, f, indent=2)

def main():
    if not APPROVED_ROOT.exists():
        raise FileNotFoundError(f"Approved folder not found: {APPROVED_ROOT}")

    if not ASSETS_DIR.exists():
        raise FileNotFoundError(f"Assets.xcassets not found: {ASSETS_DIR}")

    image_files = sorted(APPROVED_ROOT.rglob("*.png"))

    if not image_files:
        print(f"No approved PNG files found in {APPROVED_ROOT}")
        return

    for image_path in image_files:
        asset_name = image_path.stem
        imageset_dir = ASSETS_DIR / f"{asset_name}.imageset"
        imageset_dir.mkdir(parents=True, exist_ok=True)

        destination = imageset_dir / f"{asset_name}.png"
        shutil.copy2(image_path, destination)

        write_contents_json(imageset_dir, f"{asset_name}.png")

        print(f"Imported {asset_name}")

    print()
    print(f"Imported {len(image_files)} images into Assets.xcassets")

if __name__ == "__main__":
    main()
