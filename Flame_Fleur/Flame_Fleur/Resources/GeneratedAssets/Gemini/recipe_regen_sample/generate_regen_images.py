#!/usr/bin/env python3
import argparse
import base64
import hashlib
import json
import os
import random
import re
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path
from urllib.parse import urlencode

PREFERRED_MODELS = [
    "gemini-3-pro-image",
    "gemini-3.1-flash-image",
    "gemini-3.1-flash-lite-image",
    "gemini-2.5-flash-image",
]

TITLE_KEYS = ["title", "name", "recipeName"]
ID_KEYS = ["id", "recipeID", "recipeId", "slug"]

IMAGE_KEYS = [
    "imageName",
    "imageAssetName",
    "assetName",
    "asset_name",
    "image",
    "image_code",
    "imageCode",
]

INGREDIENT_KEYS = ["ingredients", "recipeIngredients", "ingredientLines"]


def slugify(value):
    value = str(value or "").lower().strip()
    value = value.split("/")[-1]
    value = re.sub(r"\.(png|jpg|jpeg|webp)$", "", value, flags=re.I)
    value = re.sub(r"[^a-z0-9]+", "_", value)
    value = re.sub(r"_+", "_", value)
    return value.strip("_")


def api_key():
    key = os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")

    if not key or key.strip() in {"", "YOUR_KEY_HERE"}:
        raise SystemExit("ERROR: Set GEMINI_API_KEY first.")

    return key.strip().strip('"').strip("'")


def request_json(url, payload=None, headers=None, timeout=180):
    data = json.dumps(payload).encode("utf-8") if payload is not None else None
    req = urllib.request.Request(url, data=data, headers=headers or {})

    try:
        with urllib.request.urlopen(req, timeout=timeout) as response:
            return json.loads(response.read().decode("utf-8"))

    except urllib.error.HTTPError as error:
        print("HTTP error:", error.code, file=sys.stderr)
        print(error.read().decode("utf-8", errors="replace"), file=sys.stderr)
        raise


def list_models(key):
    url = "https://generativelanguage.googleapis.com/v1beta/models?" + urlencode(
        {"key": key}
    )
    data = request_json(url, timeout=30)
    return [model.get("name", "") for model in data.get("models", [])]


def choose_model(key, requested=None):
    if requested:
        return requested.replace("models/", "")

    available = {model.replace("models/", "") for model in list_models(key)}

    for model in PREFERRED_MODELS:
        if model in available:
            return model

    raise SystemExit(
        "ERROR: No preferred image model found. Run your Gemini model check script."
    )


def find_recipes_json(start: Path):
    candidates = [
        start / "../../../recipes.seed.json",
        start / "../recipes.seed.json",
        start / "recipes.seed.json",
        start / "Flame_Fleur/Flame_Fleur/Resources/recipes.seed.json",
        start / "Flame_Fleur/Resources/recipes.seed.json",
    ]

    for candidate in candidates:
        path = candidate.resolve()
        if path.exists():
            return path

    matches = list(start.rglob("recipes.seed.json"))
    if matches:
        return matches[0].resolve()

    raise SystemExit(
        "ERROR: Could not find recipes.seed.json. Pass --recipes path/to/recipes.seed.json"
    )


def load_recipes(path):
    with open(path, "r", encoding="utf-8") as file:
        payload = json.load(file)

    if isinstance(payload, list):
        return payload

    if isinstance(payload, dict):
        for key in ["recipes", "items", "data"]:
            if isinstance(payload.get(key), list):
                return payload[key]

    raise SystemExit("ERROR: Could not find recipe list in recipes JSON.")


def pick_first(dictionary, keys, default=None):
    for key in keys:
        if key in dictionary and dictionary[key]:
            return dictionary[key]

    return default


def normalize_ingredients(raw):
    if not raw:
        return []

    output = []

    for item in raw:
        if isinstance(item, str):
            output.append(item)

        elif isinstance(item, dict):
            name = item.get("name") or item.get("ingredient") or item.get("title")
            quantity = item.get("quantity") or item.get("amount") or ""
            unit = item.get("unit") or ""

            if name:
                output.append(
                    " ".join(str(part) for part in [quantity, unit, name] if part)
                )

    return output


def main_ingredients(raw, max_items=7):
    ignored = {
        "salt",
        "sea salt",
        "pepper",
        "black pepper",
        "water",
        "oil",
        "olive oil",
        "butter",
        "garlic powder",
        "onion powder",
        "paprika",
        "seasoning",
    }

    result = []
    seen = set()

    for ingredient in raw:
        cleaned = re.sub(r"^\s*[\d\/\.\-\s]+", "", ingredient).strip()
        cleaned = re.sub(
            r"\b(cups?|tbsp|tablespoons?|tsp|teaspoons?|grams?|g|kg|oz|ounces?|lb|pounds?|ml|l)\b",
            "",
            cleaned,
            flags=re.I,
        ).strip()

        lowered = cleaned.lower()

        if not lowered or lowered in ignored:
            continue

        if lowered not in seen:
            seen.add(lowered)
            result.append(cleaned)

        if len(result) >= max_items:
            break

    return result


def seeded_rng(recipe, title):
    seed_base = str(pick_first(recipe, ID_KEYS, title))
    seed = int(hashlib.md5(seed_base.encode("utf-8")).hexdigest()[:8], 16)
    return random.Random(seed)


def infer_category_subcategory(recipe, title, ingredients):
    text = " ".join(
        [
            title,
            " ".join(ingredients),
            json.dumps(recipe, ensure_ascii=False),
        ]
    ).lower()

    raw = pick_first(recipe, IMAGE_KEYS)
    raw_slug = slugify(raw) if raw else ""

    category = None
    subcategory = None

    if raw_slug:
        cleaned = raw_slug
        cleaned = cleaned.replace("ff_recipe_recipe_seed_", "")
        cleaned = cleaned.replace("ff_home_recipe_", "")
        cleaned = cleaned.replace("ff_subcat_", "")
        cleaned = cleaned.replace("ff_recipe_", "")

        parts = [part for part in cleaned.split("_") if part]

        if parts and parts[-1].isdigit():
            parts = parts[:-1]

        if len(parts) >= 3 and parts[0] == "world" and parts[1] == "cuisine":
            category = "world"
            subcategory = parts[2]

        elif len(parts) >= 3 and parts[0] == "meat" and parts[1] == "seafood":
            category = "meat_seafood"
            subcategory = parts[2]

        elif len(parts) >= 3 and parts[0] == "high" and parts[1] == "protein":
            category = "high_protein"
            subcategory = parts[2]

        elif len(parts) >= 4 and parts[0] == "plant" and parts[1] == "based":
            category = "vegetarian"
            subcategory = "plant_based_bowls"

        elif len(parts) >= 2:
            category = parts[0]
            subcategory = parts[1]

    inference_rules = [
        ("world", "mexican", ["mexican", "taco", "tacos", "enchilada", "chilaquiles", "quesadilla", "tostada", "poblano"]),
        ("world", "korean", ["korean", "bulgogi", "kimchi", "gochujang", "japchae"]),
        ("world", "italian", ["italian", "pasta", "risotto", "gnocchi", "ragu", "parmesan"]),
        ("world", "greek", ["greek", "souvlaki", "feta", "orzo", "pita", "mezze"]),
        ("world", "japanese", ["japanese", "onigiri", "miso", "sushi"]),
        ("world", "indian", ["indian", "dal", "curry"]),
        ("world", "chinese", ["chinese", "five spice", "five-spice"]),
        ("meat_seafood", "fish", ["salmon", "fish", "cod", "trout", "sea bass"]),
        ("meat_seafood", "tuna", ["tuna"]),
        ("meat_seafood", "shrimp", ["shrimp", "prawn"]),
        ("meat", "beef", ["beef", "steak", "short rib", "bulgogi"]),
        ("meat", "chicken", ["chicken"]),
        ("vegetarian", "mushrooms", ["mushroom", "portobello"]),
        ("vegetarian", "plant_based_bowls", ["plant based", "plant-based", "power bowl", "veggie bowl", "grain bowl", "quinoa bowl"]),
        ("vegetarian", "tofu_tempeh", ["tofu", "tempeh"]),
        ("vegetarian", "beans_lentils", ["bean", "beans", "lentil", "lentils", "chickpea", "chickpeas"]),
        ("vegetarian", "eggplant", ["eggplant"]),
        ("vegetarian", "cauliflower", ["cauliflower"]),
        ("vegetarian", "greens", ["kale", "spinach", "arugula", "chard", "collard"]),
        ("vegetarian", "root_vegetables", ["carrot", "beet", "parsnip", "sweet potato", "turnip", "root vegetable"]),
        ("chicken", "chicken_salad", ["chicken salad", "waldorf", "chicken chopped", "chicken slaw", "sesame chicken"]),
        ("bakery", "cookies", ["cookie", "cookies", "shortbread"]),
        ("bakery", "pies_tarts", ["pie", "tart", "galette"]),
        ("bakery", "brownies", ["brownie", "brownies"]),
        ("bakery", "breakfast_bakes", ["breakfast bake", "scones", "coffee cake", "casserole", "biscuit", "muffin", "muffins"]),
        ("breakfast", "eggs", ["egg", "eggs", "omelet", "omelette", "frittata", "shakshuka"]),
        ("breakfast", "toasts", ["toast", "french toast"]),
        ("snacks", "general", ["snack", "snacks"]),
        ("high_protein", "protein_bowls", ["protein", "lean beef", "protein bowl"]),
    ]

    for candidate_category, candidate_subcategory, keywords in inference_rules:
        if any(keyword in text for keyword in keywords):
            category = candidate_category
            subcategory = candidate_subcategory
            break

    category = category or "recipe"
    subcategory = subcategory or "general"

    return slugify(category), slugify(subcategory)


def recipe_asset_code(recipe, title, ingredients):
    category, subcategory = infer_category_subcategory(recipe, title, ingredients)
    title_slug = slugify(title)

    if not title_slug:
        title_slug = "untitled_recipe"

    return f"{category}_{subcategory}_{title_slug}"


def stable_output_filename(recipe, title, ingredients, used_names):
    base = recipe_asset_code(recipe, title, ingredients)

    candidate = base
    counter = 2

    while candidate in used_names:
        candidate = f"{base}_{counter}"
        counter += 1

    used_names.add(candidate)

    return f"{candidate}.png"


def infer_dish_profile(title, ingredients, recipe):
    text = " ".join(
        [title] + ingredients + [json.dumps(recipe, ensure_ascii=False)]
    ).lower()

    global_scene_options = [
        "on a modern light oak dining table with soft daylight",
        "on a white marble kitchen counter with subtle gray veining",
        "on a dark stone restaurant tabletop with warm ambient lighting",
        "on a matte concrete counter in a modern kitchen",
        "on a rustic reclaimed wood table near a window",
        "on a walnut restaurant table with soft background bokeh",
        "on a bright Scandinavian-style kitchen counter",
        "on a neutral linen-covered dining table",
        "on a black marble counter with elegant restaurant lighting",
        "on a cozy home kitchen island with blurred cabinets in the background",
        "on a terracotta-toned table surface with natural light",
        "on a minimal modern dining table with soft shadows",
        "on a warm cafe table with realistic background blur",
        "on a ceramic-tiled kitchen counter with natural daylight",
        "on a polished stone counter with restaurant-style plating light",
        "on a dark wood restaurant table with soft candle-like background warmth",
        "on a pale stone bistro table with natural reflections",
        "on a modern black dining table with directional window light",
        "on a farmhouse dining table with subtle linen and ceramic details",
        "on a brushed stainless kitchen prep surface with soft restaurant lighting",
    ]

    if any(word in text for word in ["soup", "bisque", "broth", "ramen", "pho"]):
        serving_options = [
            "a deep handmade ceramic soup bowl",
            "a rustic stoneware bowl on a small plate",
            "a wide shallow bowl with visible garnish",
            "a dark ceramic bowl with steam and rich broth texture",
            "a modern white bowl with a curved rim",
            "a speckled ceramic bowl suited for soup",
        ]

    elif any(word in text for word in ["curry", "stew", "chili"]):
        serving_options = [
            "a deep ceramic bowl",
            "a rustic serving bowl",
            "a cast iron pot",
            "a dark stoneware bowl with sauce texture visible",
            "a shallow stew bowl with garnish",
            "a small Dutch oven suitable for serving",
        ]

    elif any(word in text for word in ["pizza", "flatbread"]):
        serving_options = [
            "a rustic wooden pizza board",
            "a dark round serving board",
            "a lightly floured wooden peel",
            "a stoneware pizza plate",
            "a modern slate serving board",
            "a round ceramic pizza plate",
        ]

    elif any(word in text for word in ["cake", "tart", "pie", "galette", "cheesecake"]):
        serving_options = [
            "a decorative dessert plate",
            "a ceramic cake stand",
            "a simple elegant porcelain plate",
            "a rustic dessert plate with a small fork nearby",
            "a modern matte dessert plate",
            "a marble dessert board",
        ]

    elif any(word in text for word in ["cookie", "brownie", "bar", "muffin", "scone"]):
        serving_options = [
            "a parchment-lined tray",
            "a small ceramic dessert plate",
            "a rustic wooden board",
            "a matte stoneware plate",
            "a modern rectangular serving plate",
            "a bakery-style metal tray",
        ]

    elif any(word in text for word in ["pasta", "risotto", "gnocchi", "ragu"]):
        serving_options = [
            "a wide shallow pasta bowl",
            "a rustic ceramic dinner plate",
            "a matte stoneware bowl",
            "a white rimmed pasta plate",
            "a modern coupe bowl",
            "a dark restaurant-style pasta bowl",
        ]

    elif any(word in text for word in ["salad", "bowl", "grain bowl", "power bowl"]):
        serving_options = [
            "a shallow ceramic bowl",
            "a modern matte plate-bowl",
            "a wide stoneware bowl",
            "a natural ceramic serving bowl",
            "a glass bowl if appropriate",
            "a clean modern white bowl",
        ]

    elif any(word in text for word in ["taco", "tacos", "quesadilla", "burrito", "wrap", "tostada"]):
        serving_options = [
            "a rustic ceramic serving plate",
            "a wooden serving board",
            "a colorful casual plate",
            "a matte stoneware plate",
            "a modern oval plate",
            "a handmade ceramic platter",
        ]

    elif any(word in text for word in ["skillet", "frittata", "shakshuka"]):
        serving_options = [
            "a cast iron skillet",
            "a rustic saute pan",
            "a small serving pan on a wooden board",
            "a ceramic oven-safe pan",
            "a black steel skillet",
            "a shallow enamel pan",
        ]

    elif any(word in text for word in ["salmon", "fish", "sea bass", "cod", "trout", "tuna", "shrimp"]):
        serving_options = [
            "a ceramic dinner plate",
            "a rustic stoneware plate",
            "a lightly textured serving plate",
            "a shallow white plate with garnish",
            "a modern restaurant-style plate",
            "a dark ceramic seafood plate",
        ]

    elif any(word in text for word in ["pancake", "waffle", "omelet", "omelette", "egg", "breakfast"]):
        serving_options = [
            "a breakfast plate",
            "a ceramic plate",
            "a shallow breakfast bowl if appropriate",
            "a small cast iron pan if appropriate",
            "a modern brunch plate",
            "a speckled ceramic breakfast plate",
        ]

    else:
        serving_options = [
            "a ceramic dinner plate",
            "a rustic serving plate",
            "a simple elegant plate",
            "a matte stoneware bowl or plate suited to the dish",
            "a modern restaurant-style plate",
            "a shallow handmade ceramic bowl",
        ]

    return {
        "serving_options": serving_options,
        "scene_options": global_scene_options,
    }


def build_prompt_and_metadata(title, ingredients, recipe):
    profile = infer_dish_profile(title, ingredients, recipe)
    rng = seeded_rng(recipe, title)

    serving = rng.choice(profile["serving_options"])
    scene = rng.choice(profile["scene_options"])

    lens_options = [
        "shot with a 50mm professional food photography lens feel",
        "shot with a natural 70mm editorial food photography feel",
        "shot like a premium cookbook photograph with sharp food detail",
        "shot like a high-end restaurant menu photograph with crisp focus",
        "shot like a modern lifestyle food magazine photo with the dish in clear focus",
        "shot like a professional restaurant campaign image with close-up detail",
    ]

    lighting_options = [
        "strong soft key light focused directly on the dish from the front-left side",
        "bright diffused kitchen daylight focused on the food",
        "soft morning window light directed onto the dish",
        "warm restaurant key light highlighting the food clearly",
        "clean daylight with strong food highlights and realistic shadows",
        "soft directional studio-style light focused on the plated dish",
        "well-balanced bright food photography lighting with the dish as the brightest subject",
    ]

    background_style_options = [
        "modern kitchen background with very soft blur",
        "restaurant dining background with warm bokeh and no sharp distractions",
        "minimal marble counter background softly out of focus",
        "wooden table background with natural grain, secondary to the dish",
        "clean cafe-style table scene with background blur",
        "home kitchen island background with subtle blurred detail",
        "neutral linen and ceramic table styling, softly out of focus",
        "dark stone surface with elegant restaurant atmosphere and shallow depth of field",
        "bright Scandinavian kitchen setting with the background softly blurred",
        "rustic farmhouse table setting with minimal blurred props",
        "contemporary restaurant tabletop with subtle ambient depth",
        "marble and brass kitchen detail softly blurred in the background",
        "modern home dining scene with realistic but blurred everyday detail",
        "warm bistro-style background with natural blur",
        "clean editorial food styling without looking sterile",
    ]

    realism_options = [
        "include small natural imperfections in plating so it does not look artificial",
        "avoid overly perfect symmetry; make the food look naturally styled",
        "use realistic sauce texture, crumbs, herbs, steam, and surface imperfections where appropriate",
        "make it feel photographed in a real kitchen, dining space, or restaurant, not rendered on a blank AI set",
        "use believable shadows, reflections, and dishware contact with the table",
        "avoid generic AI-food perfection; keep the styling premium but believable",
        "avoid overly glossy fake surfaces; keep materials tactile and natural",
        "add subtle asymmetry and natural food texture where appropriate",
    ]

    prop_options = [
        "with one or two subtle props only, appropriate to the dish and blurred if in the background",
        "with restrained table styling and no clutter",
        "with a soft background object blur, such as a napkin, spoon, herbs, glass, or small plate",
        "with environmental detail that supports the dish but does not distract",
        "with dish-appropriate props, such as herbs, cutlery, folded linen, serving spoon, or small garnish bowl, kept secondary",
        "with minimal realistic styling, not a staged stock-photo setup",
        "with a single fork, spoon, napkin, or glass softly out of focus if appropriate",
        "with subtle table texture and believable real-world context",
    ]

    color_mood_options = [
        "natural warm tones",
        "clean modern neutral tones",
        "slightly moody restaurant tones with the food still brightly lit",
        "bright fresh daytime tones",
        "soft earthy tones",
        "premium editorial food photography tones",
        "warm home-cooked tones",
        "modern cool-neutral tones with appetizing food color",
    ]

    lens = rng.choice(lens_options)
    lighting = rng.choice(lighting_options)
    background_style = rng.choice(background_style_options)
    realism = rng.choice(realism_options)
    props = rng.choice(prop_options)
    color_mood = rng.choice(color_mood_options)

    ingredient_line = (
        ", ".join(ingredients)
        if ingredients
        else "the main visible ingredients of the dish"
    )

    prompt = f"""
Create a realistic cinematic food photograph of "{title}".

This is a normal finished recipe photo, not an exploded view.

Primary image goal:
- the dish must be the main subject and occupy most of the image
- the camera must focus sharply on the dish, not on the background
- the food should fill about 70 to 85 percent of the frame
- use a closer crop than a typical wide table scene
- the dish should feel close, appetizing, detailed, and premium
- the background should support the dish but stay secondary and softly blurred
- image should work beautifully as a mobile app card thumbnail with the dish instantly recognizable at small size

Serving and scene:
- present the dish in or on {serving}
- place it {scene}
- use {background_style}
- use {lighting}
- use {color_mood}
- {lens}
- {props}

Camera and focus:
- side view with a slightly elevated camera angle
- camera looking gently down toward the dish at about 25 to 40 degrees
- close-up or medium-close food photography framing
- sharp focus on the main dish and key ingredients
- shallow depth of field with the background softly blurred
- the plate, bowl, pan, or serving surface should be cropped close enough that the food feels prominent
- do not use a distant wide shot
- do not let the table, room, props, or background become the focus
- do not use a top-down or flat-lay view
- do not use a straight overhead view

Lighting and quality:
- strong, clean, appetizing light must fall directly on the dish
- the dish should be the brightest and clearest subject in the image
- high-definition, sharp, crisp food texture
- realistic highlights on sauces, vegetables, proteins, crusts, grains, and garnishes
- avoid blur on the food
- avoid low-resolution, soft, smeared, painterly, or plastic-looking textures
- avoid dark underexposed food

Food requirements:
- the finished cooked dish is the clear hero subject
- ingredients must be clearly identifiable
- visually emphasize these ingredients when appropriate: {ingredient_line}
- make the dish look realistic, appetizing, and suitable for a premium recipe app
- use dishware and environment that genuinely suit this specific dish
- respect the cultural style of the dish and use servingware, garnish, and plating that feel appropriate to that cuisine

Variation requirements:
- do not make recipes from the same category share the same background
- vary table materials between modern wood, marble, stone, linen, ceramic tile, dark restaurant table, cafe table, and home kitchen counter
- vary dishware color and shape naturally
- vary lighting mood naturally while keeping the food clear, sharp, and appetizing
- avoid repeating the same kitchen background across multiple images
- make this feel like one photo from a diverse premium recipe app library, not from a uniform AI batch

Anti-AI repetition rules:
- do not use a plain white background
- do not use the same generic kitchen background
- do not make the image look like a synthetic render
- do not make the plating too perfect or symmetrical
- avoid identical camera framing across dishes
- avoid excessive garnish, fake microgreens, unrealistic sauce dots, or overly decorative restaurant plating unless the dish naturally calls for it
- {realism}

Composition:
- single hero dish
- square-friendly composition
- close crop
- dish centered or slightly offset
- background secondary and softly blurred
- well illuminated, realistic shadows, believable texture
- no text
- no logo
- no collage
- no split image
- no exploded ingredients
- no hands
- no people
""".strip()

    metadata = {
        "serving": serving,
        "scene": scene,
        "background_style": background_style,
        "lighting": lighting,
        "lens": lens,
        "props": props,
        "color_mood": color_mood,
        "realism_rule": realism,
    }

    return prompt, metadata


def find_base64_images(obj):
    found = []

    def walk(value):
        if isinstance(value, dict):
            mime = str(value.get("mimeType") or value.get("mime_type") or "").lower()
            data = value.get("data")

            if isinstance(data, str) and ("image" in mime or len(data) > 1000):
                found.append(data)

            for child in value.values():
                walk(child)

        elif isinstance(value, list):
            for child in value:
                walk(child)

    walk(obj)

    return found


def generate_image(key, model, prompt):
    payload = {
        "model": model,
        "input": [
            {
                "type": "text",
                "text": prompt,
            }
        ],
    }

    headers = {
        "x-goog-api-key": key,
        "Content-Type": "application/json",
    }

    response = request_json(
        "https://generativelanguage.googleapis.com/v1beta/interactions",
        payload=payload,
        headers=headers,
        timeout=180,
    )

    images = find_base64_images(response)

    if not images:
        debug_path = Path("gemini_last_response_no_image.json")
        debug_path.write_text(json.dumps(response, indent=2), encoding="utf-8")
        raise RuntimeError(
            f"No base64 image found. Wrote debug response to {debug_path}"
        )

    return base64.b64decode(images[0])


def main():
    start = Path.cwd()

    parser = argparse.ArgumentParser(
        description="Generate realistic cinematic recipe images with varied scenes."
    )

    parser.add_argument(
        "--recipes",
        default=None,
        help="Path to recipes.seed.json",
    )

    parser.add_argument(
        "--output",
        default=".",
        help="Output directory. Default is current folder.",
    )

    parser.add_argument(
        "--model",
        default=None,
        help="Override Gemini image model.",
    )

    parser.add_argument(
        "--limit",
        type=int,
        default=10,
        help="Number of recipes to generate. Use 0 for all recipes.",
    )

    parser.add_argument(
        "--offset",
        type=int,
        default=0,
        help="Start index into the recipe list.",
    )

    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print prompts and filenames only.",
    )

    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite existing generated files.",
    )

    parser.add_argument(
        "--sleep",
        type=float,
        default=2.0,
        help="Seconds between generations.",
    )

    args = parser.parse_args()

    key = api_key()
    model = choose_model(key, args.model)

    recipes_path = (
        Path(args.recipes).resolve()
        if args.recipes
        else find_recipes_json(start)
    )

    output_dir = Path(args.output).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    recipes = load_recipes(recipes_path)

    if not recipes:
        raise SystemExit("ERROR: No recipes found in recipes JSON.")

    selected = recipes[args.offset:]

    if args.limit and args.limit > 0:
        selected = selected[: args.limit]

    used_names = set()

    print(f"Recipes JSON: {recipes_path}")
    print(f"Output: {output_dir}")
    print(f"Using model: {model}")
    print(f"Recipes to process: {len(selected)}")

    manifest = []

    for index, recipe in enumerate(selected, 1):
        title = str(pick_first(recipe, TITLE_KEYS, "Untitled Recipe"))

        ingredients = main_ingredients(
            normalize_ingredients(pick_first(recipe, INGREDIENT_KEYS, []))
        )

        category, subcategory = infer_category_subcategory(recipe, title, ingredients)
        filename = stable_output_filename(recipe, title, ingredients, used_names)
        output_path = output_dir / filename

        prompt, prompt_metadata = build_prompt_and_metadata(title, ingredients, recipe)

        print("")
        print(f"[{index}/{len(selected)}] {title}")
        print("Filename:", filename)
        print("Category:", category)
        print("Subcategory:", subcategory)
        print(
            "Ingredients:",
            ", ".join(ingredients) if ingredients else "(none detected)",
        )
        print("Scene:", prompt_metadata["scene"])
        print("Serving:", prompt_metadata["serving"])

        manifest_item = {
            "index": index,
            "title": title,
            "filename": filename,
            "category": category,
            "subcategory": subcategory,
            "ingredients": ingredients,
            "model": model,
            "output_path": str(output_path),
            "prompt_metadata": prompt_metadata,
            "prompt": prompt,
        }

        manifest.append(manifest_item)

        if args.dry_run:
            continue

        if output_path.exists() and not args.overwrite:
            print("Skipping existing file. Use --overwrite to regenerate.")
            manifest_item["status"] = "skipped_existing"
            continue

        image_bytes = generate_image(key, model, prompt)
        output_path.write_bytes(image_bytes)

        manifest_item["status"] = "saved"
        print("Saved:", output_path)

        time.sleep(args.sleep)

    manifest_path = output_dir / "recipe_regen_manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2), encoding="utf-8")

    print("")
    print("Manifest:", manifest_path)
    print("Done.")


if __name__ == "__main__":
    main()
