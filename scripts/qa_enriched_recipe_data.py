#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RECIPES_PATH = ROOT / "Flame_Fleur" / "Flame_Fleur" / "Resources" / "recipes.seed.enriched.full.json"
SOURCE_PATH = ROOT / "Flame_Fleur" / "Flame_Fleur" / "Resources" / "recipes.seed.json"
RECIPE_DETAIL_PATH = ROOT / "Flame_Fleur" / "Flame_Fleur" / "Features" / "Recipe" / "RecipeDetailView.swift"
REPORT_DIR = ROOT / "reports"
MD_REPORT = REPORT_DIR / "enriched_recipe_qa_report.md"
JSON_REPORT = REPORT_DIR / "enriched_recipe_qa_report.json"


SUSPICIOUS_GENERIC_INGREDIENTS = {
    "ingredient",
    "food",
    "sauce",
    "seasoning",
    "protein",
    "vegetable",
}

SUSPICIOUS_INSTRUCTION_PHRASES = {
    "cook until done",
    "prepare ingredients",
    "serve and enjoy",
    "follow package instructions",
}


def load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def normalize_name(name: str) -> str:
    return re.sub(r"\s+", " ", re.sub(r"[^a-z0-9]+", " ", str(name).strip().lower())).strip()


def has_ugly_decimal(display_quantity: str) -> bool:
    return bool(re.search(r"\.\d{3,}", display_quantity)) or bool(re.search(r"\.\d{2,}\b", display_quantity))


def is_too_short(step: str) -> bool:
    return len(step.strip().split()) < 4


