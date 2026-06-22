#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from fractions import Fraction
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SEED_PATH = ROOT / "Flame_Fleur" / "Flame_Fleur" / "Resources" / "recipes.seed.json"
OUTPUT_PATH = ROOT / "Flame_Fleur" / "Flame_Fleur" / "Resources" / "recipes.seed.enriched.full.json"


def normalize_name(value: str) -> str:
    return re.sub(r"\s+", " ", re.sub(r"[^a-z0-9]+", " ", value.strip().lower())).strip()


def slugify(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", normalize_name(value)).strip("_")


def display_name(value: str) -> str:
    return " ".join(part.capitalize() for part in normalize_name(value).split())


def format_quantity(quantity: float | int) -> str:
    value = float(quantity)
    if abs(value - round(value)) < 0.001:
        return str(int(round(value)))

    frac = Fraction(str(value)).limit_denominator(8)
    if abs(float(frac) - value) < 0.03:
        whole = frac.numerator // frac.denominator
        remainder = frac.numerator % frac.denominator
        if remainder == 0:
            return str(whole)
        if whole:
            return f"{whole} {remainder}/{frac.denominator}"
        return f"{remainder}/{frac.denominator}"

    return f"{value:.2f}".rstrip("0").rstrip(".")


def ing(name: str, quantity: float | int, unit: str, category: str, notes: str = "") -> dict:
    return {
        "name": display_name(name),
        "quantity": quantity,
        "unit": unit,
        "category": category,
        "notes": notes,
        "displayQuantity": f"{format_quantity(quantity)} {unit}".strip(),
    }


def unique_ingredients(items: list[dict]) -> list[dict]:
    seen: set[str] = set()
    deduped: list[dict] = []
    for item in items:
        key = normalize_name(item["name"])
        if key in seen:
            continue
        seen.add(key)
        deduped.append(item)
    return deduped


def add(items: list[dict], *new_items: dict) -> None:
    items.extend(new_items)


def recipe_index(recipe_id: str) -> int:
    try:
        return int(recipe_id.rsplit("-", 1)[-1])
    except ValueError:
        return 1


def choose(index: int, options: list[str]) -> str:
    return options[(max(index, 1) - 1) % len(options)]


def infer_family(title: str) -> str:
    t = normalize_name(title)
    if any(word in t for word in ["brownie", "cookie", "muffin", "cake", "pie", "tart", "bread", "roll", "puff", "galette", "scone", "biscuit", "danish", "loaf", "pita", "palmiers"]):
        if any(word in t for word in ["bread", "roll", "loaf", "pita"]):
            return "bread"
        if "brownie" in t:
            return "brownies"
        if "cookie" in t:
            return "cookies"
        if "muffin" in t:
            return "muffins"
        if any(word in t for word in ["pie", "tart", "galette"]):
            return "pies_tarts"
        if "cake" in t:
            return "cakes"
        if any(word in t for word in ["puff", "danish", "palmiers"]):
            return "pastries"
    if any(word in t for word in ["breakfast bake", "coffee cake", "egg bake", "savory bake"]):
        return "breakfast_bakes"
    if any(word in t for word in ["pasta", "linguine", "spaghetti", "noodle", "orzo", "japchae", "ramen", "udon", "soba"]):
        return "pasta"
    if "risotto" in t:
        return "risotto"
    if any(word in t for word in ["soup", "broth", "bisque"]):
        return "soup"
    if any(word in t for word in ["stew", "braise"]):
        return "stew"
    if any(word in t for word in ["salad", "lettuce cups"]):
        return "salad"
    if any(word in t for word in ["bowl", "bowls", "power bowl", "rice plate", "grain bowl", "meal prep"]):
        return "bowl"
    if any(word in t for word in ["tacos", "enchiladas", "tostadas", "chilaquiles", "quesadillas"]):
        return "tacos"
    if "curry" in t:
        return "curry"
    if "stir-fry" in t or "stir fry" in t or "fried rice" in t:
        return "stir_fry"
    if any(word in t for word in ["skillet", "sheet pan", "tray", "one-pan", "one pan"]):
        return "skillet"
    if "bake" in t:
        return "bake"
    if "roast" in t:
        return "roast"
    if "skewer" in t:
        return "skewers"
    if "toast" in t:
        return "toast"
    if any(word in t for word in ["wrap", "lettuce cups"]):
        return "wrap"
    if any(word in t for word in ["frittata", "omelet", "egg skillet", "egg white", "jammy egg", "egg-based"]):
        return "egg"
    if any(word in t for word in ["protein bowl", "protein power", "post-workout", "recovery", "low-carb", "high-protein", "meal prep"]):
        return "high_protein"
    if "plate" in t:
        return "plate"
    return "bowl"


def cuisine_from_subcategory(subcategory_id: str) -> str:
    slug = normalize_name(subcategory_id)
    if slug.startswith("world cuisine "):
        return slug.split("world cuisine ", 1)[1]
    return ""


def recipe_markers(title: str) -> list[str]:
    t = normalize_name(title)
    markers = []
    for key in [
        "lemon",
        "lime",
        "orange",
        "tomato",
        "basil",
        "mushroom",
        "garlic",
        "ginger",
        "sesame",
        "miso",
        "gochujang",
        "harissa",
        "chimichurri",
        "pesto",
        "coconut",
        "honey",
        "maple",
        "yogurt",
        "chocolate",
        "coffee",
        "apple",
        "berry",
        "spinach",
        "kale",
        "avocado",
        "cabbage",
        "cauliflower",
        "zucchini",
        "carrot",
        "potato",
        "pear",
        "citrus",
        "ricotta",
        "parmesan",
        "feta",
        "cotija",
        "mozzarella",
        "cream",
        "butter",
        "olive oil",
        "turmeric",
        "cumin",
        "paprika",
        "peanut",
        "almond",
        "pistachio",
        "tahini",
        "chickpea",
        "bean",
        "lentil",
        "tofu",
        "tempeh",
        "eggplant",
        "salmon",
        "shrimp",
        "cod",
        "fish",
        "haddock",
        "tilapia",
        "tuna",
        "scallop",
        "beef",
        "pork",
        "lamb",
        "turkey",
        "chicken",
        "egg",
        "rice",
        "quinoa",
        "orzo",
        "noodle",
        "pasta",
        "gnocchi",
        "bread",
        "tortilla",
        "pita",
    ]:
        if key in t:
            markers.append(key)
    return markers


CUISINE_PROFILES = {
    "italian": [
        ("Olive Oil", 2, "tbsp", "Pantry"),
        ("Garlic", 3, "cloves", "Produce"),
        ("Basil", 1, "cup", "Produce"),
        ("Parmesan", 1 / 2, "cup", "Dairy"),
    ],
    "mexican": [
        ("Onion", 1, "each", "Produce"),
        ("Garlic", 3, "cloves", "Produce"),
        ("Lime", 1, "each", "Produce"),
        ("Cilantro", 1, "cup", "Produce"),
        ("Cumin", 1, "tsp", "Pantry"),
        ("Chili Powder", 1, "tsp", "Pantry"),
    ],
    "korean": [
        ("Sesame Oil", 1, "tbsp", "Pantry"),
        ("Soy Sauce", 2, "tbsp", "Pantry"),
        ("Ginger", 1, "tbsp", "Produce"),
        ("Scallions", 4, "each", "Produce"),
        ("Sesame Seeds", 1, "tbsp", "Pantry"),
    ],
    "german": [
        ("Onion", 1, "each", "Produce"),
        ("Butter", 2, "tbsp", "Dairy"),
        ("Dijon Mustard", 1, "tbsp", "Pantry"),
        ("Parsley", 1 / 2, "cup", "Produce"),
        ("Caraway Seeds", 1, "tsp", "Pantry"),
    ],
    "japanese": [
        ("Miso", 2, "tbsp", "Pantry"),
        ("Soy Sauce", 2, "tbsp", "Pantry"),
        ("Ginger", 1, "tbsp", "Produce"),
        ("Scallions", 4, "each", "Produce"),
        ("Sesame Seeds", 1, "tbsp", "Pantry"),
    ],
    "thai": [
        ("Coconut Milk", 1, "can", "Pantry"),
        ("Thai Curry Paste", 2, "tbsp", "Pantry"),
        ("Lime", 1, "each", "Produce"),
        ("Basil", 1 / 2, "cup", "Produce"),
        ("Ginger", 1, "tbsp", "Produce"),
    ],
    "indian": [
        ("Ginger", 1, "tbsp", "Produce"),
        ("Garlic", 3, "cloves", "Produce"),
        ("Cumin", 1, "tsp", "Pantry"),
        ("Coriander", 1, "tsp", "Pantry"),
        ("Turmeric", 1, "tsp", "Pantry"),
        ("Greek Yogurt", 1 / 2, "cup", "Dairy"),
    ],
    "chinese": [
        ("Garlic", 3, "cloves", "Produce"),
        ("Ginger", 1, "tbsp", "Produce"),
        ("Soy Sauce", 2, "tbsp", "Pantry"),
        ("Sesame Oil", 1, "tbsp", "Pantry"),
        ("Scallions", 4, "each", "Produce"),
    ],
    "french": [
        ("Shallot", 1, "each", "Produce"),
        ("Butter", 2, "tbsp", "Dairy"),
        ("Thyme", 1, "tbsp", "Produce"),
        ("Dijon Mustard", 1, "tbsp", "Pantry"),
        ("Parsley", 1 / 2, "cup", "Produce"),
    ],
    "greek": [
        ("Olive Oil", 2, "tbsp", "Pantry"),
        ("Lemon", 1, "each", "Produce"),
        ("Oregano", 1, "tbsp", "Produce"),
        ("Feta", 4, "oz", "Dairy"),
        ("Cucumber", 1, "each", "Produce"),
        ("Tomatoes", 2, "cups", "Produce"),
    ],
    "spanish": [
        ("Olive Oil", 2, "tbsp", "Pantry"),
        ("Garlic", 3, "cloves", "Produce"),
        ("Smoked Paprika", 1, "tsp", "Pantry"),
        ("Parsley", 1 / 2, "cup", "Produce"),
        ("Saffron", 1, "pinch", "Pantry"),
    ],
    "middle eastern": [
        ("Tahini", 3, "tbsp", "Pantry"),
        ("Lemon", 1, "each", "Produce"),
        ("Cumin", 1, "tsp", "Pantry"),
        ("Parsley", 1, "cup", "Produce"),
        ("Garlic", 2, "cloves", "Produce"),
    ],
}


def cuisine_profile(cuisine: str) -> list[tuple[str, float | int, str, str]]:
    return CUISINE_PROFILES.get(cuisine, [
        ("Olive Oil", 2, "tbsp", "Pantry"),
        ("Garlic", 2, "cloves", "Produce"),
        ("Parsley", 1 / 2, "cup", "Produce"),
    ])


def title_flavor_additions(title: str) -> list[dict]:
    t = normalize_name(title)
    items: list[dict] = []

    flavor_map = [
        ("lemon", [ing("Lemon", 1, "each", "Produce")]),
        ("lime", [ing("Lime", 1, "each", "Produce")]),
        ("orange", [ing("Orange", 1, "each", "Produce")]),
        ("tomato", [ing("Cherry Tomatoes", 2, "cups", "Produce")]),
        ("basil", [ing("Basil", 1, "cup", "Produce")]),
        ("mushroom", [ing("Cremini Mushrooms", 8, "oz", "Produce")]),
        ("garlic", [ing("Garlic", 3, "cloves", "Produce")]),
        ("ginger", [ing("Ginger", 1, "tbsp", "Produce")]),
        ("sesame", [ing("Sesame Seeds", 1, "tbsp", "Pantry"), ing("Sesame Oil", 1, "tbsp", "Pantry")]),
        ("miso", [ing("Miso", 2, "tbsp", "Pantry")]),
        ("gochujang", [ing("Gochujang", 2, "tbsp", "Pantry")]),
        ("harissa", [ing("Harissa", 1, "tbsp", "Pantry")]),
        ("chimichurri", [ing("Parsley", 1, "cup", "Produce"), ing("Cilantro", 1 / 2, "cup", "Produce"), ing("Red Wine Vinegar", 1, "tbsp", "Pantry")]),
        ("pesto", [ing("Basil", 1, "cup", "Produce"), ing("Pine Nuts", 2, "tbsp", "Pantry"), ing("Parmesan", 1 / 3, "cup", "Dairy")]),
        ("coconut", [ing("Coconut Milk", 1, "can", "Pantry")]),
        ("honey", [ing("Honey", 2, "tbsp", "Pantry")]),
        ("maple", [ing("Maple Syrup", 2, "tbsp", "Pantry")]),
        ("yogurt", [ing("Greek Yogurt", 1, "cup", "Dairy")]),
        ("chocolate", [ing("Cocoa Powder", 3, "tbsp", "Pantry"), ing("Dark Chocolate", 3, "oz", "Pantry")]),
        ("coffee", [ing("Espresso Powder", 1, "tsp", "Pantry")]),
        ("apple", [ing("Apples", 2, "each", "Produce"), ing("Cinnamon", 1, "tsp", "Pantry")]),
        ("berry", [ing("Mixed Berries", 1, "cup", "Produce")]),
        ("spinach", [ing("Spinach", 4, "cups", "Produce")]),
        ("kale", [ing("Kale", 3, "cups", "Produce")]),
        ("avocado", [ing("Avocado", 1, "each", "Produce")]),
        ("cabbage", [ing("Cabbage", 3, "cups", "Produce")]),
        ("cauliflower", [ing("Cauliflower", 1, "head", "Produce")]),
        ("zucchini", [ing("Zucchini", 2, "each", "Produce")]),
        ("carrot", [ing("Carrots", 2, "each", "Produce")]),
        ("potato", [ing("Potatoes", 2, "each", "Produce")]),
        ("pear", [ing("Pear", 1, "each", "Produce")]),
        ("ricotta", [ing("Ricotta", 1, "cup", "Dairy")]),
        ("parmesan", [ing("Parmesan", 1 / 2, "cup", "Dairy")]),
        ("feta", [ing("Feta", 4, "oz", "Dairy")]),
        ("cotija", [ing("Cotija", 1 / 2, "cup", "Dairy")]),
        ("mozzarella", [ing("Mozzarella", 8, "oz", "Dairy")]),
        ("cream", [ing("Heavy Cream", 1 / 2, "cup", "Dairy")]),
        ("butter", [ing("Butter", 2, "tbsp", "Dairy")]),
        ("olive oil", [ing("Olive Oil", 2, "tbsp", "Pantry")]),
        ("turmeric", [ing("Turmeric", 1, "tsp", "Pantry")]),
        ("cumin", [ing("Cumin", 1, "tsp", "Pantry")]),
        ("paprika", [ing("Paprika", 1, "tsp", "Pantry")]),
        ("peanut", [ing("Peanuts", 2, "tbsp", "Pantry"), ing("Peanut Butter", 1, "tbsp", "Pantry")]),
        ("almond", [ing("Almonds", 2, "tbsp", "Pantry"), ing("Almond Flour", 1 / 4, "cup", "Pantry")]),
        ("pistachio", [ing("Pistachios", 2, "tbsp", "Pantry")]),
        ("tahini", [ing("Tahini", 2, "tbsp", "Pantry")]),
        ("chickpea", [ing("Chickpeas", 1, "can", "Pantry")]),
        ("bean", [ing("Beans", 1, "can", "Pantry")]),
        ("lentil", [ing("Lentils", 1, "cup", "Pantry")]),
        ("tofu", [ing("Tofu", 14, "oz", "Protein")]),
        ("tempeh", [ing("Tempeh", 8, "oz", "Protein")]),
        ("eggplant", [ing("Eggplant", 1, "large", "Produce")]),
    ]

    for key, bundle in flavor_map:
        if key in t:
            items.extend(bundle)

    if "rice" in t:
        items.append(ing("Rice", 1.5, "cups", "Pantry"))
    if "quinoa" in t:
        items.append(ing("Quinoa", 1, "cup", "Pantry"))
    if "orzo" in t:
        items.append(ing("Orzo", 1.5, "cups", "Pantry"))
    if "gnocchi" in t:
        items.append(ing("Potato Gnocchi", 20, "oz", "Pantry"))
    if "pasta" in t or "linguine" in t or "spaghetti" in t:
        items.append(ing("Pasta", 12, "oz", "Pantry"))
    if "bread" in t or "toast" in t or "roll" in t or "pita" in t:
        items.append(ing("Bread", 1, "loaf", "Bakery"))
    if "tortilla" in t or "tacos" in t or "enchilada" in t or "tostada" in t:
        items.append(ing("Corn Tortillas", 8, "each", "Bakery"))

    return items


def protein_from_group(recipe: dict, title_lower: str) -> list[dict]:
    group = recipe.get("categoryGroupID", "")
    sub = recipe.get("subcategoryID", "")
    index = recipe_index(recipe.get("id", ""))

    if group == "meat-seafood":
        if "shrimp" in title_lower or "shrimp" in sub:
            protein = [ing("Shrimp", 1.25, "lb", "Protein")]
        elif "salmon" in title_lower or "salmon" in sub:
            protein = [ing("Salmon", 1.25, "lb", "Protein")]
        elif "tuna" in title_lower or "tuna" in sub:
            protein = [ing("Tuna", 1.25, "lb", "Protein")]
        elif any(word in title_lower for word in ["cod", "haddock", "tilapia", "fish"]) or "fish" in sub:
            fish_name = choose(index, ["Cod", "Haddock", "Tilapia", "White Fish Fillets"])
            protein = [ing(fish_name, 1.25, "lb", "Protein")]
        elif "beef" in title_lower or "beef" in sub:
            protein = [ing(choose(index, ["Flank Steak", "Ground Beef", "Sirloin Steak"]), 1.25, "lb", "Protein")]
        elif "pork" in title_lower or "pork" in sub:
            protein = [ing(choose(index, ["Pork Tenderloin", "Pork Chops", "Ground Pork"]), 1.25, "lb", "Protein")]
        elif "lamb" in title_lower or "lamb" in sub:
            protein = [ing(choose(index, ["Lamb Chops", "Ground Lamb"]), 1.25, "lb", "Protein")]
        elif "turkey" in title_lower or "turkey" in sub:
            protein = [ing(choose(index, ["Ground Turkey", "Turkey Cutlets", "Turkey Breast"]), 1.25, "lb", "Protein")]
        else:
            protein = [ing("Sea Scallops", 1.25, "lb", "Protein")]
    elif group == "vegetarian":
        if "tofu" in sub or "tofu" in title_lower:
            protein = [ing("Tofu", 14, "oz", "Protein")]
        elif "tempeh" in sub or "tempeh" in title_lower:
            protein = [ing("Tempeh", 8, "oz", "Protein")]
        elif "beans-lentils" in sub or "lentil" in title_lower:
            protein = [ing(choose(index, ["Lentils", "Green Lentils", "Brown Lentils"]), 1.25, "cups", "Pantry")]
        elif "chickpeas" in sub or "chickpea" in title_lower:
            protein = [ing("Chickpeas", 2, "cups", "Pantry")]
        elif "mushrooms" in sub or "mushroom" in title_lower:
            protein = [ing(choose(index, ["Cremini Mushrooms", "Portobello Mushrooms", "Mixed Mushrooms"]), 12, "oz", "Produce")]
        elif "eggplant" in sub or "eggplant" in title_lower:
            protein = [ing("Eggplant", 1, "large", "Produce")]
        elif "cauliflower" in sub or "cauliflower" in title_lower:
            protein = [ing("Cauliflower", 1, "head", "Produce")]
        elif "leafy-greens" in sub or any(word in title_lower for word in ["spinach", "kale", "greens"]):
            protein = [ing(choose(index, ["Spinach", "Kale", "Mixed Greens"]), 4, "cups", "Produce")]
        else:
            protein = [ing("Chickpeas", 2, "cups", "Pantry")]
    elif group == "chicken":
        if "salad" in title_lower:
            protein = [ing("Chicken Breast", 1.25, "lb", "Protein")]
        elif "soup" in title_lower:
            protein = [ing("Shredded Chicken", 1.25, "lb", "Protein")]
        elif "skewer" in title_lower:
            protein = [ing("Chicken Breast", 1.25, "lb", "Protein")]
        elif "curry" in title_lower:
            protein = [ing("Chicken Thighs", 1.5, "lb", "Protein")]
        elif "pasta" in title_lower:
            protein = [ing("Chicken Breast", 1.25, "lb", "Protein")]
        elif "taco" in title_lower:
            protein = [ing("Shredded Chicken", 1.25, "lb", "Protein")]
        elif "bowl" in title_lower:
            protein = [ing("Chicken Breast", 1.25, "lb", "Protein")]
        elif "roast" in title_lower or "grilled" in title_lower:
            protein = [ing("Chicken Thighs", 1.5, "lb", "Protein")]
        else:
            protein = [ing("Chicken Breast", 1.25, "lb", "Protein")]
    elif group == "high-protein":
        if "yogurt" in sub:
            protein = [ing("Greek Yogurt", 1.5, "cups", "Dairy")]
        elif "egg-based" in sub:
            protein = [ing("Eggs", 6, "each", "Protein")]
        elif "seafood" in sub:
            protein = [ing(choose(index, ["Salmon", "Shrimp", "Cod"]), 1.25, "lb", "Protein")]
        elif "legume" in sub:
            protein = [ing(choose(index, ["Lentils", "Chickpeas", "Black Beans"]), 2, "cups", "Pantry")]
        elif "low-carb" in sub:
            protein = [ing(choose(index, ["Chicken Breast", "Salmon", "Turkey Breast", "Tofu"]), 1.25, "lb", "Protein")]
        elif "breakfast" in sub:
            protein = [ing(choose(index, ["Eggs", "Egg Whites", "Greek Yogurt"]), 6, "each", "Protein")]
        elif "lean-chicken" in sub:
            protein = [ing("Chicken Breast", 1.25, "lb", "Protein")]
        else:
            protein = [ing(choose(index, ["Chicken Breast", "Salmon", "Tofu", "Turkey Breast"]), 1.25, "lb", "Protein")]
    else:
        protein = []
    return protein


def family_core_ingredients(recipe: dict, family: str, title_lower: str) -> list[dict]:
    group = recipe.get("categoryGroupID", "")
    sub = recipe.get("subcategoryID", "")
    index = recipe_index(recipe.get("id", ""))
    cuisine = cuisine_from_subcategory(sub)
    items: list[dict] = []

    if family == "soup":
        add(items,
            ing("Onion", 1, "each", "Produce"),
            ing("Garlic", 3, "cloves", "Produce"),
            ing("Carrots", 2, "each", "Produce"),
            ing("Celery", 2, "stalks", "Produce"),
            ing("Stock", 5, "cups", "Pantry"),
        )
        if "beans" in title_lower or "bean" in title_lower:
            items.append(ing(choose(index, ["Cannellini Beans", "White Beans", "Black Beans"]), 2, "cups", "Pantry"))
        elif "lentil" in title_lower:
            items.append(ing(choose(index, ["Lentils", "Green Lentils", "Red Lentils"]), 1.5, "cups", "Pantry"))
        elif "mushroom" in title_lower:
            items.append(ing("Cremini Mushrooms", 8, "oz", "Produce"))
        else:
            items.append(ing("Potatoes", 2, "each", "Produce"))
        items.append(ing("Herbs", 1 / 2, "cup", "Produce"))
        items.append(ing("Lemon", 1, "each", "Produce"))
    elif family == "stew":
        add(items,
            ing("Onion", 1, "each", "Produce"),
            ing("Garlic", 3, "cloves", "Produce"),
            ing("Carrots", 2, "each", "Produce"),
            ing("Stock", 4, "cups", "Pantry"),
            ing("Tomatoes", 2, "cups", "Produce"),
        )
        if "white bean" in title_lower or "bean" in title_lower:
            items.append(ing("Cannellini Beans", 2, "cups", "Pantry"))
        elif "chickpea" in title_lower:
            items.append(ing("Chickpeas", 2, "cups", "Pantry"))
        else:
            items.append(ing("Potatoes", 2, "each", "Produce"))
        items.append(ing("Thyme", 1, "tbsp", "Produce"))
        items.append(ing("Olive Oil", 2, "tbsp", "Pantry"))
    elif family == "salad":
        add(items,
            ing(choose(index, ["Mixed Greens", "Baby Spinach", "Romaine Lettuce"]), 4, "cups", "Produce"),
            ing("Cucumber", 1, "each", "Produce"),
            ing("Tomatoes", 2, "cups", "Produce"),
            ing("Red Onion", 1 / 2, "each", "Produce"),
            ing("Olive Oil", 2, "tbsp", "Pantry"),
            ing("Lemon", 1, "each", "Produce"),
        )
        if "grain" in title_lower or "bowl" in title_lower:
            items.append(ing(choose(index, ["Quinoa", "Farro", "Brown Rice"]), 1, "cup", "Pantry"))
        else:
            items.append(ing(choose(index, ["Feta", "Parmesan", "Avocado"]), 4, "oz", "Dairy"))
    elif family == "bowl":
        add(items,
            ing(choose(index, ["Quinoa", "Brown Rice", "Jasmine Rice", "Farro"]), 1, "cup", "Pantry"),
            ing(choose(index, ["Baby Spinach", "Mixed Greens", "Shredded Cabbage"]), 3, "cups", "Produce"),
            ing("Cucumber", 1, "each", "Produce"),
            ing("Avocado", 1, "each", "Produce"),
            ing("Lime", 1, "each", "Produce"),
            ing("Olive Oil", 2, "tbsp", "Pantry"),
        )
        if "taco" in title_lower:
            items.append(ing("Black Beans", 1, "cup", "Pantry"))
        elif "power" in title_lower or "protein" in title_lower:
            items.append(ing("Chickpeas", 1, "cup", "Pantry"))
    elif family == "tacos":
        add(items,
            ing("Corn Tortillas", 8, "each", "Bakery"),
            ing("Shredded Cabbage", 3, "cups", "Produce"),
            ing("Lime", 1, "each", "Produce"),
            ing("Avocado", 1, "each", "Produce"),
            ing("Cilantro", 1, "cup", "Produce"),
            ing("Sour Cream", 1 / 2, "cup", "Dairy"),
            ing("Olive Oil", 1, "tbsp", "Pantry"),
        )
    elif family == "pasta":
        add(items,
            ing(choose(index, ["Spaghetti", "Linguine", "Pappardelle", "Fettuccine"]), 12, "oz", "Pantry"),
            ing("Garlic", 3, "cloves", "Produce"),
            ing("Onion", 1, "each", "Produce"),
            ing("Olive Oil", 2, "tbsp", "Pantry"),
            ing(choose(index, ["Parmesan", "Ricotta", "Mozzarella"]), 1 / 2, "cup", "Dairy"),
            ing(choose(index, ["Basil", "Parsley", "Thyme"]), 1 / 2, "cup", "Produce"),
        )
        if "cream" in title_lower:
            items.append(ing("Heavy Cream", 1 / 2, "cup", "Dairy"))
        if "tomato" in title_lower:
            items.append(ing("Tomatoes", 2, "cups", "Produce"))
        if "mushroom" in title_lower:
            items.append(ing("Cremini Mushrooms", 8, "oz", "Produce"))
    elif family == "risotto":
        add(items,
            ing("Arborio Rice", 1.5, "cups", "Pantry"),
            ing("Stock", 5, "cups", "Pantry"),
            ing("Shallot", 1, "each", "Produce"),
            ing("Garlic", 2, "cloves", "Produce"),
            ing("Butter", 2, "tbsp", "Dairy"),
            ing("Parmesan", 1 / 2, "cup", "Dairy"),
        )
        if "mushroom" in title_lower:
            items.append(ing("Cremini Mushrooms", 12, "oz", "Produce"))
        if "lemon" in title_lower:
            items.append(ing("Lemon", 1, "each", "Produce"))
        if "herb" in title_lower:
            items.append(ing("Thyme", 1, "tbsp", "Produce"))
    elif family == "curry":
        add(items,
            ing("Onion", 1, "each", "Produce"),
            ing("Garlic", 3, "cloves", "Produce"),
            ing("Ginger", 1, "tbsp", "Produce"),
            ing("Coconut Milk", 1, "can", "Pantry"),
            ing("Curry Paste", 2, "tbsp", "Pantry"),
            ing("Rice", 1.5, "cups", "Pantry"),
        )
        if "thai" in cuisine:
            items.append(ing("Basil", 1 / 2, "cup", "Produce"))
        if "indian" in cuisine:
            items.append(ing("Garam Masala", 1, "tsp", "Pantry"))
        if "korma" in title_lower:
            items.append(ing("Greek Yogurt", 1 / 2, "cup", "Dairy"))
    elif family == "stir_fry":
        add(items,
            ing(choose(index, ["Jasmine Rice", "Brown Rice", "Rice Noodles", "Soba Noodles"]), 1.5, "cups", "Pantry"),
            ing("Garlic", 3, "cloves", "Produce"),
            ing("Ginger", 1, "tbsp", "Produce"),
            ing("Scallions", 4, "each", "Produce"),
            ing("Soy Sauce", 2, "tbsp", "Pantry"),
            ing("Sesame Oil", 1, "tbsp", "Pantry"),
        )
        if "fried rice" in title_lower:
            items.append(ing("Eggs", 2, "each", "Protein"))
        if "noodle" in title_lower:
            items.append(ing("Snow Peas", 1, "cup", "Produce"))
    elif family == "skillet":
        add(items,
            ing("Onion", 1, "each", "Produce"),
            ing("Garlic", 3, "cloves", "Produce"),
            ing("Olive Oil", 2, "tbsp", "Pantry"),
            ing(choose(index, ["Potatoes", "Baby Potatoes", "Sweet Potatoes"]), 2, "cups", "Produce"),
            ing(choose(index, ["Parsley", "Thyme", "Rosemary"]), 1 / 2, "cup", "Produce"),
        )
        if "creamy" in title_lower:
            items.append(ing("Greek Yogurt", 1 / 2, "cup", "Dairy"))
    elif family == "bake":
        add(items,
            ing("Olive Oil", 2, "tbsp", "Pantry"),
            ing("Onion", 1, "each", "Produce"),
            ing("Garlic", 2, "cloves", "Produce"),
            ing(choose(index, ["Breadcrumbs", "Panko", "Crushed Crackers"]), 1, "cup", "Pantry"),
            ing(choose(index, ["Parmesan", "Mozzarella", "Feta"]), 1 / 2, "cup", "Dairy"),
            ing(choose(index, ["Parsley", "Basil", "Thyme"]), 1 / 2, "cup", "Produce"),
        )
    elif family == "roast":
        add(items,
            ing("Olive Oil", 2, "tbsp", "Pantry"),
            ing("Garlic", 3, "cloves", "Produce"),
            ing(choose(index, ["Potatoes", "Carrots", "Parsnips"]), 2, "cups", "Produce"),
            ing(choose(index, ["Rosemary", "Thyme", "Parsley"]), 1 / 2, "cup", "Produce"),
            ing("Lemon", 1, "each", "Produce"),
        )
    elif family == "skewers":
        add(items,
            ing("Olive Oil", 2, "tbsp", "Pantry"),
            ing("Garlic", 2, "cloves", "Produce"),
            ing("Lemon", 1, "each", "Produce"),
            ing(choose(index, ["Bell Peppers", "Zucchini", "Red Onion"]), 2, "cups", "Produce"),
            ing(choose(index, ["Parsley", "Cilantro", "Mint"]), 1 / 2, "cup", "Produce"),
        )
    elif family == "toast":
        add(items,
            ing(choose(index, ["Sourdough Bread", "Whole Grain Bread", "Rye Bread"]), 4, "slices", "Bakery"),
            ing("Olive Oil", 1, "tbsp", "Pantry"),
            ing("Garlic", 1, "clove", "Produce"),
            ing(choose(index, ["Tomatoes", "Avocado", "Mushrooms", "Ricotta"]), 1, "cup", "Produce"),
            ing(choose(index, ["Parsley", "Basil", "Dill"]), 1 / 4, "cup", "Produce"),
        )
    elif family == "wrap":
        add(items,
            ing(choose(index, ["Lettuce Leaves", "Tortillas", "Collard Greens"]), 8, "each", "Produce"),
            ing("Cucumber", 1, "each", "Produce"),
            ing("Carrots", 2, "each", "Produce"),
            ing("Lime", 1, "each", "Produce"),
            ing("Sesame Oil", 1, "tbsp", "Pantry"),
            ing("Soy Sauce", 2, "tbsp", "Pantry"),
        )
    elif family == "egg":
        add(items,
            ing("Eggs", 6, "each", "Protein"),
            ing(choose(index, ["Spinach", "Kale", "Mushrooms"]), 3, "cups", "Produce"),
            ing("Cheddar", 4, "oz", "Dairy"),
            ing("Olive Oil", 1, "tbsp", "Pantry"),
            ing("Bread", 2, "slices", "Bakery"),
        )
    elif family == "plate":
        add(items,
            ing("Olive Oil", 2, "tbsp", "Pantry"),
            ing("Lemon", 1, "each", "Produce"),
            ing(choose(index, ["Potatoes", "Rice", "Quinoa"]), 1.5, "cups", "Pantry"),
            ing(choose(index, ["Broccoli", "Green Beans", "Asparagus"]), 2, "cups", "Produce"),
            ing(choose(index, ["Parsley", "Thyme", "Dill"]), 1 / 2, "cup", "Produce"),
        )
    elif family == "high_protein":
        add(items,
            ing(choose(index, ["Quinoa", "Brown Rice", "Farro", "Cauliflower Rice"]), 1, "cup", "Pantry"),
            ing("Baby Spinach", 3, "cups", "Produce"),
            ing("Cucumber", 1, "each", "Produce"),
            ing("Avocado", 1, "each", "Produce"),
            ing("Greek Yogurt", 1 / 2, "cup", "Dairy"),
        )
    return items


def bakery_ingredients(recipe: dict, family: str, title_lower: str) -> list[dict]:
    index = recipe_index(recipe.get("id", ""))
    items: list[dict] = []

    if family == "bread":
        add(items,
            ing("Flour", 3, "cups", "Pantry"),
            ing("Yeast", 2, "tsp", "Pantry"),
            ing("Warm Water", 1.5, "cups", "Pantry"),
            ing("Salt", 2, "tsp", "Pantry"),
            ing("Olive Oil", 2, "tbsp", "Pantry"),
            ing("Seeds", 1 / 4, "cup", "Pantry"),
        )
    elif family == "cakes":
        add(items,
            ing("Flour", 2.5, "cups", "Pantry"),
            ing("Sugar", 1.25, "cups", "Pantry"),
            ing("Eggs", 3, "each", "Protein"),
            ing("Butter", 1 / 2, "cup", "Dairy"),
            ing("Milk", 1, "cup", "Dairy"),
            ing("Baking Powder", 2, "tsp", "Pantry"),
        )
    elif family == "pastries":
        add(items,
            ing("Puff Pastry", 1, "sheet", "Bakery"),
            ing("Egg", 1, "each", "Protein"),
            ing("Butter", 2, "tbsp", "Dairy"),
            ing("Sugar", 1 / 4, "cup", "Pantry"),
            ing(choose(index, ["Fruit Jam", "Spinach", "Cheddar", "Cream Cheese"]), 1, "cup", "Dairy"),
        )
    elif family == "cookies":
        add(items,
            ing("Flour", 2.25, "cups", "Pantry"),
            ing("Butter", 1, "cup", "Dairy"),
            ing("Brown Sugar", 1, "cup", "Pantry"),
            ing("Egg", 1, "each", "Protein"),
            ing(choose(index, ["Chocolate Chips", "Oats", "Nuts"]), 1.5, "cups", "Pantry"),
        )
    elif family == "muffins":
        add(items,
            ing("Flour", 2, "cups", "Pantry"),
            ing("Oats", 1, "cup", "Pantry"),
            ing("Eggs", 2, "each", "Protein"),
            ing("Greek Yogurt", 1, "cup", "Dairy"),
            ing(choose(index, ["Berries", "Bananas", "Apples"]), 1.5, "cups", "Produce"),
            ing("Baking Powder", 2, "tsp", "Pantry"),
        )
    elif family == "pies_tarts":
        add(items,
            ing("Pie Dough", 1, "sheet", "Bakery"),
            ing(choose(index, ["Apples", "Pears", "Berries"]), 3, "cups", "Produce"),
            ing("Sugar", 1 / 2, "cup", "Pantry"),
            ing("Butter", 2, "tbsp", "Dairy"),
            ing("Cinnamon", 1, "tsp", "Pantry"),
        )
    elif family == "brownies":
        add(items,
            ing("Flour", 1, "cup", "Pantry"),
            ing("Cocoa Powder", 1 / 2, "cup", "Pantry"),
            ing("Butter", 1 / 2, "cup", "Dairy"),
            ing("Sugar", 1.25, "cups", "Pantry"),
            ing("Eggs", 2, "each", "Protein"),
            ing("Dark Chocolate", 4, "oz", "Pantry"),
        )
    elif family == "breakfast_bakes":
        add(items,
            ing("Eggs", 6, "each", "Protein"),
            ing("Milk", 1, "cup", "Dairy"),
            ing(choose(index, ["Bread", "Potatoes", "Tortillas"]), 2, "cups", "Bakery"),
            ing(choose(index, ["Spinach", "Tomatoes", "Mushrooms"]), 2, "cups", "Produce"),
            ing("Cheddar", 4, "oz", "Dairy"),
        )
    elif family == "savory_bakes":
        add(items,
            ing("Puff Pastry", 1, "sheet", "Bakery"),
            ing("Egg", 1, "each", "Protein"),
            ing(choose(index, ["Spinach", "Mushrooms", "Caramelized Onions"]), 2, "cups", "Produce"),
            ing("Cheddar", 4, "oz", "Dairy"),
            ing("Butter", 2, "tbsp", "Dairy"),
        )

    if "apple" in title_lower:
        items.extend([ing("Apples", 2, "each", "Produce"), ing("Cinnamon", 1, "tsp", "Pantry")])
    if "berry" in title_lower:
        items.append(ing("Mixed Berries", 1, "cup", "Produce"))
    if "citrus" in title_lower or "orange" in title_lower:
        items.append(ing("Orange", 1, "each", "Produce"))
    if "chocolate" in title_lower:
        items.append(ing("Cocoa Powder", 3, "tbsp", "Pantry"))
    if "carrot" in title_lower:
        items.append(ing("Carrots", 2, "each", "Produce"))
    if "pistachio" in title_lower:
        items.append(ing("Pistachios", 1 / 2, "cup", "Pantry"))
    if "almond" in title_lower:
        items.append(ing("Almonds", 1 / 2, "cup", "Pantry"))
    if "vanilla" in title_lower:
        items.append(ing("Vanilla Extract", 1, "tsp", "Pantry"))
    if "espresso" in title_lower:
        items.append(ing("Espresso Powder", 1, "tsp", "Pantry"))

    return items


def build_ingredients(recipe: dict, family: str, cuisine: str) -> list[dict]:
    title_lower = normalize_name(recipe.get("title", ""))
    items: list[dict] = []
    group = recipe.get("categoryGroupID", "")

    if group == "world-cuisine":
        items.extend([ing(*spec) for spec in cuisine_profile(cuisine)])
    elif group == "meat-seafood":
        items.extend(protein_from_group(recipe, title_lower))
        items.extend([ing(*spec) for spec in cuisine_profile(cuisine or "mediterranean")][:3])
    elif group == "vegetarian":
        items.extend(protein_from_group(recipe, title_lower))
        items.extend([ing("Olive Oil", 2, "tbsp", "Pantry"), ing("Garlic", 2, "cloves", "Produce"), ing("Lemon", 1, "each", "Produce")])
    elif group == "chicken":
        items.extend(protein_from_group(recipe, title_lower))
        items.extend([ing("Olive Oil", 2, "tbsp", "Pantry"), ing("Garlic", 3, "cloves", "Produce"), ing("Onion", 1, "each", "Produce")])
    elif group == "high-protein":
        items.extend(protein_from_group(recipe, title_lower))
        items.extend([ing("Lemon", 1, "each", "Produce"), ing("Olive Oil", 1, "tbsp", "Pantry"), ing("Scallions", 3, "each", "Produce")])
    elif group == "bakery":
        items.extend(bakery_ingredients(recipe, family, title_lower))

    items.extend([ing(*spec) for spec in cuisine_profile(cuisine)])
    items.extend(title_flavor_additions(title_lower))
    items.extend(family_core_ingredients(recipe, family, title_lower))

    # Title-driven proteins should appear only once and should not blow past the desired range.
    items = unique_ingredients(items)
    if len(items) < 6:
        filler = [
            ing("Salt", 1, "tsp", "Pantry"),
            ing("Black Pepper", 1, "tsp", "Pantry"),
            ing("Olive Oil", 1, "tbsp", "Pantry"),
            ing("Fresh Herbs", 1 / 4, "cup", "Produce"),
            ing("Lemon", 1, "each", "Produce"),
        ]
        for item in filler:
            if normalize_name(item["name"]) not in {normalize_name(existing["name"]) for existing in items}:
                items.append(item)
            if len(items) >= 6:
                break

    return items[:12]


def build_instructions(recipe: dict, family: str, cuisine: str, ingredients: list[dict]) -> list[str]:
    title = recipe.get("title", "the dish")
    title_lower = normalize_name(title)
    main = ingredients[0]["name"] if ingredients else display_name(title)
    starch = next((item["name"] for item in ingredients if item["category"] in {"Pantry", "Bakery"} and any(key in normalize_name(item["name"]) for key in ["rice", "pasta", "bread", "tortilla", "quinoa", "gnocchi", "noodle", "orzo", "roll"])), None)
    greens = next((item["name"] for item in ingredients if any(key in normalize_name(item["name"]) for key in ["spinach", "kale", "greens", "cabbage"])), None)
    herb = next((item["name"] for item in ingredients if any(key in normalize_name(item["name"]) for key in ["basil", "parsley", "cilantro", "thyme", "dill", "mint", "oregano"])), None)

    if family in {"bread", "cakes", "cookies", "muffins", "pies_tarts", "brownies", "breakfast_bakes", "savory_bakes"}:
        return {
            "bread": [
                "Mix the dry ingredients, then stir in the wet ingredients until a shaggy dough forms.",
                "Knead or fold briefly, then let the dough rise until puffy.",
                "Shape the loaf or rolls, proof again, and brush the top with a little oil or milk.",
                "Bake until deeply golden, then cool before slicing.",
            ],
            "cakes": [
                "Whisk the dry ingredients together and cream the butter, sugar, and eggs until smooth.",
                "Fold in the remaining liquid ingredients, then pour the batter into a prepared pan.",
                "Bake until the center springs back and a tester comes out mostly clean.",
                "Cool completely before glazing or slicing for neat layers.",
            ],
            "cookies": [
                "Cream the butter and sugars, then beat in the egg and vanilla.",
                "Fold in the flour and mix-ins just until the dough comes together.",
                "Scoop onto a lined sheet pan and bake until the edges are set.",
                "Let the cookies cool briefly so they finish setting on the tray.",
            ],
            "muffins": [
                "Whisk the dry ingredients together in one bowl and the wet ingredients in another.",
                "Fold the wet and dry mixtures together until just combined, then add fruit or oats.",
                "Divide the batter into muffin cups and top with a little extra texture if desired.",
                "Bake until risen and lightly browned, then cool on a rack.",
            ],
            "pies_tarts": [
                "Prepare the crust and layer in the fruit or filling.",
                "Stir together the sweetener and spices, then spoon the filling into the shell.",
                "Bake until the crust is golden and the filling has thickened.",
                "Cool before slicing so the filling holds its shape.",
            ],
            "brownies": [
                "Melt the butter and chocolate together, then whisk in sugar and eggs until glossy.",
                "Fold in cocoa and flour until the batter is just combined.",
                "Spread into a lined pan and bake until the center is set but still fudgy.",
                "Cool completely before cutting into squares.",
            ],
            "breakfast_bakes": [
                "Layer the bread, vegetables, and cheese in a baking dish.",
                "Whisk the eggs and milk, then pour the custard over the layers.",
                "Bake until the center is set and the top is golden.",
                "Rest a few minutes before serving warm.",
            ],
            "savory_bakes": [
                "Build the filling with vegetables, cheese, and herbs.",
                "Layer or fold the pastry around the filling so it stays sealed.",
                "Bake until the pastry is crisp and the filling is hot.",
                "Serve warm while the edges are still flaky.",
            ],
        }[family]

    if family == "soup":
        return [
            f"Sauté the aromatics for {title} until fragrant and softened.",
            "Stir in the spices, then add the stock, vegetables, and main protein or legumes.",
            "Simmer until the flavors meld and the starches or beans are tender.",
            "Finish with herbs, citrus, and a final seasoning check before serving.",
        ]
    if family == "stew":
        return [
            f"Brown the aromatics and build the flavor base for {title}.",
            "Add the main ingredients, tomatoes, and stock, then bring everything to a gentle simmer.",
            "Cook until the vegetables are tender and the broth has thickened slightly.",
            "Stir in herbs and finish with acid or yogurt for balance.",
        ]
    if family == "salad":
        return [
            f"Whisk the dressing together and prep the vegetables for {title}.",
            "Toss the greens, crunchy vegetables, and main protein or grain in a large bowl.",
            "Add the dressing gradually so everything is lightly coated.",
            "Finish with herbs, cheese, or seeds just before serving.",
        ]
    if family == "bowl":
        return [
            "Cook the grain or starch until tender and keep it warm.",
            "Prepare the vegetables and main protein while the base cooks.",
            "Layer the bowl with the grain, greens, vegetables, and protein.",
            "Drizzle with sauce or dressing and finish with herbs or seeds.",
        ]
    if family == "tacos":
        return [
            "Cook the filling with spices until it is deeply seasoned and tender.",
            "Warm the tortillas and prepare the toppings while the filling finishes.",
            "Assemble the tacos with a little sauce, slaw, and avocado or cheese.",
            "Serve immediately with lime wedges on the side.",
        ]
    if family == "pasta":
        return [
            "Cook the pasta until al dente and reserve a little pasta water.",
            "Sauté the aromatics and build the sauce in a wide skillet.",
            "Add the pasta and toss with the sauce until glossy and coated.",
            "Finish with cheese, herbs, and a final splash of pasta water if needed.",
        ]
    if family == "risotto":
        return [
            "Warm the stock and keep it at a gentle simmer.",
            "Sauté the onion, garlic, and mushrooms or vegetables until fragrant.",
            "Toast the rice, add liquid gradually, and stir until creamy.",
            "Finish with butter, cheese, and herbs before serving immediately.",
        ]
    if family == "curry":
        return [
            "Bloom the curry paste and aromatics in a little oil.",
            "Add the coconut milk, protein, and vegetables, then simmer gently.",
            "Cook until the vegetables are tender and the sauce has thickened.",
            "Finish with lime, herbs, and serve over warm rice.",
        ]
    if family == "stir_fry":
        return [
            "Cook the rice or noodles and set them aside.",
            "Stir-fry the protein with garlic and ginger until just cooked through.",
            "Add the vegetables and sauce, then toss until everything is glossy.",
            "Fold the noodles or rice back in and finish with scallions or sesame seeds.",
        ]
    if family == "skillet":
        return [
            "Brown the protein or vegetables in a large skillet until they pick up color.",
            "Add the aromatics and supporting vegetables, then cook until tender.",
            "Stir in the sauce or a splash of stock to loosen the pan juices.",
            "Finish with herbs or citrus and serve hot from the pan.",
        ]
    if family == "bake":
        return [
            "Prep the baking dish and layer the main ingredients with sauce or cheese.",
            "Add breadcrumbs or a crisp topping for texture.",
            "Bake until the center is hot and the top is browned.",
            "Let it rest briefly so the layers set before serving.",
        ]
    if family == "roast":
        return [
            "Season the protein and vegetables, then arrange them on a sheet pan.",
            "Roast until the vegetables are tender and the protein is cooked through.",
            "Toss with herbs and citrus while still warm.",
            "Plate with the starchy side or greens and serve immediately.",
        ]
    if family == "skewers":
        return [
            "Marinate the protein and vegetables while the grill or broiler heats.",
            "Thread everything onto skewers and cook until charred in spots.",
            "Turn occasionally so the kebabs cook evenly.",
            "Serve with the grain, salad, or sauce on the side.",
        ]
    if family == "toast":
        return [
            "Toast the bread until crisp at the edges.",
            "Prepare the spread or topping so it is ready to assemble.",
            "Layer the toppings and season with herbs or citrus.",
            "Finish with olive oil or flaky salt and serve right away.",
        ]
    if family == "wrap":
        return [
            "Prep the vegetables and sauce while the filling warms.",
            "Arrange the filling in the lettuce leaves or wraps.",
            "Roll or fold tightly so the filling stays in place.",
            "Serve with extra sauce, lime, or herbs on the side.",
        ]
    if family == "egg":
        return [
            "Cook the vegetables until softened, then add the eggs or egg whites.",
            "Fold in cheese or greens and cook until just set.",
            "Toast the bread or prepare the plate while the eggs finish.",
            "Season with herbs and black pepper before serving.",
        ]
    if family == "plate":
        return [
            "Cook the starch or potatoes until tender and season well.",
            "Prepare the main protein and vegetables using the same pan if possible.",
            "Arrange everything on a warm plate for a composed presentation.",
            "Finish with herbs, lemon, or a spoonful of sauce.",
        ]
    if family == "high_protein":
        return [
            "Cook the grain or low-carb base until ready to serve.",
            "Prepare the protein and vegetables in separate pans so the textures stay distinct.",
            "Build the bowl with the base, vegetables, and protein.",
            "Add yogurt, citrus, or herbs to finish with brightness.",
        ]

    return [
        "Prep the ingredients and heat the oven or skillet as needed.",
        "Cook the aromatics and main ingredients until the dish is well seasoned.",
        "Bring the remaining components together and cook until finished.",
        "Taste and adjust before serving warm.",
    ]


def nutrition_for(recipe: dict, family: str, ingredients: list[dict]) -> dict:
    title_lower = normalize_name(recipe.get("title", ""))
    base = {
        "soup": (390, 18, 44, 14, 8, 7, 700),
        "stew": (430, 20, 38, 16, 8, 6, 720),
        "salad": (420, 24, 24, 22, 7, 7, 540),
        "bowl": (520, 28, 54, 20, 8, 8, 680),
        "tacos": (490, 25, 50, 18, 7, 6, 650),
        "pasta": (560, 22, 66, 20, 5, 7, 760),
        "risotto": (500, 16, 62, 18, 4, 6, 690),
        "curry": (540, 24, 50, 24, 6, 8, 760),
        "stir_fry": (500, 28, 52, 18, 6, 7, 700),
        "skillet": (520, 28, 34, 28, 6, 5, 710),
        "bake": (560, 26, 38, 32, 6, 6, 820),
        "roast": (530, 30, 32, 28, 6, 5, 720),
        "skewers": (470, 30, 30, 22, 4, 5, 650),
        "toast": (360, 14, 42, 14, 5, 5, 460),
        "wrap": (400, 22, 24, 18, 7, 6, 560),
        "egg": (410, 26, 16, 26, 4, 4, 540),
        "plate": (500, 28, 42, 20, 6, 5, 640),
        "high_protein": (460, 34, 32, 18, 7, 6, 560),
        "bread": (290, 9, 54, 6, 3, 5, 420),
        "cakes": (360, 5, 48, 17, 2, 27, 300),
        "pastries": (340, 6, 33, 21, 2, 10, 320),
        "cookies": (250, 4, 30, 12, 2, 18, 180),
        "muffins": (280, 6, 36, 11, 3, 14, 220),
        "pies_tarts": (310, 4, 40, 15, 3, 18, 260),
        "brownies": (330, 5, 40, 16, 3, 24, 240),
        "breakfast_bakes": (380, 20, 20, 22, 4, 6, 560),
        "savory_bakes": (420, 19, 24, 24, 4, 6, 590),
    }.get(family, (480, 22, 42, 20, 6, 7, 620))

    calories, protein, carbs, fat, fiber, sugar, sodium = base

    if any(token in title_lower for token in ["salmon", "shrimp", "cod", "fish", "haddock", "tilapia", "tuna", "scallop"]):
        calories += 60
        protein += 8
        fat += 3
    if any(token in title_lower for token in ["chicken", "turkey", "beef", "pork", "lamb"]):
        calories += 80
        protein += 10
        fat += 4
    if any(token in title_lower for token in ["tofu", "tempeh", "lentil", "bean", "chickpea"]):
        protein += 4
        fiber += 2
    if "yogurt" in title_lower:
        protein += 4
    if any(token in title_lower for token in ["berry", "apple", "orange", "citrus"]):
        sugar += 2
    if "chocolate" in title_lower:
        sugar += 6
        calories += 40
    if "curry" in title_lower or "tacos" in title_lower or "bake" in title_lower:
        sodium += 40
    if family in {"bread", "cookies", "muffins", "cakes", "brownies", "pies_tarts"}:
        carbs += 8
    if family in {"salad", "bowl"}:
        fiber += 1

    return {
        "calories": int(round(calories)),
        "proteinGrams": int(round(protein)),
        "carbsGrams": int(round(carbs)),
        "fatGrams": int(round(fat)),
        "fiberGrams": int(round(fiber)),
        "sugarGrams": int(round(sugar)),
        "sodiumMilligrams": int(round(sodium)),
    }


def servings_for(recipe: dict, family: str) -> int:
    group = recipe.get("categoryGroupID", "")
    if family in {"bread", "cakes", "cookies", "muffins", "pies_tarts", "brownies"}:
        return 8
    if family in {"breakfast_bakes", "savory_bakes"}:
        return 6
    if group == "high-protein":
        return 4
    if family in {"soup", "stew", "bowl", "salad", "pasta", "risotto", "curry", "stir_fry", "skillet", "bake", "roast", "wrap", "plate", "tacos", "skewers", "egg"}:
        return 4
    return 4


def times_for(recipe: dict, family: str) -> tuple[int, int]:
    title_lower = normalize_name(recipe.get("title", ""))
    if family == "bread":
        return 25, 35
    if family == "cakes":
        return 20, 35
    if family == "cookies":
        return 15, 15
    if family == "muffins":
        return 15, 18
    if family == "pies_tarts":
        return 25, 35
    if family == "brownies":
        return 15, 28
    if family in {"breakfast_bakes", "savory_bakes"}:
        return 20, 35
    if family == "soup":
        return 15, 35
    if family == "stew":
        return 20, 40
    if family == "salad":
        return 18, 0
    if family == "bowl":
        return 20, 20
    if family == "tacos":
        return 20, 20
    if family == "pasta":
        return 15, 25
    if family == "risotto":
        return 20, 35
    if family == "curry":
        return 18, 28
    if family == "stir_fry":
        return 20, 15
    if family == "skillet":
        return 15, 20
    if family == "bake":
        return 25, 30
    if family == "roast":
        return 20, 35
    if family == "skewers":
        return 20, 15
    if family == "toast":
        return 10, 10
    if family == "wrap":
        return 15, 10
    if family == "egg":
        return 15, 10
    if family == "plate":
        return 20, 20
    if family == "high_protein":
        return 15, 20
    if "quick" in title_lower:
        return 10, 15
    return 15, 20


def description_for(recipe: dict, family: str, cuisine: str) -> str:
    title = recipe.get("title", "this recipe")
    cuisine_label = cuisine.replace("_", " ").replace("-", " ").strip()
    theme = {
        "bread": "baked with a crisp crust and a soft interior",
        "cakes": "finished with a tender crumb and a polished bake-shop feel",
        "cookies": "built for a chewy center and crisp edges",
        "muffins": "designed to bake up moist and evenly domed",
        "pies_tarts": "set up with a clean slice and a balanced fruit-forward filling",
        "brownies": "kept rich and fudgy in the center",
        "breakfast_bakes": "ideal for a cozy make-ahead brunch",
        "savory_bakes": "layered for a crisp, golden finish",
        "soup": "built on a soothing broth with plenty of texture",
        "stew": "slow-simmered until the broth tastes rounded and complete",
        "salad": "balanced with crunchy vegetables, a bright dressing, and a clean finish",
        "bowl": "arranged for a colorful, satisfying meal-prep style presentation",
        "tacos": "structured for a fast, lively meal with fresh toppings",
        "pasta": "finished glossy so every strand catches the sauce",
        "risotto": "made to feel creamy without losing its bite",
        "curry": "rich with aromatic spices and a silky sauce",
        "stir_fry": "kept fast, hot, and full of texture",
        "skillet": "built as a simple one-pan dinner with good browning",
        "bake": "bubbling and golden straight from the oven",
        "roast": "sheet-pan roasted for caramelized edges",
        "skewers": "balanced between char and tenderness",
        "toast": "elevated with a bright topping and crisp bread",
        "wrap": "easy to assemble and cleanly handheld",
        "egg": "anchored by protein and bright herbs for a quick meal",
        "plate": "composed for a polished, restaurant-style presentation",
        "high_protein": "structured to feel filling without getting heavy",
    }.get(family, "built for everyday cooking with a polished finish")
    return f"{title} is {theme} with {cuisine_label} flavor cues and a practical home-cook method."


def build_recipe(recipe: dict) -> dict:
    title_lower = normalize_name(recipe.get("title", ""))
    family = infer_family(recipe.get("title", ""))
    cuisine = cuisine_from_subcategory(recipe.get("subcategoryID", "")) or normalize_name(recipe.get("categoryGroupID", ""))
    ingredients = build_ingredients(recipe, family, cuisine)
    instructions = build_instructions(recipe, family, cuisine, ingredients)
    servings = servings_for(recipe, family)
    prep_minutes, cook_minutes = times_for(recipe, family)
    total_minutes = prep_minutes + cook_minutes
    nutrition = nutrition_for(recipe, family, ingredients)

    generated_tags = [
        normalize_name(recipe.get("categoryGroupID", "")).replace(" ", ""),
        family,
        cuisine.replace(" ", "") if cuisine else "",
    ]
    if "quick" in title_lower:
        generated_tags.append("quickDinner")
    if group := recipe.get("categoryGroupID", ""):
        if group == "high-protein":
            generated_tags.append("highProtein")
        if group == "vegetarian":
            generated_tags.append("vegetarian")
        if group == "chicken":
            generated_tags.append("chicken")
        if group == "meat-seafood":
            generated_tags.append("seafood")
        if group == "bakery":
            generated_tags.append("baking")

    base_tags = recipe.get("tags", []) or []
    tags: list[str] = []
    for tag in [*base_tags, *generated_tags]:
        if tag and tag not in tags:
            tags.append(tag)

    enriched = dict(recipe)
    enriched["subcategory"] = recipe.get("subcategoryTitle") or recipe.get("subcategoryID")
    enriched["description"] = description_for(recipe, family, cuisine)
    enriched["servings"] = servings
    enriched["prepMinutes"] = prep_minutes
    enriched["cookMinutes"] = cook_minutes
    enriched["totalMinutes"] = total_minutes
    enriched["prepTimeMinutes"] = prep_minutes
    enriched["cookingTimeMinutes"] = cook_minutes
    enriched["totalTimeMinutes"] = total_minutes
    enriched["caloriesPerServing"] = nutrition["calories"]
    enriched["calories"] = nutrition["calories"]
    enriched["nutritionPerServing"] = nutrition
    enriched["nutrition"] = nutrition
    enriched["ingredients"] = ingredients
    enriched["instructions"] = instructions
    enriched["tags"] = tags
    return enriched


def main() -> None:
    recipes = json.loads(SEED_PATH.read_text(encoding="utf-8"))
    enriched = [build_recipe(recipe) for recipe in recipes]
    OUTPUT_PATH.write_text(json.dumps(enriched, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
