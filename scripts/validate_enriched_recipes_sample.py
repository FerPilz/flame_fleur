#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SEED_PATH = ROOT / "Flame_Fleur" / "Flame_Fleur" / "Resources" / "recipes.seed.json"
ENRICHED_PATH = ROOT / "Flame_Fleur" / "Flame_Fleur" / "Resources" / "recipes.seed.enriched.sample.json"
CATALOG_PATH = ROOT / "Flame_Fleur" / "Flame_Fleur" / "Resources" / "shopping_ingredients.seed.sample.json"
REPORT_DIR = ROOT / "reports"
MD_REPORT_PATH = REPORT_DIR / "recipe_enrichment_sample_report.md"
JSON_REPORT_PATH = REPORT_DIR / "recipe_enrichment_sample_report.json"


def normalize_name(name: str) -> str:
    return re.sub(r"\s+", " ", name.strip().lower())


def load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> None:
    REPORT_DIR.mkdir(exist_ok=True)

    errors: list[str] = []
    warnings: list[str] = []

    if not ENRICHED_PATH.exists():
        errors.append(f"Missing enriched sample file: {ENRICHED_PATH}")
        sample_recipes = []
    else:
        sample_recipes = load_json(ENRICHED_PATH)

    if not CATALOG_PATH.exists():
        errors.append(f"Missing shopping catalog sample file: {CATALOG_PATH}")
        catalog_items = []
    else:
        catalog_items = load_json(CATALOG_PATH)

    seed_by_id = {recipe["id"]: recipe for recipe in load_json(SEED_PATH)}
    catalog_by_normalized = {item["normalizedName"]: item for item in catalog_items if "normalizedName" in item}

    recipe_ids = [recipe.get("id") for recipe in sample_recipes]
    recipe_id_counts = Counter(recipe_ids)
    shopping_id_counts = Counter(item.get("id") for item in catalog_items)

    ingredient_names = []
    for recipe in sample_recipes:
        if recipe.get("id") not in seed_by_id:
            errors.append(f"Recipe id not found in seed: {recipe.get('id')}")
            continue
        source = seed_by_id[recipe["id"]]
        if recipe.get("imageName") != source.get("imageName"):
            errors.append(f"imageName changed for recipe {recipe['id']}")

        if recipe.get("servings", 0) <= 0:
            errors.append(f"Invalid servings for recipe {recipe['id']}")
        if recipe.get("prepMinutes", -1) < 0:
            errors.append(f"Invalid prepMinutes for recipe {recipe['id']}")
        if recipe.get("cookMinutes", -1) < 0:
            errors.append(f"Invalid cookMinutes for recipe {recipe['id']}")
        if recipe.get("totalMinutes") != recipe.get("prepMinutes", 0) + recipe.get("cookMinutes", 0):
            errors.append(f"totalMinutes mismatch for recipe {recipe['id']}")

        ingredients = recipe.get("ingredients")
        if not isinstance(ingredients, list) or len(ingredients) < 6:
            errors.append(f"Too few ingredients for recipe {recipe['id']}")
        else:
            for ingredient in ingredients:
                for field in ["name", "quantity", "unit", "category"]:
                    if field not in ingredient:
                        errors.append(f"Missing ingredient field '{field}' in recipe {recipe['id']}")
                ingredient_names.append(normalize_name(str(ingredient.get("name", ""))))
                normalized = normalize_name(str(ingredient.get("name", "")))
                if normalized not in catalog_by_normalized:
                    errors.append(f"Missing shopping ingredient for '{ingredient.get('name')}' in recipe {recipe['id']}")

        instructions = recipe.get("instructions")
        if not isinstance(instructions, list) or len(instructions) < 4:
            errors.append(f"Too few instructions for recipe {recipe['id']}")

        nutrition = recipe.get("nutritionPerServing")
        if not isinstance(nutrition, dict):
            errors.append(f"Missing nutritionPerServing for recipe {recipe['id']}")
        else:
            required_nutrition_keys = [
                "calories",
                "proteinGrams",
                "carbsGrams",
                "fatGrams",
                "fiberGrams",
                "sugarGrams",
                "sodiumMilligrams",
            ]
            for key in required_nutrition_keys:
                if key not in nutrition:
                    errors.append(f"Missing nutrition key '{key}' in recipe {recipe['id']}")

        if "caloriesPerServing" not in recipe:
            errors.append(f"Missing caloriesPerServing for recipe {recipe['id']}")

    if len(sample_recipes) != 10:
        errors.append(f"Expected 10 sample recipes, found {len(sample_recipes)}")

    duplicate_recipe_ids = sorted([recipe_id for recipe_id, count in recipe_id_counts.items() if count > 1 and recipe_id is not None])
    duplicate_shopping_ids = sorted([item_id for item_id, count in shopping_id_counts.items() if count > 1 and item_id is not None])

    if duplicate_recipe_ids:
        errors.append(f"Duplicate recipe IDs: {duplicate_recipe_ids}")
    if duplicate_shopping_ids:
        errors.append(f"Duplicate shopping IDs: {duplicate_shopping_ids}")

    unique_ingredients = sorted(set(ingredient_names))
    unique_shopping = sorted({item["normalizedName"] for item in catalog_items if "normalizedName" in item})

    validated = not errors
    if not validated:
        warnings.append("Sample enrichment did not pass all validation checks.")

    report = {
        "validationPassed": validated,
        "recipeCount": len(sample_recipes),
        "uniqueSampleIngredientCount": len(unique_ingredients),
        "uniqueShoppingIngredientCount": len(unique_shopping),
        "recipeIdsEnriched": recipe_ids,
        "shoppingIngredientsGenerated": [
            {
                "id": item.get("id"),
                "displayName": item.get("displayName"),
                "normalizedName": item.get("normalizedName"),
            }
            for item in catalog_items
        ],
        "warnings": warnings,
        "errors": errors,
        "nextRecommendedSteps": [
            "Review the sample recipe structure against the current Swift model.",
            "Promote the sample enrichment schema into a repeatable generator for the full 342-recipe batch.",
            "Decide how the Swift `Recipe` and shopping models should evolve to support structured ingredients and per-serving nutrition.",
        ],
        "schemaCompatibilityConcerns": [
            "Current Swift `Recipe.ingredients` is `[String]`, but the sample uses structured ingredient objects.",
            "Current Swift `Recipe` stores `prepTimeMinutes`, `cookingTimeMinutes`, `totalTimeMinutes`, `calories`, and `nutrition`; the enriched sample adds `prepMinutes`, `cookMinutes`, `totalMinutes`, `caloriesPerServing`, and `nutritionPerServing`.",
            "Current shopping item model has no `normalizedName` field; the catalog sample uses it for deduplication and matching.",
        ],
    }

    lines = []
    lines.append("# Recipe Enrichment Sample Report")
    lines.append("")
    lines.append(f"Validation passed: {'yes' if validated else 'no'}")
    lines.append(f"Recipes enriched: {len(sample_recipes)}")
    lines.append(f"Unique sample ingredients: {len(unique_ingredients)}")
    lines.append(f"Unique shopping ingredients: {len(unique_shopping)}")
    lines.append("")
    lines.append("## Recipe IDs")
    for recipe_id in recipe_ids:
        lines.append(f"- {recipe_id}")
    lines.append("")
    lines.append("## Shopping ingredients")
    for item in catalog_items:
        lines.append(f"- {item.get('displayName')} (`{item.get('normalizedName')}`)")
    lines.append("")
    if warnings:
        lines.append("## Warnings")
        for warning in warnings:
            lines.append(f"- {warning}")
        lines.append("")
    if errors:
        lines.append("## Errors")
        for error in errors:
            lines.append(f"- {error}")
        lines.append("")
    lines.append("## Next steps")
    for step in report["nextRecommendedSteps"]:
        lines.append(f"- {step}")
    lines.append("")
    lines.append("## Schema compatibility concerns")
    for concern in report["schemaCompatibilityConcerns"]:
        lines.append(f"- {concern}")
    lines.append("")

    MD_REPORT_PATH.write_text("\n".join(lines), encoding="utf-8")
    JSON_REPORT_PATH.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    if not validated:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
