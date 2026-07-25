#!/usr/bin/env python3
import argparse
import json
import re
import shutil
from pathlib import Path

TITLE_KEYS = ["title", "name", "recipeName"]

IMAGE_KEYS = [
    "imageName",
    "imageAssetName",
    "assetName",
    "asset_name",
    "image",
    "image_code",
    "imageCode",
]


def slugify(value):
    value = str(value or "").lower().strip()
    value = value.split("/")[-1]
    value = re.sub(r"\.(png|jpg|jpeg|webp)$", "", value, flags=re.I)
    value = re.sub(r"[^a-z0-9]+", "_", value)
    value = re.sub(r"_+", "_", value)
    return value.strip("_")


def pick_first(dictionary, keys, default=None):
    for key in keys:
        if isinstance(dictionary, dict) and key in dictionary and dictionary[key]:
            return dictionary[key]
    return default


def load_recipes_payload(path):
    with open(path, "r", encoding="utf-8") as file:
        payload = json.load(file)

    if isinstance(payload, list):
        return payload, payload

    if isinstance(payload, dict):
        for key in ["recipes", "items", "data"]:
            if isinstance(payload.get(key), list):
                return payload, payload[key]

    raise SystemExit("ERROR: Could not find recipe list in recipes JSON.")


def image_update_key(recipe):
    """
    Prefer updating the existing image field if the recipe already has one.
    Otherwise add imageName.
    """
    for key in IMAGE_KEYS:
        if key in recipe:
            return key
    return "imageName"


def build_image_index(images_dir):
    pngs = sorted(images_dir.glob("*.png"))

    by_stem = {p.stem: p for p in pngs}
    by_title_suffix = {}

    for p in pngs:
        stem = p.stem
        parts = stem.split("_")

        # Try every possible suffix so titles can match:
        # world_mexican_charred_corn_tacos -> charred_corn_tacos
        for i in range(len(parts)):
            suffix = "_".join(parts[i:])
            by_title_suffix.setdefault(suffix, []).append(p)

    return pngs, by_stem, by_title_suffix


def find_matching_image(recipe, by_title_suffix):
    title = str(pick_first(recipe, TITLE_KEYS, "Untitled Recipe"))
    title_slug = slugify(title)

    matches = by_title_suffix.get(title_slug, [])

    if not matches:
        return None

    # If there are multiple, choose the shortest filename first.
    # This avoids weird duplicate suffix files if any exist.
    matches = sorted(matches, key=lambda p: (len(p.stem), p.name))
    return matches[0]


def main():
    parser = argparse.ArgumentParser(
        description="Link regenerated recipe images to recipes.seed.json."
    )

    parser.add_argument(
        "--recipes",
        default="../../../recipes.seed.json",
        help="Path to recipes.seed.json",
    )

    parser.add_argument(
        "--images",
        default=".",
        help="Folder containing generated PNG images",
    )

    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Preview changes without editing recipes.seed.json",
    )

    parser.add_argument(
        "--use-extension",
        action="store_true",
        help="Store image names with .png extension instead of asset stem only",
    )

    args = parser.parse_args()

    recipes_path = Path(args.recipes).resolve()
    images_dir = Path(args.images).resolve()

    if not recipes_path.exists():
        raise SystemExit(f"ERROR: recipes file not found: {recipes_path}")

    if not images_dir.exists():
        raise SystemExit(f"ERROR: images folder not found: {images_dir}")

    payload, recipes = load_recipes_payload(recipes_path)
    pngs, _, by_title_suffix = build_image_index(images_dir)

    linked = []
    missing = []
    changed = 0

    for recipe in recipes:
        title = str(pick_first(recipe, TITLE_KEYS, "Untitled Recipe"))
        image_path = find_matching_image(recipe, by_title_suffix)

        if not image_path:
            missing.append(title)
            continue

        key = image_update_key(recipe)
        new_value = image_path.name if args.use_extension else image_path.stem
        old_value = recipe.get(key)

        linked.append((title, key, old_value, new_value))

        if old_value != new_value:
            changed += 1
            if not args.dry_run:
                recipe[key] = new_value

    print("Recipes file:", recipes_path)
    print("Images folder:", images_dir)
    print("Recipes in app:", len(recipes))
    print("PNG images found:", len(pngs))
    print("Recipes linked:", len(linked))
    print("Recipes missing image:", len(missing))
    print("Recipes needing update:", changed)

    if missing:
        print("\nMissing images:")
        for title in missing[:120]:
            print("-", title)
        if len(missing) > 120:
            print(f"... and {len(missing) - 120} more")

    print("\nSample updates:")
    for title, key, old_value, new_value in linked[:40]:
        print(f"- {title}: {key}: {old_value} -> {new_value}")

    if args.dry_run:
        print("\nDRY RUN ONLY. No file was changed.")
        return

    if missing:
        raise SystemExit(
            "\nERROR: Some recipes are missing images. Fix missing images before writing."
        )

    backup_path = recipes_path.with_suffix(recipes_path.suffix + ".backup_before_image_link")
    shutil.copy2(recipes_path, backup_path)

    with open(recipes_path, "w", encoding="utf-8") as file:
        json.dump(payload, file, indent=2, ensure_ascii=False)
        file.write("\n")

    print("\nBackup created:", backup_path)
    print("Updated recipes file:", recipes_path)
    print("Done.")


if __name__ == "__main__":
    main()
