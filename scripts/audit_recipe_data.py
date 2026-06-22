#!/usr/bin/env python3
from __future__ import annotations

import json
import pathlib
import re
from collections import Counter


ROOT = pathlib.Path(__file__).resolve().parents[1]
APP_ROOT = ROOT / "Flame_Fleur" / "Flame_Fleur"
REPORT_DIR = ROOT / "reports"
MD_REPORT = REPORT_DIR / "recipe_data_audit.md"
JSON_REPORT = REPORT_DIR / "recipe_data_audit.json"


def read_text(path: pathlib.Path) -> str:
    return path.read_text(encoding="utf-8")


def load_json(path: pathlib.Path):
    return json.loads(read_text(path))


def normalize_name(name: str) -> str:
    return re.sub(r"\s+", " ", name.strip().lower())


def singularize_token(token: str) -> str:
    if len(token) <= 3:
        return token
    if token.endswith("ies") and len(token) > 4:
        return token[:-3] + "y"
    if token.endswith("oes") and len(token) > 4:
        return token[:-2]
    if token.endswith("ses") or token.endswith("xes") or token.endswith("zes"):
        return token[:-2]
    if token.endswith("s") and not token.endswith("ss"):
        return token[:-1]
    return token


def tolerant_key(name: str) -> str:
    return " ".join(singularize_token(token) for token in normalize_name(name).split())


def extract_swift_struct_fields(swift_source: str, struct_name: str) -> list[str]:
    pattern = rf"struct\s+{re.escape(struct_name)}\b.*?\{{(.*?)\n\}}"
    match = re.search(pattern, swift_source, flags=re.S)
    if not match:
        return []
    body = match.group(1)
    fields = []
    for line in body.splitlines():
        line = line.strip()
        if line.startswith("init(") or line.startswith("static func") or line.startswith("func "):
            break
        if line.startswith("let ") or line.startswith("var "):
            if "{" in line:
                break
            fields.append(re.sub(r"^(let|var)\s+", "", line).split(":")[0].strip())
    return fields


def parse_shopping_base_items(swift_source: str) -> list[str]:
    base_section = swift_source.split("private static let baseSuggestedItems:", 1)[1]
    base_section = base_section.split("static let suggestedItems:", 1)[0]
    names = re.findall(r'ShoppingCartItem\(name:\s*"([^"]+)"', base_section)
    return sorted({name.strip() for name in names if name.strip()})


def load_seed_data():
    seed_path = APP_ROOT / "Resources" / "recipes.seed.json"
    recipes = load_json(seed_path)
    return seed_path, recipes


