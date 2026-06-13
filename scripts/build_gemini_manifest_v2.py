import json
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]

OUTPUT_PATH = PROJECT_ROOT / "Flame_Fleur/Flame_Fleur/Resources/ImagePrompts/gemini_asset_manifest_home_planner_subcategory_v2.json"

MASTER_STYLE = """
Create a hyperrealistic premium food photograph for a high-end cooking app.

Photography direction:
Use a 3/4 angle or 30–45 degree perspective view. Do not use a top-down view.
The image must show realistic depth, dimensionality, and perspective.
The food should feel like a real dish photographed for a premium cookbook or high-end culinary magazine.

Visual style:
hyperrealistic food photography, premium editorial cookbook photography, warm natural daylight, soft realistic shadows, vibrant but natural colors, refined plating, fresh ingredients, realistic textures, appetizing, elegant, luxurious but approachable.

Plate and surface styling:
Use visually interesting serving materials such as ceramic plates, matte stoneware bowls, textured neutral plates, rustic wooden boards, glazed bowls, or handmade pottery where appropriate.
The background must be light and clean, but not necessarily plain white. Use warm off-white, pale stone, light beige, soft cream, pale wood, or subtle light kitchen surfaces.
Keep the image colorful and appetizing while preserving a clean premium look.

Composition:
Square 1:1 image.
Centered main subject.
Enough breathing room around the dish so it works inside circular subcategory crops and recipe cards.
Food must remain recognizable at small mobile app size.
Minimal elegant props only.
No people, no hands, no packaging.

Strict constraints:
No text, no title, no letters, no logo, no watermark, no border.
No illustration, no cartoon, no digital painting, no 3D render, no collage.
No messy background, no dark background, no overhead view, no top-down flat lay.
""".strip()


def make_prompt(asset_type, category_group, subcategory, recipe_name, subject):
    return f"""
{MASTER_STYLE}

Asset type: {asset_type}
Category group: {category_group or "none"}
Subcategory: {subcategory or "none"}
Recipe name: {recipe_name or "none"}

Subject:
{subject}
""".strip()


