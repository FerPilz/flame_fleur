# Recipe Data Audit

Seed file: `Flame_Fleur/Flame_Fleur/Resources/recipes.seed.json`

Total recipes: 342

## 1. Recipe file summary

- Top-level fields: calories, category, categoryGroupID, cookingTimeMinutes, creatorAvatarName, creatorName, description, difficulty, equipment, id, imageName, ingredients, instructions, isCommunityRecipe, isPremium, nutrition, prepTimeMinutes, sectionTags, servings, subcategoryID, subcategoryTitle, subtitle, tags, tips, title, totalTimeMinutes
- Fields found in all recipes: calories, category, categoryGroupID, cookingTimeMinutes, creatorAvatarName, creatorName, description, difficulty, equipment, id, imageName, ingredients, instructions, isCommunityRecipe, isPremium, nutrition, prepTimeMinutes, sectionTags, servings, subcategoryID, subcategoryTitle, subtitle, tags, tips, title, totalTimeMinutes
- Fields missing in some recipes: None
- Placeholder signals: creatorName missing in 327 recipes, creatorAvatarName missing in 327 recipes, empty tags in 47 recipes

Desired final fields: `id`, `title`, `description`, `category`, `subcategory`, `imageName`, `servings`, `prepMinutes`, `cookMinutes`, `totalMinutes`, `ingredients`, `instructions`, `caloriesPerServing`, `nutritionPerServing`, `tags`

## 2. Recipe model summary

- Recipe model: `Flame_Fleur/Flame_Fleur/Shared/Models/Recipe.swift`
- `Recipe` fields: id, title, subtitle, description, categoryGroupID, subcategoryID, subcategoryTitle, creatorName, creatorAvatarName, category, sectionTags, prepTimeMinutes, cookingTimeMinutes, totalTimeMinutes, calories, servings, difficulty, tags, imageName, isPremium, isCommunityRecipe, ingredients, instructions, nutrition, equipment, tips
- `RecipeNutrition` fields: calories, proteinGrams, carbsGrams, fatGrams, fiberGrams, sugarGrams, sodiumMilligrams
- Current ingredient representation: arrays of strings, not structured ingredient objects
- Current nutrition representation: `RecipeNutrition` struct with 7 numeric fields
- Current model decodes the seed JSON: yes
- Final schema would require model changes: yes

## 3. Ingredient structure audit

- Ingredient representation: strings
- Recipes with no ingredients: 0
- Recipes with fewer than 4 ingredients: 0
- Unique ingredient names: 22
- Examples: baby greens, black pepper, brown rice, butter, chili flakes, cucumber, fresh herbs, garlic, greek yogurt, honey, lemon, olive oil, parmesan, quinoa, red onion

## 4. Instruction audit

- Instruction representation: strings
- Recipes with no instructions: 0
- Recipes with fewer than 3 instructions: 0
- Examples: Prep the ingredients and warm a large skillet over medium heat., Cook the aromatics until fragrant, then add the main ingredients., Simmer or roast until tender and deeply flavored., Adjust seasoning with salt, pepper, citrus, and herbs., Prep the ingredients and warm a large skillet over medium heat., Cook the aromatics until fragrant, then add the main ingredients., Simmer or roast until tender and deeply flavored., Adjust seasoning with salt, pepper, citrus, and herbs., Serve warm with the suggested garnish or side., Prep the ingredients and warm a large skillet over medium heat.

## 5. Time and serving audit

- Missing servings: 0
- Missing prep time: 0
- Missing cook time: 0
- Missing total time: 0
- Time format: integers in minutes

## 6. Nutrition audit

- Nutrition fields: calories, carbsGrams, fatGrams, fiberGrams, proteinGrams, sodiumMilligrams, sugarGrams
- Recipes with no calories: 0
- Recipes with no nutrition object: 0
- Recipes with partial nutrition: 0
- Vitamins/minerals present: no
- Nutrition appears per serving: yes

## 7. Shopping/cart database audit

- Shopping data location: `Flame_Fleur/Flame_Fleur/Shared/SampleData/SampleShoppingCartItems.swift`
- Shopping database exists: yes, but as a hybrid sample/dynamic list
- Static base items: 8
- Live generated recipe-derived catalog: yes (`suggestedItems` appends recipe ingredients from `RecipeRepository.shared.allRecipes`)
- `ShoppingCartItem` fields: id, name, quantity, unit, category, price, storeName, imageName, sourceRecipeID, sourceRecipeTitle, isChecked, notes
- Normalized name field in current model: no

## 8. Ingredient coverage check

- Total unique recipe ingredients: 22
- Live generated shopping catalog ingredients: 22
- Live generated shopping catalog missing ingredients: 0
- Static base shopping ingredients: 8
- Found in static base list: 2
- Missing from static base list: 20
- First 100 missing ingredients from live catalog: None
- First 100 missing ingredients from static base list: baby greens, black pepper, brown rice, butter, chili flakes, cucumber, fresh herbs, honey, lemon, olive oil, parmesan, quinoa, red onion, sea salt, shallot, smoked paprika, soy sauce, tahini, tomatoes, vegetable stock

## 9. Recommended final schema

Proposed `Recipe` enrichment fields:
- `id`, `title`, `description`, `category`, `subcategory`, `imageName`, `servings`, `prepMinutes`, `cookMinutes`, `totalMinutes`, `ingredients`, `instructions`, `caloriesPerServing`, `nutritionPerServing`, `tags`

Proposed structured ingredient record:
- `name`, `quantity`, `unit`, `category`

Proposed shopping ingredient record:
- `id`, `displayName`, `normalizedName`, `category`, `defaultUnit`, `estimatedPrice`, `imageName`

## 10. Recommendation
- Next ticket: enrich `recipes.seed.json` to a structured recipe schema and decide whether to promote the dynamic shopping suggestion logic into a dedicated ingredient catalog file.
