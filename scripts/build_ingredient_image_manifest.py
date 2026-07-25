#!/usr/bin/env python3
import json
import re
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
CATALOG_PATH = PROJECT_ROOT / "Flame_Fleur/Flame_Fleur/Resources/shopping_ingredients.seed.full.json"
MANIFEST_PATH = PROJECT_ROOT / "Flame_Fleur/Flame_Fleur/Resources/ImagePrompts/ingredient_image_manifest.json"

CATEGORY_TO_CART = {
    "bakery": "bakery",
    "dairy": "dairy_eggs",
    "pantry": "pantry",
    "produce": "produce",
    "protein": "meat_seafood",
    "frozen": "frozen",
    "beverages": "beverages",
    "household": "household",
    "other": "other",
}

CART_TO_FALLBACK = {
    "produce": "cart_category_produce",
    "dairy_eggs": "cart_category_dairy_eggs",
    "meat_seafood": "cart_category_meat_seafood",
    "pantry": "cart_category_pantry",
    "bakery": "cart_category_bakery",
    "frozen": "cart_category_frozen",
    "beverages": "cart_category_beverages",
    "household": "cart_category_household",
    "other": "cart_category_other",
}

HERB_KEYWORDS = {"basil", "cilantro", "dill", "mint", "oregano", "parsley", "rosemary", "sage", "thyme", "chives"}
SPICE_KEYWORDS = {"paprika", "pepper", "cinnamon", "coriander", "caraway", "chili powder", "cocoa powder", "baking powder", "cumin"}
LIQUID_KEYWORDS = {"oil", "sauce", "milk", "broth", "stock", "vinegar", "honey", "syrup", "water"}
SEAFOOD_KEYWORDS = {"salmon", "tuna", "shrimp", "cod", "tilapia", "halibut", "trout", "fish", "scallop", "prawn", "mussel", "clam", "crab"}
MEAT_KEYWORDS = {"chicken", "beef", "pork", "lamb", "turkey", "steak", "sausage"}
CHEESE_KEYWORDS = {"cheddar", "mozzarella", "parmesan", "ricotta", "feta", "goat cheese", "cream cheese", "cottage cheese", "cheese"}
BREAD_KEYWORDS = {"bread", "roll", "bagel", "bun", "loaf", "muffin", "croissant", "biscuit", "scone"}


def snake_case(value: str) -> str:
    slug = re.sub(r"[^a-zA-Z0-9]+", "_", value.strip().lower())
    return re.sub(r"_+", "_", slug).strip("_")


def prompt_subject(name: str, category: str) -> str:
    lowered = name.strip().lower()
    words = set(lowered.replace("-", " ").split())

    if category == "produce":
        if words & HERB_KEYWORDS:
            return f"fresh {lowered} bunch or sprigs on a neutral warm surface"
        if any(token in lowered for token in ["garlic", "onion", "shallot"]):
            return f"whole fresh {lowered} on a neutral warm surface"
        return f"fresh {lowered} ingredient on a neutral warm surface"

    if category == "dairy":
        if "yogurt" in lowered:
            return f"plain {lowered} in a small bowl or tub"
        if lowered == "butter":
            return "a stick or pats of butter on a small butter dish"
        if any(keyword in lowered for keyword in CHEESE_KEYWORDS):
            return f"a portion of {lowered} cheese on a small board"
        if any(token in lowered for token in ["milk", "cream"]):
            return f"a small glass bottle or jar of {lowered}"
        if "egg" in lowered:
            return f"fresh {lowered} on a neutral surface"
        return f"plain {lowered} ingredient on a small dish"

    if category == "pantry":
        if any(keyword in lowered for keyword in LIQUID_KEYWORDS):
            return f"a small glass bottle or jar of {lowered}"
        if any(keyword in lowered for keyword in SPICE_KEYWORDS):
            return f"a small ceramic bowl of {lowered}"
        if any(token in lowered for token in ["flour", "powder", "sugar"]):
            return f"a small ceramic bowl of {lowered}"
        if any(token in lowered for token in ["rice", "quinoa", "lentils", "beans", "bean", "oats", "oat", "seeds", "seed", "almonds", "almond", "nuts", "nut", "breadcrumbs", "chickpeas", "chickpea"]):
            return f"a small ceramic bowl of dry {lowered}"
        if any(token in lowered for token in ["pasta", "noodles", "noodle"]):
            return f"dry {lowered} arranged on a neutral surface"
        return f"a clean portion of {lowered} in a small bowl"

    if category == "bakery":
        if any(token in lowered for token in BREAD_KEYWORDS):
            return f"fresh {lowered} on a light bakery board"
        if any(token in lowered for token in ["tortilla", "pita", "wrap"]):
            return f"stacked {lowered} on a neutral surface"
        if any(token in lowered for token in ["dough", "pastry"]):
            return f"plain {lowered} rolled or folded on a light surface"
        return f"fresh {lowered} on a neutral bakery surface"

    if category == "protein":
        if any(token in lowered for token in SEAFOOD_KEYWORDS):
            return f"raw {lowered} fillet or pieces on a clean tray"
        if any(token in lowered for token in MEAT_KEYWORDS):
            return f"raw {lowered} cut on a clean board or tray"
        if any(token in lowered for token in ["tofu", "tempeh"]):
            return f"plain {lowered} blocks on a neutral surface"
        return f"plain {lowered} ingredient on a clean tray"

    if category == "beverages":
        return f"a clean bottle, can, or glass of {lowered}"

    if category == "household":
        return f"a clean pack or bottle of {lowered} on a neutral surface"

    if category == "frozen":
        return f"a clean portion of frozen {lowered} on a neutral surface"

    return f"a clear centered view of {lowered}"


def build_manifest() -> list[dict]:
    with CATALOG_PATH.open("r", encoding="utf-8") as handle:
        catalog = json.load(handle)

    manifest: list[dict] = []

    for item in catalog:
        original_category = snake_case(item["category"]) or "other"
        cart_category = CATEGORY_TO_CART.get(original_category, "other")
        fallback_category_image_name = CART_TO_FALLBACK[cart_category]
        item_id = snake_case(item["displayName"])
        existing_image_name = (item.get("imageName") or "").strip()
        image_name = existing_image_name if existing_image_name.startswith("ingredient_") else f"ingredient_{item_id}"

        manifest.append(
            {
                "id": item_id,
                "name": item["displayName"],
                "category": original_category,
                "cartCategory": cart_category,
                "imageName": image_name,
                "outputFilename": f"{image_name}.png",
                "promptSubject": prompt_subject(item["displayName"], original_category),
                "fallbackCategoryImageName": fallback_category_image_name,
                "status": "pending",
                "notes": "",
            }
        )

    return manifest


def main() -> int:
    manifest = build_manifest()
    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)

    with MANIFEST_PATH.open("w", encoding="utf-8") as handle:
        json.dump(manifest, handle, indent=2, ensure_ascii=False)
        handle.write("\n")

    print(f"Created {MANIFEST_PATH}")
    print(f"Entries: {len(manifest)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