def main() -> None:
    REPORT_DIR.mkdir(exist_ok=True)

    errors: list[str] = []
    warnings: list[str] = []

    recipes = load_json(RECIPES_PATH)
    source_by_id = {recipe["id"]: recipe for recipe in load_json(SOURCE_PATH)}

    counts = Counter()
    recipe_ids = [recipe.get("id") for recipe in recipes]
    recipe_id_counts = Counter(recipe_ids)
    tag_counter = Counter()
    ingredient_counter = Counter()

    examples: list[dict] = []
    suspicious_ingredients: list[dict] = []
    suspicious_instructions: list[dict] = []

    for recipe in recipes:
        recipe_id = recipe.get("id")
        counts["recipes"] += 1

        if not recipe_id:
            errors.append("Encountered recipe without an id.")
            continue

        source = source_by_id.get(recipe_id)
        if source is None:
            errors.append(f"Recipe id missing from source seed: {recipe_id}")
            continue

        if recipe.get("title", "").strip() == "":
            errors.append(f"Empty recipe title: {recipe_id}")

        if source.get("imageName") and recipe.get("imageName") != source.get("imageName"):
            errors.append(f"imageName changed for recipe {recipe_id}")

        if not recipe.get("category"):
            errors.append(f"Missing category for recipe {recipe_id}")
        if not recipe.get("subcategoryID"):
            warnings.append(f"Missing subcategoryID for recipe {recipe_id}")

        ingredients = recipe.get("ingredients") or []
        if len(ingredients) < 6:
            errors.append(f"Too few ingredients for recipe {recipe_id}")

        ingredient_names_seen: set[str] = set()
        for ingredient in ingredients:
            for field in ("name", "quantity", "unit", "category", "displayQuantity"):
                if field not in ingredient:
                    errors.append(f"Missing ingredient field '{field}' in recipe {recipe_id}")

            name = str(ingredient.get("name", "")).strip()
            display_quantity = str(ingredient.get("displayQuantity", "")).strip()
            if not name:
                errors.append(f"Empty ingredient name in recipe {recipe_id}")

            normalized = normalize_name(name)
            if normalized in ingredient_names_seen:
                warnings.append(f"Duplicate ingredient name in recipe {recipe_id}: {name}")
            ingredient_names_seen.add(normalized)
            ingredient_counter[normalized] += 1

            if has_ugly_decimal(display_quantity):
                errors.append(f"Ugly decimal displayQuantity in recipe {recipe_id}: {display_quantity}")

            if normalized in SUSPICIOUS_GENERIC_INGREDIENTS or any(
                token == normalized for token in SUSPICIOUS_GENERIC_INGREDIENTS
            ):
                suspicious_ingredients.append({"recipeID": recipe_id, "ingredient": name})

        instructions = recipe.get("instructions") or []
        if len(instructions) < 4:
            errors.append(f"Too few instructions for recipe {recipe_id}")

        for step in instructions:
            text = str(step).strip()
            if not text:
                errors.append(f"Empty instruction step in recipe {recipe_id}")
            if any(phrase in text.lower() for phrase in SUSPICIOUS_INSTRUCTION_PHRASES):
                suspicious_instructions.append({"recipeID": recipe_id, "instruction": text})
            if is_too_short(text):
                warnings.append(f"Very short instruction step in recipe {recipe_id}: {text}")

        servings = int(recipe.get("servings", 0) or 0)
        prep = int(recipe.get("prepMinutes", -1) or 0)
        cook = int(recipe.get("cookMinutes", -1) or 0)
        total = int(recipe.get("totalMinutes", -1) or 0)

        if not (1 <= servings <= 8):
            warnings.append(f"Unusual servings for recipe {recipe_id}: {servings}")
        if not (0 <= prep <= 90):
            warnings.append(f"Unusual prep time for recipe {recipe_id}: {prep}")
        if not (0 <= cook <= 180):
            warnings.append(f"Unusual cook time for recipe {recipe_id}: {cook}")
        if total != prep + cook:
            errors.append(f"totalMinutes mismatch for recipe {recipe_id}")
        if total < 5:
            warnings.append(f"Suspiciously short total time for recipe {recipe_id}: {total}")
        if total > 240:
            warnings.append(f"Suspiciously long total time for recipe {recipe_id}: {total}")
        if prep == 0 and cook == 0:
            warnings.append(f"prep/cook both zero for recipe {recipe_id}")

        calories = int(recipe.get("caloriesPerServing", recipe.get("calories", 0)) or 0)
        nutrition = recipe.get("nutritionPerServing") or {}
        if calories < 100 or calories > 1200:
            warnings.append(f"Unusual calories per serving for recipe {recipe_id}: {calories}")

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
                errors.append(f"Missing nutrition key '{key}' in recipe {recipe_id}")

        if isinstance(nutrition, dict):
            numeric_checks = {
                "calories": (100, 1200),
                "proteinGrams": (0, 100),
                "carbsGrams": (0, 180),
                "fatGrams": (0, 90),
                "fiberGrams": (0, 40),
                "sugarGrams": (0, 100),
                "sodiumMilligrams": (0, 3000),
            }
            for key, (low, high) in numeric_checks.items():
                value = nutrition.get(key)
                if isinstance(value, (int, float)) and not (low <= value <= high):
                    warnings.append(f"Suspicious nutrition value for recipe {recipe_id}: {key}={value}")

        tags = recipe.get("tags") or []
        counts["emptyTags"] += 0 if tags else 1
        if len(tags) != len(set(tags)):
            warnings.append(f"Duplicate tags for recipe {recipe_id}")
        for tag in tags:
            tag_counter[tag] += 1

        if len(examples) < 10:
            examples.append(
                {
                    "id": recipe_id,
                    "title": recipe.get("title"),
                    "servings": servings,
                    "prepMinutes": prep,
                    "cookMinutes": cook,
                    "totalMinutes": total,
                    "ingredientCount": len(ingredients),
                    "instructionCount": len(instructions),
                    "caloriesPerServing": calories,
                }
            )

    if len(recipes) != 342:
        errors.append(f"Expected exactly 342 recipes, found {len(recipes)}")

    duplicate_recipe_ids = sorted(recipe_id for recipe_id, count in recipe_id_counts.items() if count > 1)
    if duplicate_recipe_ids:
        errors.append(f"Duplicate recipe IDs found: {duplicate_recipe_ids[:25]}")

    suspicious_ingredient_names = sorted(ingredient_counter.keys() & SUSPICIOUS_GENERIC_INGREDIENTS)

    title_lines = [
        f"# Enriched Recipe QA Report",
        "",
        f"Validation passed: {'yes' if not errors else 'no'}",
        f"Recipe count: {len(recipes)}",
        f"Duplicate recipe IDs: {len(duplicate_recipe_ids)}",
        f"Suspicious generic ingredient names: {len(suspicious_ingredient_names)}",
        f"Recipes with empty tags: {sum(1 for recipe in recipes if not (recipe.get('tags') or []))}",
        "",
        "## Examples",
    ]
    for example in examples:
        title_lines.append(
            f"- {example['id']} | {example['title']} | {example['ingredientCount']} ingredients | "
            f"{example['instructionCount']} steps | {example['totalMinutes']} min total"
        )
    title_lines.extend(
        [
            "",
            "## Most common tags",
        ]
    )
    for tag, count in tag_counter.most_common(15):
        title_lines.append(f"- {tag}: {count}")
    title_lines.extend(
        [
            "",
            "## Suspicious ingredients",
        ]
    )
    if suspicious_ingredient_names:
        for name in suspicious_ingredient_names:
            title_lines.append(f"- {name}")
    else:
        title_lines.append("- None")
    title_lines.extend(
        [
            "",
            "## Suspicious instruction phrases",
        ]
    )
    if suspicious_instructions:
        for item in suspicious_instructions[:50]:
            title_lines.append(f"- {item['recipeID']}: {item['instruction']}")
    else:
        title_lines.append("- None")
    title_lines.extend(
        [
            "",
            "## Notes",
            "- Approximate nutrition is surfaced in Recipe Detail via the existing `Approx. nutrition per serving` label.",
            "- Structured ingredients are used in Recipe Detail and cart add flows.",
        ]
    )

    report = {
        "validationPassed": not errors,
        "recipeCount": len(recipes),
        "duplicateRecipeIDs": duplicate_recipe_ids,
        "recipeTitlesMissing": [recipe.get("id") for recipe in recipes if not str(recipe.get("title", "")).strip()],
        "recipesWithoutCategory": [recipe.get("id") for recipe in recipes if not recipe.get("category")],
        "recipesWithoutSubcategoryID": [recipe.get("id") for recipe in recipes if not recipe.get("subcategoryID")],
        "recipesWithEmptyTags": [recipe.get("id") for recipe in recipes if not (recipe.get("tags") or [])],
        "suspiciousGenericIngredients": suspicious_ingredient_names,
        "suspiciousIngredientExamples": suspicious_ingredients[:100],
        "suspiciousInstructionExamples": suspicious_instructions[:100],
        "tagCounts": tag_counter.most_common(),
        "warnings": warnings,
        "errors": errors,
        "examples": examples,
        "nutritionLabelDetectedInSource": "Approx. nutrition per serving" in RECIPE_DETAIL_PATH.read_text(encoding="utf-8"),
        "sourcePaths": {
            "recipesSeed": str(RECIPES_PATH.relative_to(ROOT)),
            "oldSeed": str(SOURCE_PATH.relative_to(ROOT)),
            "recipeDetail": str(RECIPE_DETAIL_PATH.relative_to(ROOT)),
        },
        "summary": {
            "ingredientsMinPerRecipe": min(len(recipe.get("ingredients") or []) for recipe in recipes) if recipes else 0,
            "ingredientsMaxPerRecipe": max(len(recipe.get("ingredients") or []) for recipe in recipes) if recipes else 0,
            "instructionsMinPerRecipe": min(len(recipe.get("instructions") or []) for recipe in recipes) if recipes else 0,
            "instructionsMaxPerRecipe": max(len(recipe.get("instructions") or []) for recipe in recipes) if recipes else 0,
        },
    }

    MD_REPORT.write_text("\n".join(title_lines) + "\n", encoding="utf-8")
    JSON_REPORT.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    if errors:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