groups = [
    {
        "id": "world_cuisine",
        "title": "World Cuisine",
        "subcategories": [
            ("italian", "Italian", "A vibrant Italian pasta dish served in a shallow ceramic bowl, with tomato sauce, fresh basil, parmesan shavings, and warm natural light."),
            ("mexican", "Mexican", "Colorful Mexican tacos on a rustic ceramic plate, with fresh salsa, lime, cilantro, avocado, and bright natural colors."),
            ("korean", "Korean", "A Korean-inspired rice bowl in a matte stoneware bowl, with vegetables, sesame, glazed protein, kimchi colors, and elegant plating."),
            ("german", "German", "A refined German-inspired plate with roasted potatoes, greens, and a rustic comforting main dish on a ceramic or wooden surface."),
            ("japanese", "Japanese", "A Japanese-inspired salmon sushi bowl or clean bento-style dish in a ceramic bowl, with rice, cucumber, avocado, sesame, and minimalist premium styling."),
            ("thai", "Thai", "A bright Thai-inspired curry or noodle dish in a colorful ceramic bowl, with herbs, lime, chili, and rich natural color."),
            ("indian", "Indian", "A refined Indian curry dish in a ceramic bowl with basmati rice, herbs, spices, warm golden sauce, and light textured background."),
            ("chinese", "Chinese", "A polished Chinese-inspired stir-fry or dumpling dish on a ceramic plate, with vegetables, sauce glaze, and warm natural light."),
            ("french", "French", "A refined French bistro-style plated dish with elegant sauce, herbs, vegetables, and premium restaurant-style presentation."),
            ("greek", "Greek", "A fresh Greek-inspired plate with salad, feta, olives, herbs, cucumber, tomatoes, and ceramic Mediterranean-style plating."),
            ("spanish", "Spanish", "A Spanish-inspired paella or tapas dish with saffron rice, seafood or vegetables, colorful garnish, and warm natural light."),
            ("middle_eastern", "Middle Eastern", "A Middle Eastern mezze plate on ceramic and wooden surfaces, with hummus, herbs, vegetables, pita, olives, and colorful premium styling."),
        ],
    },
    {
        "id": "meat_seafood",
        "title": "Meat & Seafood",
        "subcategories": [
            ("fish", "Fish", "A beautifully plated fish fillet on a ceramic plate, with lemon, herbs, vegetables, and premium angled food photography."),
            ("shrimp", "Shrimp", "Golden sautéed shrimp on a ceramic plate or shallow bowl, with herbs, lime, garlic, and colorful fresh garnish."),
            ("salmon", "Salmon", "A glossy salmon fillet served on a ceramic plate with vegetables, lemon, herbs, and warm natural light."),
            ("tuna", "Tuna", "A refined seared tuna plate with sesame crust, greens, sauce accents, and clean restaurant-style plating."),
            ("beef", "Beef", "A premium sliced beef steak dish on a ceramic plate or wooden board, with roasted vegetables and herbs."),
            ("pork", "Pork", "An elegant pork tenderloin or pork chop dish with vegetables, sauce, herbs, and light stone background."),
            ("lamb", "Lamb", "A refined lamb dish with roasted vegetables, herbs, and elegant ceramic plate presentation."),
            ("turkey", "Turkey", "A clean plated turkey dish with greens, grains, vegetables, and warm natural light."),
            ("shellfish", "Shellfish", "A premium shellfish plate with mussels or clams, herbs, lemon, sauce, and light coastal-style surface."),
        ],
    },
    {
        "id": "vegetarian",
        "title": "Vegetarian",
        "subcategories": [
            ("tofu_tempeh", "Tofu & Tempeh", "A colorful tofu and tempeh dish in a ceramic bowl, with crisp vegetables, sesame, herbs, and vibrant sauce."),
            ("beans_lentils", "Beans & Lentils", "A warm lentil and bean bowl in matte stoneware, with vegetables, herbs, olive oil, and premium rustic styling."),
            ("mushrooms", "Mushrooms", "A refined mushroom dish or mushroom risotto in a shallow ceramic bowl, with herbs and warm natural light."),
            ("eggplant", "Eggplant", "Roasted eggplant on a ceramic plate with sauce, herbs, pomegranate, and colorful premium Mediterranean styling."),
            ("cauliflower", "Cauliflower", "A beautifully roasted cauliflower dish with herbs, sauce, colorful garnish, and elegant plate presentation."),
            ("chickpeas", "Chickpeas", "A vibrant chickpea bowl with vegetables, herbs, tahini, colorful garnish, and ceramic bowl presentation."),
            ("leafy_greens", "Leafy Greens", "A fresh leafy greens salad in a ceramic bowl, with avocado, seeds, herbs, and colorful vegetables."),
            ("root_vegetables", "Root Vegetables", "Roasted root vegetables on a ceramic plate or wooden board, with herbs, olive oil, and warm natural colors."),
            ("plant_based_bowls", "Plant-Based Bowls", "A colorful plant-based bowl with grains, vegetables, avocado, legumes, herbs, and premium stoneware bowl styling."),
        ],
    },
    {
        "id": "chicken",
        "title": "Chicken",
        "subcategories": [
            ("grilled_chicken", "Grilled Chicken", "Grilled chicken breast on a ceramic plate with lemon, herbs, colorful vegetables, and angled premium photography."),
            ("roast_chicken", "Roast Chicken", "Golden roast chicken with herbs and vegetables on a ceramic platter or wooden board, warm natural daylight."),
            ("chicken_bowls", "Chicken Bowls", "A chicken grain bowl in matte stoneware with vegetables, avocado, herbs, and colorful premium styling."),
            ("chicken_pasta", "Chicken Pasta", "A refined chicken pasta dish in a ceramic bowl, with herbs, parmesan, sauce, and warm natural light."),
            ("chicken_soup", "Chicken Soup", "A warm chicken soup bowl in ceramic, with vegetables, herbs, golden broth, and light cozy background."),
            ("chicken_tacos", "Chicken Tacos", "Chicken tacos on a rustic ceramic plate, with fresh toppings, lime, cilantro, colorful salsa, and premium styling."),
            ("chicken_curry", "Chicken Curry", "A chicken curry bowl with rice, herbs, golden sauce, spices, and ceramic bowl presentation."),
            ("chicken_salad", "Chicken Salad", "A fresh chicken salad in a ceramic bowl, with greens, avocado, vegetables, herbs, and colorful ingredients."),
            ("chicken_skewers", "Chicken Skewers", "Grilled chicken skewers on a ceramic plate or wooden board, with vegetables, herbs, and warm natural light."),
        ],
    },
    {
        "id": "bakery",
        "title": "Bakery",
        "subcategories": [
            ("bread", "Bread", "Artisan bread on a light wooden board with a ceramic plate nearby, warm natural daylight, rustic premium bakery styling."),
            ("cakes", "Cakes", "A refined slice of cake on a ceramic dessert plate, with cream, fruit or garnish, and soft natural light."),
            ("pastries", "Pastries", "Golden croissants and pastries on a ceramic plate or wooden board, warm daylight, premium bakery styling."),
            ("cookies", "Cookies", "Premium cookies stacked on a ceramic plate, with warm natural light and soft beige background."),
            ("muffins", "Muffins", "Fresh muffins with golden tops on a ceramic plate or wooden board, colorful fruit accents and light background."),
            ("pies_tarts", "Pies & Tarts", "A refined fruit tart or pie slice on a ceramic plate, glossy fruit, warm light, and elegant bakery styling."),
            ("brownies", "Brownies", "Fudgy brownies cut into neat squares on a ceramic plate or wooden board, warm natural light, premium dessert styling."),
            ("breakfast_bakes", "Breakfast Bakes", "A warm breakfast bake with oats or fruit in ceramic bakeware, colorful garnish, and light kitchen surface."),
            ("savory_bakes", "Savory Bakes", "A savory tart or quiche on a ceramic plate, with herbs, vegetables, golden crust, and warm natural light."),
        ],
    },
    {
        "id": "high_protein",
        "title": "High Protein",
        "subcategories": [
            ("protein_bowls", "Protein Bowls", "A high-protein bowl in matte stoneware with grilled chicken, quinoa, avocado, colorful vegetables, and herbs."),
            ("lean_chicken", "Lean Chicken", "Lean grilled chicken with colorful vegetables on a ceramic plate, premium fitness-inspired plating."),
            ("egg_based_meals", "Egg-Based Meals", "An egg-based meal on a ceramic plate with eggs, greens, avocado, colorful garnish, and warm natural light."),
            ("greek_yogurt", "Greek Yogurt", "A Greek yogurt bowl in ceramic with berries, nuts, honey, granola, and colorful fresh styling."),
            ("seafood_protein", "Seafood Protein", "A high-protein seafood plate with fish or shrimp, greens, lemon, herbs, and premium angled photography."),
            ("legume_protein", "Legume Protein", "A legume protein bowl with lentils, chickpeas, vegetables, herbs, and matte ceramic bowl styling."),
            ("post_workout_meals", "Post-Workout Meals", "A balanced post-workout meal with lean protein, grains, colorful vegetables, and clean premium plating."),
            ("low_carb_protein", "Low-Carb Protein", "A low-carb high-protein plate with lean protein, greens, avocado, colorful garnish, and ceramic presentation."),
            ("high_protein_breakfast", "High-Protein Breakfast", "A high-protein breakfast plate with eggs, yogurt or lean protein, fruit, and colorful premium morning styling."),
        ],
    },
]

home_recipes = [
    ("world_cuisine", "italian", "spicy_tomato_basil_pasta", "Spicy Tomato Basil Pasta", "Spicy tomato basil pasta served in a shallow ceramic bowl, with rich red sauce, basil, parmesan shavings, and chili flakes."),
    ("meat_seafood", "fish", "honey_garlic_salmon", "Honey Garlic Salmon", "Honey garlic salmon on a ceramic plate with glossy golden glaze, herbs, lemon, vegetables, and colorful premium plating."),
    ("vegetarian", "mushrooms", "creamy_mushroom_risotto", "Creamy Mushroom Risotto", "Creamy mushroom risotto in a shallow ceramic bowl, with parmesan, herbs, sautéed mushrooms, and warm natural light."),
    ("high_protein", "protein_bowls", "grilled_chicken_quinoa_bowl", "Grilled Chicken Quinoa Bowl", "A grilled chicken quinoa bowl in matte stoneware with avocado, greens, roasted vegetables, herbs, and colorful ingredients."),
    ("bakery", "brownies", "fudgy_brownies", "Fudgy Brownies", "Fudgy chocolate brownies on a ceramic plate or wooden board, with rich texture and warm natural daylight."),
    ("world_cuisine", "mexican", "chicken_tacos", "Chicken Tacos", "Chicken tacos on a ceramic plate with fresh salsa, lime, cilantro, avocado, and colorful premium styling."),
    ("vegetarian", "plant_based_bowls", "rainbow_veggie_bowl", "Rainbow Veggie Bowl", "A colorful plant-based bowl in stoneware with grains, avocado, vegetables, legumes, herbs, and bright natural ingredients."),
    ("high_protein", "greek_yogurt", "greek_yogurt_berry_bowl", "Greek Yogurt Berry Bowl", "Greek yogurt bowl in ceramic with berries, granola, nuts, honey, and colorful premium breakfast styling."),
    ("meat_seafood", "shrimp", "garlic_lime_shrimp", "Garlic Lime Shrimp", "Garlic lime shrimp on a ceramic plate with herbs, lime, sauce glaze, and vibrant fresh garnish."),
    ("chicken", "chicken_salad", "herb_chicken_salad", "Herb Chicken Salad", "Herb chicken salad in a ceramic bowl with greens, avocado, colorful vegetables, and fresh herbs."),
    ("bakery", "muffins", "blueberry_oat_muffins", "Blueberry Oat Muffins", "Blueberry oat muffins on a ceramic plate or wooden board, golden tops, colorful blueberries, warm daylight."),
    ("world_cuisine", "japanese", "salmon_sushi_bowl", "Salmon Sushi Bowl", "A salmon sushi bowl in ceramic with rice, cucumber, avocado, sesame, colorful vegetables, and minimalist Japanese styling."),
]

