#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SEED_PATH = ROOT / "Flame_Fleur" / "Flame_Fleur" / "Resources" / "recipes.seed.json"
ENRICHED_PATH = ROOT / "Flame_Fleur" / "Flame_Fleur" / "Resources" / "recipes.seed.enriched.full.json"
CATALOG_PATH = ROOT / "Flame_Fleur" / "Flame_Fleur" / "Resources" / "shopping_ingredients.seed.full.json"
REPORT_DIR = ROOT / "reports"
MD_REPORT_PATH = REPORT_DIR / "recipe_enrichment_full_report.md"
JSON_REPORT_PATH = REPORT_DIR / "recipe_enrichment_full_report.json"


def normalize_name(name: str) -> str:
    return re.sub(r"\s+", " ", re.sub(r"[^a-z0-9]+", " ", str(name).strip().lower())).strip()


def load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def has_long_decimal(display_quantity: str) -> bool:
    return bool(re.search(r"\.\d{3,}", display_quantity))


def main() -> None:
    REPORT_DIR.mkdir(exist_ok=True)

    errors: list[str] = []
    warnings: list[str] = []

    if not ENRICHED_PATH.exists():
        errors.append(f"Missing enriched full file: {ENRICHED_PATH}")
        recipes = []
    else:
        recipes = load_json(ENRICHED_PATH)

    if not CATALOG_PATH.exists():
        errors.append(f"Missing shopping catalog full file: {CATALOG_PATH}")
        catalog_items = []
    else:
        catalog_items = load_json(CATALOG_PATH)

    seed_by_id = {recipe["id"]: recipe for recipe in load_json(SEED_PATH)}
    catalog_by_normalized = {item["normalizedName"]: item for item in catalog_items if "normalizedName" in item}

    recipe_ids = [recipe.get("id") for recipe in recipes]
    recipe_id_counts = Counter(recipe_ids)
    shopping_id_counts = Counter(item.get("id") for item in catalog_items)
    shopping_normalized_counts = Counter(item.get("normalizedName") for item in catalog_items)

    ingredient_names: list[str] = []
    category_counts: Counter[str] = Counter()
    examples: list[dict] = []

    for recipe in recipes:
        recipe_id = recipe.get("id")
        if recipe_id not in seed_by_id:
            errors.append(f"Recipe id not found in seed: {recipe_id}")
            continue

        source = seed_by_id[recipe_id]
        if recipe.get("imageName") != source.get("imageName"):
            errors.append(f"imageName changed for recipe {recipe_id}")

        if recipe_ids.count(recipe_id) != 1:
            errors.append(f"Duplicate recipe ID detected: {recipe_id}")

        if recipe.get("servings", 0) <= 0:
            errors.append(f"Invalid servings for recipe {recipe_id}")
        if recipe.get("prepMinutes", -1) < 0:
            errors.append(f"Invalid prepMinutes for recipe {recipe_id}")
        if recipe.get("cookMinutes", -1) < 0:
            errors.append(f"Invalid cookMinutes for recipe {recipe_id}")
        if recipe.get("totalMinutes") != recipe.get("prepMinutes", 0) + recipe.get("cookMinutes", 0):
            errors.append(f"totalMinutes mismatch for recipe {recipe_id}")

        ingredients = recipe.get("ingredients")
        if not isinstance(ingredients, list) or len(ingredients) < 6:
            errors.append(f"Too few ingredients for recipe {recipe_id}")
        else:
            for ingredient in ingredients:
                for field in ["name", "quantity", "unit", "category", "displayQuantity"]:
                    if field not in ingredient:
                        errors.append(f"Missing ingredient field '{field}' in recipe {recipe_id}")
                display_quantity = str(ingredient.get("displayQuantity", ""))
                if has_long_decimal(display_quantity):
                    errors.append(f"Ugly decimal displayQuantity in recipe {recipe_id}: {display_quantity}")
                normalized = normalize_name(ingredient.get("name", ""))
                ingredient_names.append(normalized)
                category_counts[str(ingredient.get("category", "Unknown")).strip() or "Unknown"] += 1
                if normalized not in catalog_by_normalized:
                    errors.append(f"Missing shopping ingredient for '{ingredient.get('name')}' in recipe {recipe_id}")

        instructions = recipe.get("instructions")
        if not isinstance(instructions, list) or len(instructions) < 4:
            errors.append(f"Too few instructions for recipe {recipe_id}")

        nutrition = recipe.get("nutritionPerServing")
        if not isinstance(nutrition, dict):
            errors.append(f"Missing nutritionPerServing for recipe {recipe_id}")
        else:
            for key in [
                "calories",
                "proteinGrams",
                "carbsGrams",
                "fatGrams",
                "fiberGrams",
                "sugarGrams",
                "sodiumMilligrams",
            ]:
                if key not in nutrition:
                    errors.append(f"Missing nutrition key '{key}' in recipe {recipe_id}")

        if "caloriesPerServing" not in recipe:
            errors.append(f"Missing caloriesPerServing for recipe {recipe_id}")

        if len(examples) < 10:
            examples.append(
                {
                    "id": recipe_id,
                    "title": recipe.get("title"),
                    "servings": recipe.get("servings"),
                    "ingredientCount": len(ingredients) if isinstance(ingredients, list) else 0,
                    "instructionCount": len(instructions) if isinstance(instructions, list) else 0,
                    "caloriesPerServing": recipe.get("caloriesPerServing"),
                }
            )

    if len(recipes) != 342:
        errors.append(f"Expected 342 recipes, found {len(recipes)}")

    original_ids = [recipe["id"] for recipe in load_json(SEED_PATH)]
    if recipe_ids != original_ids:
        errors.append("Recipe order or IDs do not exactly match the original seed file")

    duplicate_recipe_ids = sorted([recipe_id for recipe_id, count in recipe_id_counts.items() if count > 1 and recipe_id is not None])
    duplicate_shopping_ids = sorted([item_id for item_id, count in shopping_id_counts.items() if count > 1 and item_id is not None])
    duplicate_shopping_normalized = sorted([name for name, count in shopping_normalized_counts.items() if count > 1 and name is not None])

    if duplicate_recipe_ids:
        errors.append(f"Duplicate recipe IDs: {duplicate_recipe_ids[:25]}")
    if duplicate_shopping_ids:
        errors.append(f"Duplicate shopping IDs: {duplicate_shopping_ids[:25]}")
    if duplicate_shopping_normalized:
        errors.append(f"Duplicate shopping normalized names: {duplicate_shopping_normalized[:25]}")

    unique_ingredients = sorted(set(ingredient_names))
    unique_shopping = sorted({item["normalizedName"] for item in catalog_items if "normalizedName" in item})
    missing_ingredients = sorted(set(unique_ingredients) - set(unique_shopping))

    if missing_ingredients:
        errors.append(f"Missing shopping coverage for ingredients: {missing_ingredients[:50]}")

    category_ranking = category_counts.most_common(10)
    validated = not errors
    if not validated:
        warnings.append("Full enrichment did not pass all validation checks.")

    report = {
        "validationPassed": validated,
        "recipeCount": len(recipes),
        "uniqueRecipeIngredientCount": len(unique_ingredients),
        "uniqueShoppingIngredientCount": len(unique_shopping),
        "recipeIdsEnriched": recipe_ids,
        "topIngredientCategories": [
            {"category": category, "count": count} for category, count in category_ranking
        ],
        "examples": examples,
        "shoppingIngredientsGenerated": [
            {
                "id": item.get("id"),
                "displayName": item.get("displayName"),
                "normalizedName": item.get("normalizedName"),
                "category": item.get("category"),
            }
            for item in catalog_items
        ],
        "warnings": warnings,
        "errors": errors,
        "missingIngredients": missing_ingredients,
        "nextRecommendedSteps": [
            "Review the full enriched schema against the current Swift Recipe model.",
            "Plan the Swift model migration for structured ingredients and displayQuantity support.",
            "Promote the full enriched JSON into the app only after the model update is in place.",
        ],
        "schemaCompatibilityConcerns": [
            "Current Swift `Recipe.ingredients` is `[String]`, but the full output uses structured ingredient objects with displayQuantity.",
            "Current Swift `Recipe` stores `prepTimeMinutes`, `cookingTimeMinutes`, `totalTimeMinutes`, `calories`, and `nutrition`; the enriched output also carries `prepMinutes`, `cookMinutes`, `totalMinutes`, `caloriesPerServing`, and `nutritionPerServing`.",
            "Current shopping item model has no `normalizedName` field; the catalog output depends on it for deduplication and matching.",
        ],
    }

    lines = []
    lines.append("# Recipe Enrichment Full Report")
    lines.append("")
    lines.append(f"Validation passed: {'yes' if validated else 'no'}")
    lines.append(f"Recipes enriched: {len(recipes)}")
    lines.append(f"Unique recipe ingredients: {len(unique_ingredients)}")
    lines.append(f"Unique shopping ingredients: {len(unique_shopping)}")
    lines.append("")
    lines.append("## Top ingredient categories")
    for category, count in category_ranking:
        lines.append(f"- {category}: {count}")
    lines.append("")
    lines.append("## Recipe IDs")
    for recipe_id in recipe_ids:
        lines.append(f"- {recipe_id}")
    lines.append("")
    lines.append("## Examples")
    for example in examples:
        lines.append(
            f"- {example['id']} | {example['title']} | servings {example['servings']} | "
            f"{example['ingredientCount']} ingredients | {example['instructionCount']} steps | "
            f"{example['caloriesPerServing']} cal/serving"
        )
    lines.append("")
    lines.append("## Shopping ingredients")
    for item in catalog_items:
        lines.append(f"- {item.get('displayName')} (`{item.get('normalizedName')}`) [{item.get('category')}]")
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
    lines.append("## Missing ingredients")
    if missing_ingredients:
        for name in missing_ingredients:
            lines.append(f"- {name}")
    else:
        lines.append("- None")
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
