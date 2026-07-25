#!/usr/bin/env python3
import json
import sys
from collections import Counter
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
MANIFEST_PATH = PROJECT_ROOT / "Flame_Fleur/Flame_Fleur/Resources/ImagePrompts/ingredient_image_manifest.json"
APPROVED_DIR = PROJECT_ROOT / "Flame_Fleur/Flame_Fleur/Resources/GeneratedAssets/Gemini/ingredient_catalog_approved"
ASSETS_DIR = PROJECT_ROOT / "Flame_Fleur/Flame_Fleur/Assets.xcassets"

REQUIRED_FIELDS = {
    "id",
    "name",
    "category",
    "cartCategory",
    "imageName",
    "outputFilename",
    "promptSubject",
    "fallbackCategoryImageName",
    "status",
}

EXPECTED_ENTRY_COUNT = 168
ALLOWED_STATUSES = {"pending", "generated", "approved", "rejected"}
ALLOWED_FALLBACKS = {
    "cart_category_produce",
    "cart_category_dairy_eggs",
    "cart_category_meat_seafood",
    "cart_category_pantry",
    "cart_category_bakery",
    "cart_category_frozen",
    "cart_category_beverages",
    "cart_category_household",
    "cart_category_other",
}


def load_manifest() -> list[dict]:
    if not MANIFEST_PATH.exists():
        raise FileNotFoundError(f"Manifest not found: {MANIFEST_PATH}")

    with MANIFEST_PATH.open("r", encoding="utf-8") as handle:
        data = json.load(handle)

    if not isinstance(data, list):
        raise ValueError("Ingredient manifest must be a JSON array.")

    return data


def duplicate_values(values: list[str]) -> list[str]:
    counts = Counter(values)
    return sorted(value for value, count in counts.items() if count > 1)


def main() -> int:
    manifest = load_manifest()
    errors: list[str] = []
    missing_approved_files: list[str] = []
    missing_imagesets: list[str] = []

    if len(manifest) != EXPECTED_ENTRY_COUNT:
        errors.append(f"Expected {EXPECTED_ENTRY_COUNT} manifest entries, found {len(manifest)}")

    duplicate_ids = duplicate_values([str(entry.get("id", "")) for entry in manifest])
    duplicate_image_names = duplicate_values([str(entry.get("imageName", "")) for entry in manifest])

    if duplicate_ids:
        errors.append(f"Duplicate ids: {', '.join(duplicate_ids)}")

    if duplicate_image_names:
        errors.append(f"Duplicate imageNames: {', '.join(duplicate_image_names)}")

    for entry in manifest:
        missing_fields = sorted(field for field in REQUIRED_FIELDS if not entry.get(field))
        if missing_fields:
            errors.append(f"{entry.get('name', '<unknown>')} is missing fields: {', '.join(missing_fields)}")

        if entry.get("status") not in ALLOWED_STATUSES:
            errors.append(f"{entry.get('name', '<unknown>')} has invalid status: {entry.get('status')}")

        fallback_name = entry.get("fallbackCategoryImageName")
        if fallback_name not in ALLOWED_FALLBACKS:
            errors.append(f"{entry.get('name', '<unknown>')} has invalid fallback asset: {fallback_name}")

        if entry.get("outputFilename") != f"{entry.get('imageName')}.png":
            errors.append(f"{entry.get('name', '<unknown>')} outputFilename does not match imageName")

        if entry.get("status") == "approved":
            approved_png = APPROVED_DIR / entry["outputFilename"]
            imageset_dir = ASSETS_DIR / f"{entry['imageName']}.imageset"
            contents_json = imageset_dir / "Contents.json"
            imported_png = imageset_dir / entry["outputFilename"]

            if not approved_png.exists():
                missing_approved_files.append(entry["outputFilename"])

            if not imageset_dir.exists() or not contents_json.exists() or not imported_png.exists():
                missing_imagesets.append(entry["imageName"])

    status_counts = Counter(entry["status"] for entry in manifest)

    print(f"Manifest: {MANIFEST_PATH}")
    print(f"Total entries: {len(manifest)}")
    print(f"Pending: {status_counts.get('pending', 0)}")
    print(f"Generated: {status_counts.get('generated', 0)}")
    print(f"Approved: {status_counts.get('approved', 0)}")
    print(f"Rejected: {status_counts.get('rejected', 0)}")
    print(f"Missing approved files: {len(missing_approved_files)}")
    print(f"Missing imagesets: {len(missing_imagesets)}")

    if missing_approved_files:
        print("Approved PNGs missing:")
        for name in missing_approved_files:
            print(f"  {name}")

    if missing_imagesets:
        print("Imagesets missing:")
        for name in missing_imagesets:
            print(f"  {name}")

    if errors:
        print("Validation errors:", file=sys.stderr)
        for error in errors:
            print(f"  {error}", file=sys.stderr)
        return 1

    print("Validation passed.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise
