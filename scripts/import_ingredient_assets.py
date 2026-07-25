#!/usr/bin/env python3
import argparse
import json
import shutil
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
MANIFEST_PATH = PROJECT_ROOT / "Flame_Fleur/Flame_Fleur/Resources/ImagePrompts/ingredient_image_manifest.json"
APPROVED_DIR = PROJECT_ROOT / "Flame_Fleur/Flame_Fleur/Resources/GeneratedAssets/Gemini/ingredient_catalog_approved"
ASSETS_DIR = PROJECT_ROOT / "Flame_Fleur/Flame_Fleur/Assets.xcassets"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Import approved ingredient PNGs into Assets.xcassets.")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Preview asset import work without writing imagesets.",
    )
    return parser.parse_args()


def load_manifest() -> list[dict]:
    with MANIFEST_PATH.open("r", encoding="utf-8") as handle:
        data = json.load(handle)

    if not isinstance(data, list):
        raise ValueError("Ingredient manifest must be a JSON array.")

    return data


def write_contents_json(imageset_dir: Path, filename: str) -> None:
    payload = {
        "images": [
            {
                "idiom": "universal",
                "filename": filename,
                "scale": "1x",
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1,
        },
    }

    with (imageset_dir / "Contents.json").open("w", encoding="utf-8") as handle:
        json.dump(payload, handle, indent=2)
        handle.write("\n")


def main() -> int:
    args = parse_args()
    manifest = load_manifest()
    approved_entries = [entry for entry in manifest if entry.get("status") == "approved"]

    print(f"Manifest: {MANIFEST_PATH}")
    print(f"Approved folder: {APPROVED_DIR}")
    print(f"Assets catalog: {ASSETS_DIR}")
    print(f"Dry run: {args.dry_run}")
    print(f"Approved entries: {len(approved_entries)}")

    if not approved_entries:
        print("No approved ingredient entries found.")
        return 0

    missing_files: list[str] = []

    for entry in approved_entries:
        source_path = APPROVED_DIR / entry["outputFilename"]
        imageset_dir = ASSETS_DIR / f"{entry['imageName']}.imageset"
        destination_path = imageset_dir / entry["outputFilename"]

        if not source_path.exists():
            missing_files.append(entry["outputFilename"])
            print(f"Missing approved file: {source_path}")
            continue

        if args.dry_run:
            print(f"DRY RUN: would import {source_path.name} -> {imageset_dir.name}")
            continue

        imageset_dir.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source_path, destination_path)
        write_contents_json(imageset_dir, entry["outputFilename"])
        print(f"Imported {entry['imageName']}")

    if missing_files:
        print(f"Missing approved PNGs: {len(missing_files)}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise
