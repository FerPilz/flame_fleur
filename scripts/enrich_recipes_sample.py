#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SEED_PATH = ROOT / "Flame_Fleur" / "Flame_Fleur" / "Resources" / "recipes.seed.json"
OUTPUT_PATH = ROOT / "Flame_Fleur" / "Flame_Fleur" / "Resources" / "recipes.seed.enriched.sample.json"

SAMPLE_RECIPE_IDS = [
    "recipe-seed-world-cuisine-italian-1",
    "recipe-seed-world-cuisine-italian-2",
    "recipe-seed-world-cuisine-italian-3",
    "recipe-seed-world-cuisine-italian-4",
    "recipe-seed-world-cuisine-italian-5",
    "recipe-seed-world-cuisine-italian-6",
    "recipe-seed-world-cuisine-mexican-1",
    "recipe-seed-world-cuisine-mexican-2",
    "recipe-seed-world-cuisine-mexican-3",
    "recipe-seed-world-cuisine-mexican-4",
]


def ing(name: str, quantity, unit: str, category: str, notes: str = "") -> dict:
    return {
        "name": name,
        "quantity": quantity,
        "unit": unit,
        "category": category,
        "notes": notes,
    }


ENRICHMENTS = {
    "recipe-seed-world-cuisine-italian-1": {
        "description": "A bright tomato pasta with basil, garlic, and a little heat for a simple weeknight dinner.",
        "servings": 2,
        "prepMinutes": 15,
        "cookMinutes": 25,
        "caloriesPerServing": 540,
        "nutritionPerServing": {
            "calories": 540,
            "proteinGrams": 18,
            "carbsGrams": 68,
            "fatGrams": 22,
            "fiberGrams": 7,
            "sugarGrams": 10,
            "sodiumMilligrams": 760,
        },
        "tags": ["italian", "pasta", "weeknight", "comfortFood", "quickDinner"],
        "ingredients": [
            ing("Spaghetti", 8, "oz", "Pantry"),
            ing("Cherry Tomatoes", 2, "cups", "Produce"),
            ing("Tomato Paste", 2, "tbsp", "Pantry"),
            ing("Garlic", 4, "cloves", "Produce"),
            ing("Fresh Basil", 1, "cup", "Produce"),
            ing("Olive Oil", 3, "tbsp", "Pantry"),
            ing("Parmesan", 1 / 2, "cup", "Dairy"),
            ing("Crushed Red Pepper Flakes", 1, "tsp", "Pantry"),
        ],
        "instructions": [
            "Bring a large pot of salted water to a boil and cook the spaghetti until just al dente.",
            "Warm the olive oil in a wide skillet and cook the garlic until fragrant.",
            "Add the tomatoes and tomato paste, then cook until the tomatoes start to burst and thicken.",
            "Toss in the pasta, basil, and a splash of pasta water until glossy and coated.",
            "Finish with parmesan, red pepper flakes, and a final drizzle of olive oil before serving.",
        ],
    },
    "recipe-seed-world-cuisine-italian-2": {
        "description": "Creamy risotto with earthy mushrooms, white wine, and parmesan for a cozy polished dinner.",
        "servings": 4,
        "prepMinutes": 20,
        "cookMinutes": 35,
        "caloriesPerServing": 470,
        "nutritionPerServing": {
            "calories": 470,
            "proteinGrams": 14,
            "carbsGrams": 58,
            "fatGrams": 18,
            "fiberGrams": 4,
            "sugarGrams": 5,
            "sodiumMilligrams": 650,
        },
        "tags": ["italian", "risotto", "mushrooms", "comfortFood", "vegetarian"],
        "ingredients": [
            ing("Arborio Rice", 1.5, "cups", "Pantry"),
            ing("Cremini Mushrooms", 12, "oz", "Produce"),
            ing("Shallot", 1, "each", "Produce"),
            ing("Garlic", 3, "cloves", "Produce"),
            ing("Vegetable Stock", 5, "cups", "Pantry"),
            ing("Dry White Wine", 1 / 2, "cup", "Pantry"),
            ing("Parmesan", 3 / 4, "cup", "Dairy"),
            ing("Butter", 2, "tbsp", "Dairy"),
            ing("Olive Oil", 2, "tbsp", "Pantry"),
            ing("Fresh Thyme", 2, "tsp", "Produce"),
        ],
        "instructions": [
            "Warm the stock in a separate pot and keep it at a gentle simmer.",
            "Sauté the mushrooms, shallot, and garlic in olive oil until browned and fragrant.",
            "Stir in the rice, toast briefly, then add the white wine and let it cook off.",
            "Add the warm stock a ladle at a time, stirring until each addition is absorbed.",
            "Finish with butter, parmesan, and thyme for a creamy texture.",
            "Serve immediately while the risotto is loose and glossy.",
        ],
    },
    "recipe-seed-world-cuisine-italian-3": {
        "description": "A rustic soup of tender beans, vegetables, and herbs with a rich tomato broth.",
        "servings": 4,
        "prepMinutes": 15,
        "cookMinutes": 35,
        "caloriesPerServing": 390,
        "nutritionPerServing": {
            "calories": 390,
            "proteinGrams": 16,
            "carbsGrams": 52,
            "fatGrams": 13,
            "fiberGrams": 11,
            "sugarGrams": 8,
            "sodiumMilligrams": 710,
        },
        "tags": ["italian", "soup", "beans", "cozy", "vegetarian"],
        "ingredients": [
            ing("Cannellini Beans", 2, "cans", "Pantry"),
            ing("Carrots", 2, "each", "Produce"),
            ing("Celery", 2, "stalks", "Produce"),
            ing("Onion", 1, "each", "Produce"),
            ing("Garlic", 4, "cloves", "Produce"),
            ing("Tomato Paste", 2, "tbsp", "Pantry"),
            ing("Vegetable Stock", 5, "cups", "Pantry"),
            ing("Kale", 3, "cups", "Produce"),
            ing("Rosemary", 1, "tbsp", "Produce"),
            ing("Olive Oil", 2, "tbsp", "Pantry"),
            ing("Parmesan Rind", 1, "each", "Dairy", "Optional for extra depth"),
        ],
        "instructions": [
            "Sweat the onion, carrots, and celery in olive oil until softened.",
            "Add garlic, tomato paste, and rosemary, cooking until fragrant.",
            "Stir in the beans and vegetable stock, then simmer until the broth tastes rounded.",
            "Fold in the kale and cook just until tender.",
            "Season with salt and pepper, then finish with a parmesan garnish if desired.",
        ],
    },
    "recipe-seed-world-cuisine-italian-4": {
        "description": "Light gnocchi with ricotta, lemon, and tender spinach in a silky butter sauce.",
        "servings": 4,
        "prepMinutes": 20,
        "cookMinutes": 15,
        "caloriesPerServing": 510,
        "nutritionPerServing": {
            "calories": 510,
            "proteinGrams": 17,
            "carbsGrams": 60,
            "fatGrams": 20,
            "fiberGrams": 4,
            "sugarGrams": 6,
            "sodiumMilligrams": 640,
        },
        "tags": ["italian", "gnocchi", "lemon", "ricotta", "quickDinner"],
        "ingredients": [
            ing("Potato Gnocchi", 20, "oz", "Pantry"),
            ing("Ricotta", 1, "cup", "Dairy"),
            ing("Lemon", 1, "each", "Produce"),
            ing("Spinach", 4, "cups", "Produce"),
            ing("Butter", 3, "tbsp", "Dairy"),
            ing("Parmesan", 1 / 2, "cup", "Dairy"),
            ing("Garlic", 2, "cloves", "Produce"),
            ing("Fresh Sage", 1, "tbsp", "Produce"),
            ing("Olive Oil", 1, "tbsp", "Pantry"),
            ing("Black Pepper", 1, "tsp", "Pantry"),
        ],
        "instructions": [
            "Boil the gnocchi until they float, then drain and reserve a little cooking water.",
            "Melt butter with olive oil, garlic, and sage until aromatic.",
            "Add the spinach and let it wilt into the pan.",
            "Fold in ricotta, lemon zest, parmesan, and a splash of pasta water to make a light sauce.",
            "Toss the gnocchi through the sauce and finish with black pepper.",
        ],
    },
    "recipe-seed-world-cuisine-italian-5": {
        "description": "Layers of roasted eggplant, marinara, and melted cheese baked until bubbling and golden.",
        "servings": 4,
        "prepMinutes": 25,
        "cookMinutes": 40,
        "caloriesPerServing": 590,
        "nutritionPerServing": {
            "calories": 590,
            "proteinGrams": 24,
            "carbsGrams": 46,
            "fatGrams": 34,
            "fiberGrams": 8,
            "sugarGrams": 10,
            "sodiumMilligrams": 830,
        },
        "tags": ["italian", "eggplant", "baked", "cheesy", "comfortFood"],
        "ingredients": [
            ing("Eggplant", 2, "large", "Produce"),
            ing("Marinara Sauce", 3, "cups", "Pantry"),
            ing("Mozzarella", 12, "oz", "Dairy"),
            ing("Parmesan", 1, "cup", "Dairy"),
            ing("Breadcrumbs", 1, "cup", "Pantry"),
            ing("Garlic", 3, "cloves", "Produce"),
            ing("Basil", 1, "cup", "Produce"),
            ing("Olive Oil", 3, "tbsp", "Pantry"),
            ing("Egg", 1, "each", "Dairy"),
            ing("Flour", 1 / 2, "cup", "Pantry"),
        ],
        "instructions": [
            "Slice and salt the eggplant, then pat it dry after the moisture draws out.",
            "Dredge the slices lightly in flour and egg, then brown them in olive oil.",
            "Layer eggplant with marinara, mozzarella, parmesan, garlic, and basil.",
            "Top with breadcrumbs for a crisp finish and bake until bubbling.",
            "Rest the bake for a few minutes before slicing into neat portions.",
        ],
    },
    "recipe-seed-world-cuisine-italian-6": {
        "description": "Garlic shrimp and linguine tossed in lemon butter with parsley and a whisper of chili.",
        "servings": 4,
        "prepMinutes": 15,
        "cookMinutes": 20,
        "caloriesPerServing": 520,
        "nutritionPerServing": {
            "calories": 520,
            "proteinGrams": 28,
            "carbsGrams": 57,
            "fatGrams": 20,
            "fiberGrams": 3,
            "sugarGrams": 4,
            "sodiumMilligrams": 780,
        },
        "tags": ["italian", "shrimp", "linguine", "seafood", "quickDinner"],
        "ingredients": [
            ing("Linguine", 12, "oz", "Pantry"),
            ing("Shrimp", 1.25, "lb", "Protein"),
            ing("Garlic", 5, "cloves", "Produce"),
            ing("Lemon", 1, "each", "Produce"),
            ing("Butter", 3, "tbsp", "Dairy"),
            ing("Olive Oil", 2, "tbsp", "Pantry"),
            ing("Parsley", 1, "cup", "Produce"),
            ing("Crushed Red Pepper Flakes", 1, "tsp", "Pantry"),
            ing("White Wine", 1 / 2, "cup", "Pantry"),
            ing("Parmesan", 1 / 3, "cup", "Dairy"),
        ],
        "instructions": [
            "Cook the linguine in salted water until al dente and reserve some pasta water.",
            "Sauté the shrimp in olive oil until just pink, then set aside.",
            "Cook the garlic and red pepper flakes in butter until fragrant.",
            "Deglaze with white wine, then add lemon juice and a bit of pasta water.",
            "Return the shrimp and pasta to the skillet, toss with parsley, and finish with parmesan.",
        ],
    },
    "recipe-seed-world-cuisine-mexican-1": {
        "description": "Smoky charred corn tacos with lime, cabbage, black beans, and a cool creamy finish.",
        "servings": 4,
        "prepMinutes": 20,
        "cookMinutes": 20,
        "caloriesPerServing": 440,
        "nutritionPerServing": {
            "calories": 440,
            "proteinGrams": 15,
            "carbsGrams": 54,
            "fatGrams": 18,
            "fiberGrams": 10,
            "sugarGrams": 7,
            "sodiumMilligrams": 690,
        },
        "tags": ["mexican", "tacos", "corn", "weeknight", "vegetarian"],
        "ingredients": [
            ing("Corn Tortillas", 12, "each", "Pantry"),
            ing("Corn Kernels", 3, "cups", "Produce"),
            ing("Black Beans", 2, "cups", "Pantry"),
            ing("Avocado", 2, "each", "Produce"),
            ing("Lime", 2, "each", "Produce"),
            ing("Cabbage", 3, "cups", "Produce"),
            ing("Red Onion", 1 / 2, "each", "Produce"),
            ing("Cilantro", 1, "cup", "Produce"),
            ing("Cotija", 3 / 4, "cup", "Dairy"),
            ing("Sour Cream", 1 / 2, "cup", "Dairy"),
            ing("Chili Powder", 2, "tsp", "Pantry"),
        ],
        "instructions": [
            "Char the corn in a hot skillet until lightly browned.",
            "Warm the black beans with chili powder and a pinch of salt.",
            "Toss the cabbage with lime juice, cilantro, and thinly sliced red onion.",
            "Warm the tortillas, then fill them with beans, corn, avocado, and cabbage slaw.",
            "Finish with cotija, sour cream, and a squeeze of fresh lime.",
        ],
    },
    "recipe-seed-world-cuisine-mexican-2": {
        "description": "Chicken tinga bowls with smoky tomato sauce, rice, beans, avocado, and bright toppings.",
        "servings": 4,
        "prepMinutes": 20,
        "cookMinutes": 30,
        "caloriesPerServing": 560,
        "nutritionPerServing": {
            "calories": 560,
            "proteinGrams": 31,
            "carbsGrams": 56,
            "fatGrams": 23,
            "fiberGrams": 9,
            "sugarGrams": 7,
            "sodiumMilligrams": 840,
        },
        "tags": ["mexican", "bowls", "chicken", "smoky", "highProtein"],
        "ingredients": [
            ing("Chicken Thighs", 1.5, "lb", "Protein"),
            ing("White Rice", 1.5, "cups", "Pantry"),
            ing("Black Beans", 2, "cups", "Pantry"),
            ing("Tomatoes", 4, "each", "Produce"),
            ing("Chipotle In Adobo", 2, "tbsp", "Pantry"),
            ing("Avocado", 2, "each", "Produce"),
            ing("Lime", 2, "each", "Produce"),
            ing("Lettuce", 3, "cups", "Produce"),
            ing("Cilantro", 1, "cup", "Produce"),
            ing("Onion", 1, "each", "Produce"),
            ing("Cumin", 2, "tsp", "Pantry"),
        ],
        "instructions": [
            "Simmer the chicken with tomatoes, onion, cumin, and chipotle until tender and shreddable.",
            "Cook the rice until fluffy and season it lightly with salt and lime.",
            "Warm the black beans with a splash of cooking liquid or water.",
            "Build bowls with rice, beans, tinga chicken, lettuce, avocado, and cilantro.",
            "Finish with lime juice and a spoonful of the smoky sauce.",
        ],
    },
    "recipe-seed-world-cuisine-mexican-3": {
        "description": "Roasted poblano enchiladas with a green salsa, melty cheese, and a satisfying baked finish.",
        "servings": 6,
        "prepMinutes": 25,
        "cookMinutes": 35,
        "caloriesPerServing": 610,
        "nutritionPerServing": {
            "calories": 610,
            "proteinGrams": 26,
            "carbsGrams": 54,
            "fatGrams": 32,
            "fiberGrams": 8,
            "sugarGrams": 6,
            "sodiumMilligrams": 920,
        },
        "tags": ["mexican", "enchiladas", "poblano", "baked", "comfortFood"],
        "ingredients": [
            ing("Poblano Peppers", 4, "each", "Produce"),
            ing("Corn Tortillas", 12, "each", "Pantry"),
            ing("Shredded Chicken", 3, "cups", "Protein"),
            ing("Monterey Jack", 2, "cups", "Dairy"),
            ing("Tomatillo Salsa", 2.5, "cups", "Pantry"),
            ing("Onion", 1, "each", "Produce"),
            ing("Garlic", 3, "cloves", "Produce"),
            ing("Cilantro", 1, "cup", "Produce"),
            ing("Mexican Crema", 1 / 2, "cup", "Dairy"),
            ing("Cumin", 1.5, "tsp", "Pantry"),
            ing("Olive Oil", 2, "tbsp", "Pantry"),
        ],
        "instructions": [
            "Roast the poblanos until blistered, then peel and slice them.",
            "Sauté onion and garlic, then mix with shredded chicken, cumin, and a little salsa.",
            "Fill the tortillas with chicken and poblano strips, then roll into enchiladas.",
            "Arrange in a baking dish, spoon over tomatillo salsa, and top with cheese.",
            "Bake until bubbling, then finish with cilantro and crema.",
        ],
    },
    "recipe-seed-world-cuisine-mexican-4": {
        "description": "Citrus shrimp tostadas with crisp cabbage, creamy avocado, and a lively salsa finish.",
        "servings": 4,
        "prepMinutes": 20,
        "cookMinutes": 15,
        "caloriesPerServing": 470,
        "nutritionPerServing": {
            "calories": 470,
            "proteinGrams": 24,
            "carbsGrams": 43,
            "fatGrams": 20,
            "fiberGrams": 7,
            "sugarGrams": 6,
            "sodiumMilligrams": 760,
        },
        "tags": ["mexican", "shrimp", "tostadas", "citrus", "seafood"],
        "ingredients": [
            ing("Shrimp", 1.25, "lb", "Protein"),
            ing("Tostada Shells", 8, "each", "Pantry"),
            ing("Orange", 1, "each", "Produce"),
            ing("Lime", 2, "each", "Produce"),
            ing("Cabbage", 3, "cups", "Produce"),
            ing("Avocado", 2, "each", "Produce"),
            ing("Cilantro", 1, "cup", "Produce"),
            ing("Jalapeño", 1, "each", "Produce"),
            ing("Sour Cream", 1 / 2, "cup", "Dairy"),
            ing("Radish", 1, "bunch", "Produce"),
            ing("Garlic", 2, "cloves", "Produce"),
        ],
        "instructions": [
            "Season the shrimp with garlic, citrus zest, and a pinch of salt, then cook until pink.",
            "Toss the cabbage with lime, orange juice, and thinly sliced jalapeño.",
            "Spread a little sour cream on each tostada shell.",
            "Layer with cabbage, shrimp, avocado, cilantro, and radish.",
            "Serve immediately so the shells stay crisp.",
        ],
    },
}


