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

    static func summary(
        from plannedMeal: PlannedMeal,
        resolvingRecipeByID recipeLookup: (String) -> Recipe?
    ) -> NutritionSummary {
        guard let recipeID = plannedMeal.recipeID else {
            return summary(from: plannedMeal)
        }

        guard let recipe = recipeLookup(recipeID) else {
            #if DEBUG
            print("NutritionCalculator: missing recipe for planned meal \(plannedMeal.id) (recipeID: \(recipeID)); using stored nutrition snapshot.")
            #endif
            return summary(from: plannedMeal)
        }

        return summary(from: recipe)
    }

    static func summary(from plannedMeals: [PlannedMeal]) -> NutritionSummary {
        plannedMeals
            .map(summary(from:))
            .reduce(.zero, +)
    }

    static func summary(
        from plannedMeals: [PlannedMeal],
        resolvingRecipesByID recipeLookup: (String) -> Recipe?
    ) -> NutritionSummary {
        plannedMeals
            .map { summary(from: $0, resolvingRecipeByID: recipeLookup) }
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