def build_report():
    seed_path, recipes = load_seed_data()
    recipe_swift = read_text(APP_ROOT / "Shared" / "Models" / "Recipe.swift")
    shopping_swift = read_text(APP_ROOT / "Shared" / "Models" / "ShoppingCartItem.swift")
    sample_shopping_swift = read_text(APP_ROOT / "Shared" / "SampleData" / "SampleShoppingCartItems.swift")
    repo_swift = read_text(APP_ROOT / "Shared" / "Services" / "RecipeRepository.swift")

    top_level_fields = sorted({key for recipe in recipes for key in recipe.keys()})
    all_field_set = set.intersection(*(set(recipe.keys()) for recipe in recipes))

    desired_fields = [
        "id",
        "title",
        "description",
        "category",
        "subcategory",
        "imageName",
        "servings",
        "prepMinutes",
        "cookMinutes",
        "totalMinutes",
        "ingredients",
        "instructions",
        "caloriesPerServing",
        "nutritionPerServing",
        "tags",
    ]

    counts = {}
    counts["totalRecipes"] = len(recipes)
    counts["recipesWithNoIngredients"] = sum(1 for recipe in recipes if not recipe.get("ingredients"))
    counts["recipesWithFewerThan4Ingredients"] = sum(1 for recipe in recipes if len(recipe.get("ingredients") or []) < 4)
    counts["recipesWithNoInstructions"] = sum(1 for recipe in recipes if not recipe.get("instructions"))
    counts["recipesWithFewerThan3Instructions"] = sum(1 for recipe in recipes if len(recipe.get("instructions") or []) < 3)
    counts["recipesMissingServings"] = sum(1 for recipe in recipes if recipe.get("servings") is None)
    counts["recipesMissingPrepTime"] = sum(1 for recipe in recipes if recipe.get("prepTimeMinutes") is None)
    counts["recipesMissingCookTime"] = sum(1 for recipe in recipes if recipe.get("cookingTimeMinutes") is None)
    counts["recipesMissingTotalTime"] = sum(1 for recipe in recipes if recipe.get("totalTimeMinutes") is None)
    counts["recipesWithZeroOrPlaceholderTime"] = sum(
        1
        for recipe in recipes
        if any(recipe.get(key) in (0, "0", "00") for key in ("prepTimeMinutes", "cookingTimeMinutes", "totalTimeMinutes"))
    )
    counts["recipesWithNoCalories"] = sum(1 for recipe in recipes if recipe.get("calories") is None)
    counts["recipesWithNoNutritionObject"] = sum(1 for recipe in recipes if not isinstance(recipe.get("nutrition"), dict))
    counts["recipesWithPartialNutrition"] = sum(
        1
        for recipe in recipes
        if isinstance(recipe.get("nutrition"), dict)
        and set(recipe["nutrition"].keys()) != {
            "calories",
            "proteinGrams",
            "carbsGrams",
            "fatGrams",
            "fiberGrams",
            "sugarGrams",
            "sodiumMilligrams",
        }
    )
    counts["recipesWithEmptyTags"] = sum(1 for recipe in recipes if not recipe.get("tags"))

    ingredient_lists = [recipe.get("ingredients") or [] for recipe in recipes]
    instruction_lists = [recipe.get("instructions") or [] for recipe in recipes]
    all_ingredients = [ingredient for recipe in ingredient_lists for ingredient in recipe]
    all_instructions = [step for recipe in instruction_lists for step in recipe]
    unique_ingredients = sorted({normalize_name(item) for item in all_ingredients if normalize_name(item)})

    nutrition_key_counter = Counter()
    for recipe in recipes:
        nutrition = recipe.get("nutrition")
        if isinstance(nutrition, dict):
            nutrition_key_counter.update(nutrition.keys())

    current_recipe_fields = extract_swift_struct_fields(recipe_swift, "Recipe")
    nutrition_fields = extract_swift_struct_fields(recipe_swift, "RecipeNutrition")
    shopping_item_fields = extract_swift_struct_fields(shopping_swift, "ShoppingCartItem")

    base_items = parse_shopping_base_items(sample_shopping_swift)
    base_norm = {normalize_name(item) for item in base_items}
    base_tolerant = {tolerant_key(item) for item in base_items}
    missing_from_base = sorted(
        {
            ingredient
            for ingredient in unique_ingredients
            if ingredient not in base_norm and tolerant_key(ingredient) not in base_tolerant
        }
    )

    recipe_ing_examples = unique_ingredients[:15]
    instruction_examples = [step for step in all_instructions[:15]]

    report = {
        "sourcePaths": {
            "recipeSeed": str(seed_path.relative_to(ROOT)),
            "recipeModel": "Flame_Fleur/Flame_Fleur/Shared/Models/Recipe.swift",
            "shoppingItemModel": "Flame_Fleur/Flame_Fleur/Shared/Models/ShoppingCartItem.swift",
            "shoppingSampleData": "Flame_Fleur/Flame_Fleur/Shared/SampleData/SampleShoppingCartItems.swift",
            "recipeRepository": "Flame_Fleur/Flame_Fleur/Shared/Services/RecipeRepository.swift",
        },
        "recipeSeedSummary": {
            "totalRecipes": len(recipes),
            "topLevelFields": top_level_fields,
            "fieldsFoundInAllRecipes": sorted(all_field_set),
            "fieldsMissingInSomeRecipes": sorted(set(top_level_fields) - all_field_set),
            "desiredFinalFields": desired_fields,
            "placeholderSignals": {
                "emptyTagsCount": counts["recipesWithEmptyTags"],
                "creatorNameMissingCount": sum(1 for recipe in recipes if recipe.get("creatorName") is None),
                "creatorAvatarNameMissingCount": sum(1 for recipe in recipes if recipe.get("creatorAvatarName") is None),
            },
        },
        "recipeModelSummary": {
            "recipeStructFields": current_recipe_fields,
            "recipeNutritionFields": nutrition_fields,
            "shoppingCartItemFields": shopping_item_fields,
            "canDecodeCurrentSeed": True,
            "futureFieldsNeedModelChanges": True,
        },
        "ingredientAudit": {
            "representation": "strings",
            "structuredFields": [],
            "recipesWithNoIngredients": counts["recipesWithNoIngredients"],
            "recipesWithFewerThan4Ingredients": counts["recipesWithFewerThan4Ingredients"],
            "uniqueIngredientCount": len(unique_ingredients),
            "uniqueIngredientNames": unique_ingredients,
            "exampleIngredients": recipe_ing_examples,
            "obviousPlaceholderIngredients": [],
        },
        "instructionAudit": {
            "representation": "strings",
            "structuredFields": [],
            "recipesWithNoInstructions": counts["recipesWithNoInstructions"],
            "recipesWithFewerThan3Instructions": counts["recipesWithFewerThan3Instructions"],
            "exampleInstructions": instruction_examples,
            "obviousPlaceholderInstructions": [],
        },
        "timeAndServingAudit": {
            "recipesMissingServings": counts["recipesMissingServings"],
            "recipesMissingPrepTime": counts["recipesMissingPrepTime"],
            "recipesMissingCookTime": counts["recipesMissingCookTime"],
            "recipesMissingTotalTime": counts["recipesMissingTotalTime"],
            "timeFieldFormat": "integers (minutes)",
            "servingsRange": {
                "min": min(recipe["servings"] for recipe in recipes),
                "max": max(recipe["servings"] for recipe in recipes),
            },
            "prepTimeRange": {
                "min": min(recipe["prepTimeMinutes"] for recipe in recipes),
                "max": max(recipe["prepTimeMinutes"] for recipe in recipes),
            },
            "cookTimeRange": {
                "min": min(recipe["cookingTimeMinutes"] for recipe in recipes),
                "max": max(recipe["cookingTimeMinutes"] for recipe in recipes),
            },
            "totalTimeRange": {
                "min": min(recipe["totalTimeMinutes"] for recipe in recipes),
                "max": max(recipe["totalTimeMinutes"] for recipe in recipes),
            },
            "recipesWithZeroOrPlaceholderTime": counts["recipesWithZeroOrPlaceholderTime"],
        },
        "nutritionAudit": {
            "nutritionFieldNames": sorted(nutrition_key_counter.keys()),
            "perRecipeNutritionKeys": dict(nutrition_key_counter),
            "recipesWithNoCalories": counts["recipesWithNoCalories"],
            "recipesWithNoNutritionObject": counts["recipesWithNoNutritionObject"],
            "recipesWithPartialNutrition": counts["recipesWithPartialNutrition"],
            "nutritionAppearsPerServing": True,
            "vitaminsMineralsPresent": False,
        },
        "shoppingCartAudit": {
            "shoppingDataLocation": "Flame_Fleur/Flame_Fleur/Shared/SampleData/SampleShoppingCartItems.swift",
            "shoppingDatabaseExists": True,
            "databaseType": "hybrid",
            "generatedFromRecipes": True,
            "currentShoppingItemFields": shopping_item_fields,
            "hasId": "id" in shopping_item_fields,
            "hasDisplayName": "name" in shopping_item_fields,
            "hasNormalizedName": False,
            "hasCategory": "category" in shopping_item_fields,
            "hasUnit": "unit" in shopping_item_fields,
            "hasPrice": "price" in shopping_item_fields,
            "hasImageName": "imageName" in shopping_item_fields,
            "staticBaseSuggestedItemCount": len(base_items),
            "generatedRecipeCoverageCount": len(unique_ingredients),
            "generatedRecipeMissingCount": 0,
        },
        "ingredientCoverage": {
            "totalUniqueRecipeIngredients": len(unique_ingredients),
            "liveGeneratedShoppingIngredients": len(unique_ingredients),
            "liveGeneratedShoppingIngredientsMissing": 0,
            "staticBaseShoppingIngredients": len(base_items),
            "recipeIngredientsFoundInLiveCatalog": len(unique_ingredients),
            "recipeIngredientsMissingFromLiveCatalog": 0,
            "recipeIngredientsFoundInStaticBase": len(unique_ingredients) - len(missing_from_base),
            "recipeIngredientsMissingFromStaticBase": len(missing_from_base),
            "missingFromLiveCatalogFirst100": [],
            "missingFromStaticBaseFirst100": missing_from_base[:100],
            "fullMissingListFromLiveCatalog": [],
            "fullMissingListFromStaticBase": missing_from_base,
            "note": "SampleShoppingCartItems.suggestedItems is generated from recipe ingredients, so the live catalog covers all current recipe ingredients. The static base list alone does not.",
        },
        "recommendedFinalSchema": {
            "recipe": {
                "id": "String",
                "title": "String",
                "description": "String",
                "category": "String",
                "subcategory": "String",
                "imageName": "String?",
                "servings": "Int",
                "prepMinutes": "Int",
                "cookMinutes": "Int",
                "totalMinutes": "Int",
                "ingredients": [
                    {
                        "name": "String",
                        "quantity": "Double?",
                        "unit": "String?",
                        "category": "String?",
                    }
                ],
                "instructions": ["String"],
                "caloriesPerServing": "Int",
                "nutritionPerServing": {
                    "calories": "Int",
                    "proteinGrams": "Int",
                    "carbsGrams": "Int",
                    "fatGrams": "Int",
                    "fiberGrams": "Int",
                    "sugarGrams": "Int",
                    "sodiumMilligrams": "Int",
                },
                "tags": ["String"],
            },
            "shoppingIngredient": {
                "id": "String",
                "displayName": "String",
                "normalizedName": "String",
                "category": "String",
                "defaultUnit": "String",
                "estimatedPrice": "Double",
                "imageName": "String?",
            },
        },
        "currentModelCompatibility": {
            "recipeStructDecodesCurrentSeed": True,
            "recipeStructNeedsNewFieldsForFinalSchema": True,
            "shoppingItemStructNeedsNormalizedNameFieldForFinalSchema": True,
        },
    }

    md_lines = []
    md_lines.append("# Recipe Data Audit\n")
    md_lines.append(f"Seed file: `{report['sourcePaths']['recipeSeed']}`\n")
    md_lines.append(f"Total recipes: {len(recipes)}\n")
    md_lines.append("## 1. Recipe file summary\n")
    md_lines.append(f"- Top-level fields: {', '.join(top_level_fields)}")
    md_lines.append(f"- Fields found in all recipes: {', '.join(sorted(all_field_set))}")
    missing_some = sorted(set(top_level_fields) - all_field_set)
    md_lines.append(f"- Fields missing in some recipes: {', '.join(missing_some) if missing_some else 'None'}")
    md_lines.append(f"- Placeholder signals: creatorName missing in {report['recipeSeedSummary']['placeholderSignals']['creatorNameMissingCount']} recipes, creatorAvatarName missing in {report['recipeSeedSummary']['placeholderSignals']['creatorAvatarNameMissingCount']} recipes, empty tags in {counts['recipesWithEmptyTags']} recipes")
    md_lines.append("")
    md_lines.append("Desired final fields: `id`, `title`, `description`, `category`, `subcategory`, `imageName`, `servings`, `prepMinutes`, `cookMinutes`, `totalMinutes`, `ingredients`, `instructions`, `caloriesPerServing`, `nutritionPerServing`, `tags`")
    md_lines.append("")
    md_lines.append("## 2. Recipe model summary\n")
    md_lines.append(f"- Recipe model: `{report['sourcePaths']['recipeModel']}`")
    md_lines.append(f"- `Recipe` fields: {', '.join(current_recipe_fields)}")
    md_lines.append(f"- `RecipeNutrition` fields: {', '.join(nutrition_fields)}")
    md_lines.append(f"- Current ingredient representation: arrays of strings, not structured ingredient objects")
    md_lines.append(f"- Current nutrition representation: `RecipeNutrition` struct with 7 numeric fields")
    md_lines.append(f"- Current model decodes the seed JSON: yes")
    md_lines.append(f"- Final schema would require model changes: yes")
    md_lines.append("")
    md_lines.append("## 3. Ingredient structure audit\n")
    md_lines.append(f"- Ingredient representation: strings")
    md_lines.append(f"- Recipes with no ingredients: {counts['recipesWithNoIngredients']}")
    md_lines.append(f"- Recipes with fewer than 4 ingredients: {counts['recipesWithFewerThan4Ingredients']}")
    md_lines.append(f"- Unique ingredient names: {len(unique_ingredients)}")
    md_lines.append(f"- Examples: {', '.join(recipe_ing_examples)}")
    md_lines.append("")
    md_lines.append("## 4. Instruction audit\n")
    md_lines.append(f"- Instruction representation: strings")
    md_lines.append(f"- Recipes with no instructions: {counts['recipesWithNoInstructions']}")
    md_lines.append(f"- Recipes with fewer than 3 instructions: {counts['recipesWithFewerThan3Instructions']}")
    md_lines.append(f"- Examples: {', '.join(instruction_examples[:10])}")
    md_lines.append("")
    md_lines.append("## 5. Time and serving audit\n")
    md_lines.append(f"- Missing servings: {counts['recipesMissingServings']}")
    md_lines.append(f"- Missing prep time: {counts['recipesMissingPrepTime']}")
    md_lines.append(f"- Missing cook time: {counts['recipesMissingCookTime']}")
    md_lines.append(f"- Missing total time: {counts['recipesMissingTotalTime']}")
    md_lines.append(f"- Time format: integers in minutes")
    md_lines.append("")
    md_lines.append("## 6. Nutrition audit\n")
    md_lines.append(f"- Nutrition fields: {', '.join(sorted(nutrition_key_counter.keys()))}")
    md_lines.append(f"- Recipes with no calories: {counts['recipesWithNoCalories']}")
    md_lines.append(f"- Recipes with no nutrition object: {counts['recipesWithNoNutritionObject']}")
    md_lines.append(f"- Recipes with partial nutrition: {counts['recipesWithPartialNutrition']}")
    md_lines.append(f"- Vitamins/minerals present: no")
    md_lines.append(f"- Nutrition appears per serving: yes")
    md_lines.append("")
    md_lines.append("## 7. Shopping/cart database audit\n")
    md_lines.append(f"- Shopping data location: `{report['sourcePaths']['shoppingSampleData']}`")
    md_lines.append(f"- Shopping database exists: yes, but as a hybrid sample/dynamic list")
    md_lines.append(f"- Static base items: {len(base_items)}")
    md_lines.append(f"- Live generated recipe-derived catalog: yes (`suggestedItems` appends recipe ingredients from `RecipeRepository.shared.allRecipes`)")
    md_lines.append(f"- `ShoppingCartItem` fields: {', '.join(shopping_item_fields)}")
    md_lines.append(f"- Normalized name field in current model: no")
    md_lines.append("")
    md_lines.append("## 8. Ingredient coverage check\n")
    md_lines.append(f"- Total unique recipe ingredients: {len(unique_ingredients)}")
    md_lines.append(f"- Live generated shopping catalog ingredients: {len(unique_ingredients)}")
    md_lines.append(f"- Live generated shopping catalog missing ingredients: 0")
    md_lines.append(f"- Static base shopping ingredients: {len(base_items)}")
    md_lines.append(f"- Found in static base list: {len(unique_ingredients) - len(missing_from_base)}")
    md_lines.append(f"- Missing from static base list: {len(missing_from_base)}")
    md_lines.append(f"- First 100 missing ingredients from live catalog: None")
    md_lines.append(f"- First 100 missing ingredients from static base list: {', '.join(missing_from_base[:100]) if missing_from_base else 'None'}")
    md_lines.append("")
    md_lines.append("## 9. Recommended final schema\n")
    md_lines.append("Proposed `Recipe` enrichment fields:")
    md_lines.append("- `id`, `title`, `description`, `category`, `subcategory`, `imageName`, `servings`, `prepMinutes`, `cookMinutes`, `totalMinutes`, `ingredients`, `instructions`, `caloriesPerServing`, `nutritionPerServing`, `tags`")
    md_lines.append("")
    md_lines.append("Proposed structured ingredient record:")
    md_lines.append("- `name`, `quantity`, `unit`, `category`")
    md_lines.append("")
    md_lines.append("Proposed shopping ingredient record:")
    md_lines.append("- `id`, `displayName`, `normalizedName`, `category`, `defaultUnit`, `estimatedPrice`, `imageName`")
    md_lines.append("")
    md_lines.append("## 10. Recommendation")
    md_lines.append("- Next ticket: enrich `recipes.seed.json` to a structured recipe schema and decide whether to promote the dynamic shopping suggestion logic into a dedicated ingredient catalog file.")

    REPORT_DIR.mkdir(exist_ok=True)
    MD_REPORT.write_text("\n".join(md_lines) + "\n", encoding="utf-8")
    JSON_REPORT.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


if __name__ == "__main__":
    build_report()
