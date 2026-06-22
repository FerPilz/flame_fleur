#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FULL_RECIPES_PATH = ROOT / "Flame_Fleur" / "Flame_Fleur" / "Resources" / "recipes.seed.enriched.full.json"
OUTPUT_PATH = ROOT / "Flame_Fleur" / "Flame_Fleur" / "Resources" / "shopping_ingredients.seed.full.json"


def normalize_name(name: str) -> str:
    return re.sub(r"\s+", " ", re.sub(r"[^a-z0-9]+", " ", name.strip().lower())).strip()


def slugify(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", normalize_name(name)).strip("_")


def category_for(name: str, fallback: str = "") -> str:
    key = normalize_name(name)
    fallback = (fallback or "").strip().title()

    if fallback in {"Produce", "Pantry", "Protein", "Dairy", "Bakery"}:
        return fallback
    if any(token in key for token in ["chicken", "shrimp", "fish", "salmon", "beef", "pork", "lamb", "turkey", "egg", "tofu", "tempeh", "tuna", "cod", "haddock", "tilapia", "scallop"]):
        return "Protein"
    if any(token in key for token in ["milk", "yogurt", "cheese", "butter", "cream", "ricotta", "mozzarella", "parmesan", "cotija", "crema", "sour cream", "feta", "cheddar"]):
        return "Dairy"
    if any(token in key for token in ["bread", "tortilla", "rice", "pasta", "gnocchi", "flour", "breadcrumbs", "stock", "paste", "salsa", "adobo", "wine", "oil", "corn tortillas", "tostada", "beans", "bean", "cannellini", "black beans", "quinoa", "orzo", "noodle", "puff pastry", "pie dough", "yeast", "sugar", "oats", "cocoa", "chocolate"]):
        return "Pantry"
    if any(token in key for token in ["cake", "cookie", "muffin", "brownie", "pie", "tart", "pastry", "sourdough", "bagel", "roll", "loaf", "pita", "cornbread", "danish"]):
        return "Bakery"
    return "Produce"


def default_unit(category: str, name: str) -> str:
    key = normalize_name(name)
    if category == "Protein":
        if any(token in key for token in ["egg"]):
            return "each"
        return "lb"
    if category == "Dairy":
        return "oz"
    if any(token in key for token in ["stock", "salsa", "paste", "ricotta", "coconut milk", "broth", "cream"]):
        return "cup"
    if "tortilla" in key or "tostada" in key or "each" in key or "egg" in key:
        return "each"
    if category == "Bakery":
        return "item"
    if any(token in key for token in ["rice", "pasta", "gnocchi", "quinoa", "orzo", "oats", "beans", "lentils"]):
        return "cup"
    if any(token in key for token in ["oil", "vinegar", "juice", "honey", "maple", "sesame", "soy sauce"]):
        return "tbsp"
    return "each"


def estimated_price(category: str, name: str) -> float:
    base = {
        "Produce": 3.49,
        "Dairy": 3.29,
        "Protein": 8.49,
        "Pantry": 2.99,
        "Bakery": 4.49,
    }.get(category, 2.49)
    digest = hashlib.sha1(normalize_name(name).encode("utf-8")).hexdigest()
    offset = (int(digest[:4], 16) % 125) / 100.0
    return round(base + offset, 2)


def display_name(name: str) -> str:
    return " ".join(part.capitalize() for part in normalize_name(name).split())


def main() -> None:
    recipes = json.loads(FULL_RECIPES_PATH.read_text(encoding="utf-8"))

    seen: set[str] = set()
    catalog: list[dict] = []
    for recipe in recipes:
        for ingredient in recipe.get("ingredients", []):
            name = str(ingredient.get("name", "")).strip()
            if not name:
                continue
            normalized = normalize_name(name)
            if normalized in seen:
                continue
            seen.add(normalized)

            fallback_category = str(ingredient.get("category", ""))
            category = category_for(name, fallback_category)
            unit = ingredient.get("unit") or default_unit(category, name)

            catalog.append(
                {
                    "id": f"ingredient_{slugify(name)}",
                    "displayName": display_name(name),
                    "normalizedName": normalized,
                    "category": category,
                    "defaultUnit": unit,
                    "estimatedPrice": estimated_price(category, name),
                    "imageName": f"ingredient_{slugify(name)}",
                }
            )

    catalog.sort(key=lambda item: item["normalizedName"])
    OUTPUT_PATH.write_text(json.dumps(catalog, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