planner_recipes = [
    ("high_protein", "protein_bowls", "grilled_chicken_quinoa_bowl", "Grilled Chicken Quinoa Bowl", "A grilled chicken quinoa bowl in matte stoneware with avocado, greens, roasted vegetables, herbs, and colorful premium styling."),
    ("world_cuisine", "italian", "spicy_tomato_basil_pasta", "Spicy Tomato Basil Pasta", "Spicy tomato basil pasta in a shallow ceramic bowl, with basil, parmesan, chili flakes, and rich red sauce."),
    ("vegetarian", "plant_based_bowls", "rainbow_veggie_bowl", "Rainbow Veggie Bowl", "A colorful plant-based bowl with grains, avocado, vegetables, legumes, herbs, and stoneware bowl presentation."),
    ("meat_seafood", "salmon", "lemon_herb_salmon", "Lemon Herb Salmon", "Lemon herb salmon on a ceramic plate with vegetables, herbs, lemon slices, and warm natural daylight."),
    ("chicken", "chicken_salad", "herb_chicken_salad", "Herb Chicken Salad", "A fresh chicken salad in a ceramic bowl with greens, avocado, colorful vegetables, herbs, and premium plating."),
    ("high_protein", "egg_based_meals", "avocado_egg_breakfast", "Avocado Egg Breakfast", "A high-protein avocado egg breakfast on a ceramic plate with greens, fruit accents, and colorful premium morning styling."),
]

manifest = []

for group in groups:
    for sub_id, sub_title, subject in group["subcategories"]:
        asset_name = f"ff_subcat_{group['id']}_{sub_id}"
        manifest.append({
            "asset_type": "subcategory",
            "screen_usage": ["Explore subcategory circles", "Category option screens"],
            "category_group_id": group["id"],
            "category_group_title": group["title"],
            "subcategory_id": sub_id,
            "subcategory_title": sub_title,
            "recipe_id": None,
            "recipe_title": None,
            "asset_name": asset_name,
            "filename": f"{asset_name}.png",
            "output_folder": "subcategories",
            "aspect_ratio": "1:1",
            "recommended_format": "PNG",
            "prompt": make_prompt("subcategory", group["title"], sub_title, None, subject),
        })

for group_id, sub_id, recipe_id, recipe_title, subject in home_recipes:
    group_title = next(g["title"] for g in groups if g["id"] == group_id)
    sub_title = next(s[1] for g in groups if g["id"] == group_id for s in g["subcategories"] if s[0] == sub_id)
    asset_name = f"ff_home_recipe_{group_id}_{sub_id}_{recipe_id}"
    manifest.append({
        "asset_type": "home_recipe",
        "screen_usage": ["Home featured carousel", "Home Top Picks", "Home Community", "Home AI Recommended"],
        "category_group_id": group_id,
        "category_group_title": group_title,
        "subcategory_id": sub_id,
        "subcategory_title": sub_title,
        "recipe_id": recipe_id,
        "recipe_title": recipe_title,
        "asset_name": asset_name,
        "filename": f"{asset_name}.png",
        "output_folder": "home_recipes",
        "aspect_ratio": "1:1",
        "recommended_format": "PNG",
        "prompt": make_prompt("home_recipe", group_title, sub_title, recipe_title, subject),
    })

for group_id, sub_id, recipe_id, recipe_title, subject in planner_recipes:
    group_title = next(g["title"] for g in groups if g["id"] == group_id)
    sub_title = next(s[1] for g in groups if g["id"] == group_id for s in g["subcategories"] if s[0] == sub_id)
    asset_name = f"ff_planner_recipe_{group_id}_{sub_id}_{recipe_id}"
    manifest.append({
        "asset_type": "planner_recipe",
        "screen_usage": ["Planner meal cards", "Planner suggestions"],
        "category_group_id": group_id,
        "category_group_title": group_title,
        "subcategory_id": sub_id,
        "subcategory_title": sub_title,
        "recipe_id": recipe_id,
        "recipe_title": recipe_title,
        "asset_name": asset_name,
        "filename": f"{asset_name}.png",
        "output_folder": "planner_recipes",
        "aspect_ratio": "1:1",
        "recommended_format": "PNG",
        "prompt": make_prompt("planner_recipe", group_title, sub_title, recipe_title, subject),
    })

OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)

with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
    json.dump(manifest, f, indent=2, ensure_ascii=False)

print(f"Created: {OUTPUT_PATH}")
print(f"Total assets: {len(manifest)}")
print(f"Subcategories: {sum(1 for item in manifest if item['asset_type'] == 'subcategory')}")
print(f"Home recipes: {sum(1 for item in manifest if item['asset_type'] == 'home_recipe')}")
print(f"Planner recipes: {sum(1 for item in manifest if item['asset_type'] == 'planner_recipe')}")
