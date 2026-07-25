#!/usr/bin/env python3
import json
import shutil
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
MANIFEST_PATH = PROJECT_ROOT / "Flame_Fleur/Flame_Fleur/Resources/ImagePrompts/ingredient_image_manifest.json"
STAGING_DIR = PROJECT_ROOT / "Flame_Fleur/Flame_Fleur/Resources/GeneratedAssets/Gemini/ingredient_catalog_staging"
APPROVED_DIR = PROJECT_ROOT / "Flame_Fleur/Flame_Fleur/Resources/GeneratedAssets/Gemini/ingredient_catalog_approved"


def load_manifest() -> list[dict]:
    with MANIFEST_PATH.open("r", encoding="utf-8") as handle:
        data = json.load(handle)

    if not isinstance(data, list):
        raise ValueError("Ingredient manifest must be a JSON array.")

    return data


def save_manifest(entries: list[dict]) -> None:
    with MANIFEST_PATH.open("w", encoding="utf-8") as handle:
        json.dump(entries, handle, indent=2, ensure_ascii=False)
        handle.write("\n")


def main() -> int:
    manifest = load_manifest()
    APPROVED_DIR.mkdir(parents=True, exist_ok=True)

    approved_count = 0
    skipped_count = 0
    pruned_count = 0
    missing_files: list[str] = []

    for entry in manifest:
        source_path = STAGING_DIR / entry["outputFilename"]
        destination_path = APPROVED_DIR / entry["outputFilename"]

        if entry.get("status") == "approved":
            if source_path.exists() and destination_path.exists():
                source_path.unlink()
                pruned_count += 1
            skipped_count += 1
            continue

        if entry.get("status") != "generated":
            skipped_count += 1
            continue

        if not source_path.exists():
            missing_files.append(entry["outputFilename"])
            continue

        shutil.move(str(source_path), str(destination_path))
        entry["status"] = "approved"
        entry["notes"] = ""
        approved_count += 1

    save_manifest(manifest)

    print(f"Manifest: {MANIFEST_PATH}")
    print(f"Staging folder: {STAGING_DIR}")
    print(f"Approved folder: {APPROVED_DIR}")
    print(f"Approved count: {approved_count}")
    print(f"Skipped count: {skipped_count}")
    print(f"Pruned staging duplicates: {pruned_count}")
    print(f"Missing files: {len(missing_files)}")

    if missing_files:
        print("Missing generated PNGs:", file=sys.stderr)
        for name in missing_files:
            print(f"  {name}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise
