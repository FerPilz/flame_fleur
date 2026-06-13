import json
import re
from pathlib import Path

ROOT = Path("Flame_Fleur/Flame_Fleur")
RECIPES_PATH = ROOT / "Resources/recipes.seed.json"
OUT_PATH = ROOT / "Resources/GeneratedAssets/Gemini/image_generation_manifest_v2.json"

GLOBAL_PHOTO_STYLE = """
Create a realistic square food photograph for a premium recipe app.

The image must look like real food photography, not an AI-generated poster, illustration, or graphic icon. Show real food with natural imperfections, slightly asymmetrical plating, realistic textures, small irregular details, and warm natural light.

The food should be appetizing, colorful, fresh, and close to the camera, but not overly perfect, plastic, glossy, symmetrical, or staged.

Use a tight crop where the food fills most of the frame, while still looking like a natural photograph. The main food should stay near the center so it remains clear after the app applies a circular crop, but the photo itself must be a normal square image, not a circular icon.

Allow a small amount of natural plate edge, table texture, garnish, crumbs, sauce marks, or shadows so the image feels real and believable. Use realistic depth of field, natural shadows, and casual editorial food styling.

Strict exclusions:
No text. No typography. No titles. No labels. No watermarks. No logos. No circular border. No poster layout. No graphic design elements. No hands. No people. No packaging. No utensils dominating the image. No overly perfect plating. No artificial plastic-like textures. No fake-looking repeated patterns.
""".strip()

def slugify(value: str) -> str:
    value = value.lower().strip()
    value = re.sub(r"[^a-z0-9]+", "_", value)
    value = re.sub(r"_+", "_", value)
    return value.strip("_")

def recipe_prompt(recipe: dict) -> str:
    title = recipe.get("title", "recipe")
    subtitle = recipe.get("subtitle", "")
    subcategory = recipe.get("subcategoryTitle", "")
    ingredients = ", ".join(recipe.get("ingredients", [])[:8])

    return f"""
{GLOBAL_PHOTO_STYLE}

Dish:
{title}

Cuisine or category:
{subcategory}

Flavor direction:
{subtitle}

Key ingredients:
{ingredients}

Specific image direction:
Show the finished dish as a believable real meal, close to the camera, with natural food texture, uneven garnish, realistic browning, small imperfections, and warm appetizing color. The dish should look desirable and fresh without looking computer-perfect.
""".strip()

def subcategory_prompt(subcategory_title: str, category_group: str) -> str:
    return f"""
{GLOBAL_PHOTO_STYLE}

Category:
{subcategory_title}

Group:
{category_group}

Specific image direction:
Show a representative finished dish for this category. Make it close-up, colorful, warm, realistic, and appetizing. The dish should feel like a real photographed meal with natural imperfections, slight asymmetry, believable texture, and no graphic-design elements.
""".strip()

if not RECIPES_PATH.exists():
    raise FileNotFoundError(f"Could not find recipes seed file: {RECIPES_PATH}")

data = json.loads(RECIPES_PATH.read_text())

items = []

# Recipe images
for recipe in data:
    recipe_id = recipe.get("id")
    title = recipe.get("title")
    if not recipe_id or not title:
        continue

    asset_name = f"ff_recipe_{slugify(recipe_id)}"

    items.append({
        "type": "recipe",
        "id": recipe_id,
        "title": title,
        "asset_name": asset_name,
        "output_folder": "recipes",
        "prompt": recipe_prompt(recipe),
    })

# Subcategory images
seen_subcategories = {}

for recipe in data:
    sub_id = recipe.get("subcategoryID")
    sub_title = recipe.get("subcategoryTitle")
    category_group = recipe.get("categoryGroupID", "")

    if not sub_id or not sub_title:
        continue

    if sub_id not in seen_subcategories:
        asset_name = f"ff_subcat_{slugify(sub_id)}"

        seen_subcategories[sub_id] = {
            "type": "subcategory",
            "id": sub_id,
            "title": sub_title,
            "asset_name": asset_name,
            "output_folder": "subcategories",
            "prompt": subcategory_prompt(sub_title, category_group),
        }

items.extend(seen_subcategories.values())

OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
OUT_PATH.write_text(json.dumps(items, indent=2, ensure_ascii=False) + "\n")

print(f"Wrote {len(items)} image prompts to:")
print(OUT_PATH)
print()
print("Counts:")
print(" recipes:", sum(1 for i in items if i["type"] == "recipe"))
print(" subcategories:", sum(1 for i in items if i["type"] == "subcategory"))