def main() -> None:
    recipes = json.loads(SEED_PATH.read_text(encoding="utf-8"))
    recipes_by_id = {recipe["id"]: recipe for recipe in recipes}

    sample: list[dict] = []
    for recipe_id in SAMPLE_RECIPE_IDS:
        recipe = dict(recipes_by_id[recipe_id])
        enrich = ENRICHMENTS[recipe_id]

        prep = enrich["prepMinutes"]
        cook = enrich["cookMinutes"]
        total = prep + cook
        nutrition = enrich["nutritionPerServing"]

        recipe.update(
            {
                "subcategory": recipe.get("subcategoryTitle"),
                "description": enrich["description"],
                "servings": enrich["servings"],
                "prepMinutes": prep,
                "cookMinutes": cook,
                "totalMinutes": total,
                "caloriesPerServing": enrich["caloriesPerServing"],
                "nutritionPerServing": nutrition,
                "ingredients": enrich["ingredients"],
                "instructions": enrich["instructions"],
                "tags": enrich["tags"],
                "prepTimeMinutes": prep,
                "cookingTimeMinutes": cook,
                "totalTimeMinutes": total,
                "calories": enrich["caloriesPerServing"],
                "nutrition": nutrition,
            }
        )
        sample.append(recipe)

    OUTPUT_PATH.write_text(json.dumps(sample, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
