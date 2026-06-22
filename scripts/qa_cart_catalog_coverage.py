#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RECIPES_PATH = ROOT / "Flame_Fleur" / "Flame_Fleur" / "Resources" / "recipes.seed.enriched.full.json"
CATALOG_PATH = ROOT / "Flame_Fleur" / "Flame_Fleur" / "Resources" / "shopping_ingredients.seed.full.json"
REPORT_DIR = ROOT / "reports"
MD_REPORT = REPORT_DIR / "cart_catalog_qa_report.md"
JSON_REPORT = REPORT_DIR / "cart_catalog_qa_report.json"


def load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def normalize_name(name: str) -> str:
    return re.sub(r"\s+", " ", re.sub(r"[^a-z0-9]+", " ", str(name).strip().lower())).strip()


def tolerant_key(name: str) -> str:
    tokens = normalize_name(name).split()
    normalized_tokens = []
    for token in tokens:
        if len(token) > 3 and token.endswith("ies"):
            normalized_tokens.append(token[:-3] + "y")
        elif len(token) > 3 and token.endswith("ses"):
            normalized_tokens.append(token[:-2])
        elif len(token) > 3 and token.endswith("s") and not token.endswith("ss"):
            normalized_tokens.append(token[:-1])
        else:
            normalized_tokens.append(token)
    return " ".join(normalized_tokens)


def main() -> None:
    REPORT_DIR.mkdir(exist_ok=True)

    errors: list[str] = []
    warnings: list[str] = []

    if not CATALOG_PATH.exists():
        errors.append(f"Missing catalog file: {CATALOG_PATH}")
        catalog = []
    else:
        catalog = load_json(CATALOG_PATH)

    if not RECIPES_PATH.exists():
        errors.append(f"Missing recipe file: {RECIPES_PATH}")
        recipes = []
    else:
        recipes = load_json(RECIPES_PATH)

    recipe_ingredients = []
    ingredient_categories = Counter()
    for recipe in recipes:
        for ingredient in recipe.get("ingredients", []):
            name = str(ingredient.get("name", "")).strip()
            normalized = normalize_name(name)
            if not normalized:
                continue
            recipe_ingredients.append(
                {
                    "recipeID": recipe.get("id"),
                    "name": name,
                    "normalizedName": normalized,
                }
            )
            ingredient_categories[str(ingredient.get("category", "Unknown")).strip() or "Unknown"] += 1

    catalog_ids = [item.get("id") for item in catalog]
    catalog_normalized = [item.get("normalizedName") for item in catalog]
    duplicate_catalog_ids = sorted(item_id for item_id, count in Counter(catalog_ids).items() if count > 1 and item_id)
    duplicate_catalog_normalized = sorted(name for name, count in Counter(catalog_normalized).items() if count > 1 and name)
    missing_fields = {
        field: [item.get("id") for item in catalog if not item.get(field)]
        for field in ("id", "displayName", "normalizedName", "category", "defaultUnit", "estimatedPrice")
    }

    missing_ingredients = []
    catalog_norm_set = {normalize_name(name) for name in catalog_normalized if name}
    catalog_tolerant_set = {tolerant_key(name) for name in catalog_normalized if name}
    for ingredient in recipe_ingredients:
        if ingredient["normalizedName"] not in catalog_norm_set and tolerant_key(ingredient["normalizedName"]) not in catalog_tolerant_set:
            missing_ingredients.append(ingredient)

    shopping_category_counts = Counter(str(item.get("category", "Unknown")).strip() or "Unknown" for item in catalog)

    report = {
        "validationPassed": not errors,
        "catalogCount": len(catalog),
        "recipeIngredientCount": len(recipe_ingredients),
        "uniqueRecipeIngredientCount": len({item["normalizedName"] for item in recipe_ingredients}),
        "uniqueCatalogNormalizedCount": len({name for name in catalog_normalized if name}),
        "duplicateCatalogIDs": duplicate_catalog_ids,
        "duplicateCatalogNormalizedNames": duplicate_catalog_normalized,
        "missingCatalogFields": {key: value for key, value in missing_fields.items() if value},
        "recipeIngredientsMissingFromCatalog": missing_ingredients,
        "missingIngredientCount": len(missing_ingredients),
        "catalogCategoryCounts": shopping_category_counts.most_common(),
        "warnings": warnings,
        "errors": errors,
        "examples": {
            "firstCatalogItems": catalog[:10],
            "firstMissingIngredients": missing_ingredients[:100],
        },
        "sourcePaths": {
            "recipesSeed": str(RECIPES_PATH.relative_to(ROOT)),
            "shoppingCatalog": str(CATALOG_PATH.relative_to(ROOT)),
        },
    }

    lines = [
        "# Cart Catalog QA Report",
        "",
        f"Validation passed: {'yes' if not errors else 'no'}",
        f"Catalog items: {len(catalog)}",
        f"Recipe ingredients checked: {len(recipe_ingredients)}",
        f"Unique recipe ingredient names: {len({item['normalizedName'] for item in recipe_ingredients})}",
        f"Missing ingredients: {len(missing_ingredients)}",
        "",
        "## Catalog categories",
    ]
    for category, count in shopping_category_counts.most_common():
        lines.append(f"- {category}: {count}")

    lines.extend(
        [
            "",
            "## Missing ingredients",
        ]
    )
    if missing_ingredients:
        for item in missing_ingredients[:100]:
            lines.append(f"- {item['name']} (`{item['normalizedName']}`) from {item['recipeID']}")
    else:
        lines.append("- None")

    lines.extend(
        [
            "",
            "## Duplicate catalog IDs",
        ]
    )
    if duplicate_catalog_ids:
        for item_id in duplicate_catalog_ids:
            lines.append(f"- {item_id}")
    else:
        lines.append("- None")

    lines.extend(
        [
            "",
            "## Notes",
            "- Recipe-added ingredients are matched against the shopping catalog by normalized name.",
            "- The cart UI currently shows approximate nutrition in Recipe Detail and uses the enriched ingredient display quantities.",
        ]
    )

    MD_REPORT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    JSON_REPORT.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    if errors:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
