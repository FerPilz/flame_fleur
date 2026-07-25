import Foundation

struct ProfileInsights {
    let favoriteCuisine: CuisineInsight?
    let favoriteIngredient: IngredientInsight?
    let planningStyle: PlanningStyleInsight?
    let savedRecipeCount: Int
    let plannedDishesThisWeek: Int
    let topMealType: MealTypeInsight?
}

struct ProfileInsightsBuilder {
    let analyticsSummary: AnalyticsSummary
    let usageTrackingStore: UsageTrackingStore
    let mealPlannerStore: MealPlannerStore
    let recipeRepository: RecipeRepository

    init(
        analyticsSummary: AnalyticsSummary,
        usageTrackingStore: UsageTrackingStore,
        mealPlannerStore: MealPlannerStore,
        recipeRepository: RecipeRepository = .shared
    ) {
        self.analyticsSummary = analyticsSummary
        self.usageTrackingStore = usageTrackingStore
        self.mealPlannerStore = mealPlannerStore
        self.recipeRepository = recipeRepository
    }

    func build() -> ProfileInsights {
        let mealTypeCounts = plannedMealTypeCounts()
        let plannedRecipes = plannedRecipes()

        return ProfileInsights(
            favoriteCuisine: analyticsSummary.topCuisine,
            favoriteIngredient: analyticsSummary.topIngredients.first,
            planningStyle: planningStyle(
                plannedRecipes: plannedRecipes,
                mealTypeCounts: mealTypeCounts
            ),
            savedRecipeCount: analyticsSummary.savedRecipeCount,
            plannedDishesThisWeek: analyticsSummary.plannedDishesThisWeek,
            topMealType: mealTypeCounts.sorted { lhs, rhs in
                if lhs.value == rhs.value {
                    return lhs.key.localizedCaseInsensitiveCompare(rhs.key) == .orderedAscending
                }

                return lhs.value > rhs.value
            }
            .first
            .map { MealTypeInsight(name: $0.key, count: $0.value) }
        )
    }

    private func plannedRecipes() -> [Recipe] {
        let historicalRecipes = usageTrackingStore.events.compactMap { event -> Recipe? in
            guard event.type == .recipePlanned, let recipeID = event.recipeID else {
                return nil
            }

            return recipeRepository.recipe(id: recipeID)
        }

        if !historicalRecipes.isEmpty {
            return historicalRecipes
        }

        return mealPlannerStore.plannedMeals.compactMap { meal in
            guard let recipeID = meal.recipeID else {
                return nil
            }

            return recipeRepository.recipe(id: recipeID)
        }
    }

    private func plannedMealTypeCounts() -> [String: Int] {
        let eventCounts = usageTrackingStore.events.reduce(into: [String: Int]()) { counts, event in
            guard event.type == .recipePlanned,
                  let mealType = event.mealType?.trimmedNonEmpty else {
                return
            }

            counts[mealType, default: 0] += 1
        }

        if !eventCounts.isEmpty {
            return eventCounts
        }

        return mealPlannerStore.plannedMeals.reduce(into: [String: Int]()) { counts, meal in
            counts[meal.slot.title, default: 0] += 1
        }
    }

    private func planningStyle(
        plannedRecipes: [Recipe],
        mealTypeCounts: [String: Int]
    ) -> PlanningStyleInsight? {
        let totalCount = plannedRecipes.count
        let topMealType = mealTypeCounts.max { lhs, rhs in lhs.value < rhs.value }
        let dinnerCount = mealTypeCounts["Dinner", default: 0]
        let breakfastCount = mealTypeCounts["Breakfast", default: 0]
        let planningToCartActions = usageTrackingStore.events.filter { $0.type == .planAddedToCart }.count

        guard totalCount >= 3 || !mealTypeCounts.isEmpty else {
            return nil
        }

        if breakfastCount >= 3 && breakfastCount >= max(2, Int(Double(totalCount) * 0.45)) {
            return PlanningStyleInsight(
                title: "Breakfast Builder",
                detail: "Breakfast shows up most often in your plans.",
                systemImage: "sunrise.fill"
            )
        }

        let plantForwardCount = plannedRecipes.filter(isPlantForward).count
        if totalCount >= 3 && Double(plantForwardCount) / Double(totalCount) >= 0.6 {
            return PlanningStyleInsight(
                title: "Plant-forward Cook",
                detail: "Most of your planned meals lean vegetable- and legume-first.",
                systemImage: "leaf.fill"
            )
        }

        let proteinShare = analyticsSummary.macroSplit?.slices.first(where: { $0.title == "Protein" })?.percentage ?? 0
        let highProteinRecipeCount = plannedRecipes.filter(isHighProtein).count
        if totalCount >= 3 && (proteinShare >= 0.33 || Double(highProteinRecipeCount) / Double(totalCount) >= 0.6) {
            return PlanningStyleInsight(
                title: "High Protein Planner",
                detail: "Protein-heavy dishes make up a strong share of your week.",
                systemImage: "bolt.heart.fill"
            )
        }

        let quickCookCount = plannedRecipes.filter { $0.totalMinutes <= 35 }.count
        if dinnerCount >= 2 && totalCount >= 3 && Double(quickCookCount) / Double(totalCount) >= 0.5 {
            return PlanningStyleInsight(
                title: "Weeknight Cook",
                detail: "You tend to plan quick dinners that fit into busy evenings.",
                systemImage: "moon.stars.fill"
            )
        }

        if analyticsSummary.topCuisines.count >= 3 && totalCount + analyticsSummary.savedRecipeCount >= 4 {
            return PlanningStyleInsight(
                title: "Explorer",
                detail: "Your meals span several cuisines instead of one default lane.",
                systemImage: "globe.americas.fill"
            )
        }

        if planningToCartActions > 0 && analyticsSummary.plannedDishesThisWeek > 0 {
            return PlanningStyleInsight(
                title: "Balanced Planner",
                detail: "You regularly turn planned meals into ready-to-shop grocery lists.",
                systemImage: "checkmark.seal.fill"
            )
        }

        if let topMealType, topMealType.value >= 2 {
            return PlanningStyleInsight(
                title: "Balanced Planner",
                detail: "\(topMealType.key) is your most common planning rhythm right now.",
                systemImage: "calendar.badge.clock"
            )
        }

        return nil
    }

    private func isPlantForward(_ recipe: Recipe) -> Bool {
        switch recipe.category {
        case .vegetarian, .tofuTempeh, .beansLentils, .salad, .mushrooms:
            return true
        default:
            return recipe.tags.contains { tag in
                tag.localizedCaseInsensitiveContains("vegetarian")
                || tag.localizedCaseInsensitiveContains("vegan")
                || tag.localizedCaseInsensitiveContains("plant")
            }
        }
    }

    private func isHighProtein(_ recipe: Recipe) -> Bool {
        let nutrition = NutritionCalculator.summary(from: recipe)
        let calorieThreshold = max(nutrition.calories, 1)
        let proteinCalories = nutrition.proteinGrams * 4

        return proteinCalories / calorieThreshold >= 0.25
            || recipe.category == .highProtein
            || recipe.tags.contains { $0.localizedCaseInsensitiveContains("protein") }
    }
}

struct PlanningStyleInsight: Hashable {
    let title: String
    let detail: String
    let systemImage: String
}

struct MealTypeInsight: Hashable {
    let name: String
    let count: Int

    var countText: String {
        count == 1 ? "1 plan" : "\(count) plans"
    }
}

private extension String {
    var trimmedNonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
