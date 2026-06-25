import Foundation

enum NutritionCalculator {
    static func summary(from recipeNutrition: RecipeNutrition) -> NutritionSummary {
        NutritionSummary(
            calories: Double(recipeNutrition.calories),
            proteinGrams: Double(recipeNutrition.proteinGrams),
            carbohydrateGrams: Double(recipeNutrition.carbsGrams),
            fatGrams: Double(recipeNutrition.fatGrams),
            fiberGrams: Double(recipeNutrition.fiberGrams),
            sugarGrams: Double(recipeNutrition.sugarGrams),
            sodiumMilligrams: Double(recipeNutrition.sodiumMilligrams)
        )
    }

    static func summary(from recipe: Recipe) -> NutritionSummary {
        summary(from: recipe.nutritionPerServing)
    }

    static func summary(from recipes: [Recipe]) -> NutritionSummary {
        recipes
            .map(summary(from:))
            .reduce(.zero, +)
    }

    static func summary(from plannedMeal: PlannedMeal) -> NutritionSummary {
        NutritionSummary(
            calories: Double(plannedMeal.calories),
            proteinGrams: Double(plannedMeal.proteinGrams),
            carbohydrateGrams: Double(plannedMeal.carbsGrams),
            fatGrams: Double(plannedMeal.fatGrams)
        )
    }

    static func summary(from plannedMeals: [PlannedMeal]) -> NutritionSummary {
        plannedMeals
            .map(summary(from:))
            .reduce(.zero, +)
    }

    static func summary(
        from cartItems: [ShoppingCartItem],
        resolvingRecipesByID recipeLookup: (String) -> Recipe?
    ) -> NutritionSummary {
        let uniqueRecipeIDs = Set(cartItems.compactMap(\.sourceRecipeID))
        let recipes = uniqueRecipeIDs.compactMap(recipeLookup)
        return summary(from: recipes)
    }
}
