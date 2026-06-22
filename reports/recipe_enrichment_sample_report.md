# Recipe Enrichment Sample Report

Validation passed: yes
Recipes enriched: 10
Unique sample ingredients: 65
Unique shopping ingredients: 65

## Recipe IDs
- recipe-seed-world-cuisine-italian-1
- recipe-seed-world-cuisine-italian-2
- recipe-seed-world-cuisine-italian-3
- recipe-seed-world-cuisine-italian-4
- recipe-seed-world-cuisine-italian-5
- recipe-seed-world-cuisine-italian-6
- recipe-seed-world-cuisine-mexican-1
- recipe-seed-world-cuisine-mexican-2
- recipe-seed-world-cuisine-mexican-3
- recipe-seed-world-cuisine-mexican-4

## Shopping ingredients
- Arborio Rice (`arborio rice`)
- Avocado (`avocado`)
- Basil (`basil`)
- Black Beans (`black beans`)
- Black Pepper (`black pepper`)
- Breadcrumbs (`breadcrumbs`)
- Butter (`butter`)
- Cabbage (`cabbage`)
- Cannellini Beans (`cannellini beans`)
- Carrots (`carrots`)
- Celery (`celery`)
- Cherry Tomatoes (`cherry tomatoes`)
- Chicken Thighs (`chicken thighs`)
- Chili Powder (`chili powder`)
- Chipotle In Adobo (`chipotle in adobo`)
- Cilantro (`cilantro`)
- Corn Kernels (`corn kernels`)
- Corn Tortillas (`corn tortillas`)
- Cotija (`cotija`)
- Cremini Mushrooms (`cremini mushrooms`)
- Crushed Red Pepper Flakes (`crushed red pepper flakes`)
- Cumin (`cumin`)
- Dry White Wine (`dry white wine`)
- Egg (`egg`)
- Eggplant (`eggplant`)
- Flour (`flour`)
- Fresh Basil (`fresh basil`)
- Fresh Sage (`fresh sage`)
- Fresh Thyme (`fresh thyme`)
- Garlic (`garlic`)
- Jalapeño (`jalapeño`)
- Kale (`kale`)
- Lemon (`lemon`)
- Lettuce (`lettuce`)
- Lime (`lime`)
- Linguine (`linguine`)
- Marinara Sauce (`marinara sauce`)
- Mexican Crema (`mexican crema`)
- Monterey Jack (`monterey jack`)
- Mozzarella (`mozzarella`)
- Olive Oil (`olive oil`)
- Onion (`onion`)
- Orange (`orange`)
- Parmesan (`parmesan`)
- Parmesan Rind (`parmesan rind`)
- Parsley (`parsley`)
- Poblano Peppers (`poblano peppers`)
- Potato Gnocchi (`potato gnocchi`)
- Radish (`radish`)
- Red Onion (`red onion`)
- Ricotta (`ricotta`)
- Rosemary (`rosemary`)
- Shallot (`shallot`)
- Shredded Chicken (`shredded chicken`)
- Shrimp (`shrimp`)
- Sour Cream (`sour cream`)
- Spaghetti (`spaghetti`)
- Spinach (`spinach`)
- Tomatillo Salsa (`tomatillo salsa`)
- Tomato Paste (`tomato paste`)
- Tomatoes (`tomatoes`)
- Tostada Shells (`tostada shells`)
- Vegetable Stock (`vegetable stock`)
- White Rice (`white rice`)
- White Wine (`white wine`)

## Next steps
- Review the sample recipe structure against the current Swift model.
- Promote the sample enrichment schema into a repeatable generator for the full 342-recipe batch.
- Decide how the Swift `Recipe` and shopping models should evolve to support structured ingredients and per-serving nutrition.

## Schema compatibility concerns
- Current Swift `Recipe.ingredients` is `[String]`, but the sample uses structured ingredient objects.
- Current Swift `Recipe` stores `prepTimeMinutes`, `cookingTimeMinutes`, `totalTimeMinutes`, `calories`, and `nutrition`; the enriched sample adds `prepMinutes`, `cookMinutes`, `totalMinutes`, `caloriesPerServing`, and `nutritionPerServing`.
- Current shopping item model has no `normalizedName` field; the catalog sample uses it for deduplication and matching.
