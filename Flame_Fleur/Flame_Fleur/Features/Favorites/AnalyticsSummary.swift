import Foundation

struct AnalyticsSummary {
    let savedRecipes: [Recipe]
    let weeklyPlannedMeals: [PlannedMeal]
    let plannedDishesThisWeek: Int
    let averagePlannedCaloriesPerDay: Int?
    let savedRecipeCount: Int
    let topRecipeSnapshot: RecipeUsageInsight?
    let macroSplit: MacroSplit?
    let topCuisine: CuisineInsight?
    let topCuisines: [CuisineInsight]
    let topIngredients: [IngredientInsight]
    let topPlannedRecipes: [RecipeUsageInsight]
    let ingredientSource: IngredientInsightSource
    let usesCookedHistory: Bool

    var plannedDishesCount: Int {
        plannedDishesThisWeek
    }

    var usesSavedRecipeFallbackForIngredients: Bool {
        ingredientSource == .savedRecipes
    }
}

struct AnalyticsSummaryBuilder {
    let usageTrackingStore: UsageTrackingStore
    let favoritesStore: FavoritesStore
    let mealPlannerStore: MealPlannerStore
    let recipeRepository: RecipeRepository
    let calendar: Calendar

    init(
        usageTrackingStore: UsageTrackingStore,
        favoritesStore: FavoritesStore,
        mealPlannerStore: MealPlannerStore,
        recipeRepository: RecipeRepository = .shared,
        calendar: Calendar = .current
    ) {
        self.usageTrackingStore = usageTrackingStore
        self.favoritesStore = favoritesStore
        self.mealPlannerStore = mealPlannerStore
        self.recipeRepository = recipeRepository
        self.calendar = calendar
    }

    func build() -> AnalyticsSummary {
        let savedRecipes = resolvedSavedRecipes()
        let weeklyMeals = mealPlannerStore.mealsInSelectedWeek
        let plannedEventRecords = usageRecords(for: .recipePlanned)
        let currentPlannedRecords = currentPlannedMealRecords()
        let viewedRecords = usageRecords(for: .recipeViewed)
        let savedRecipeRecords = savedRecipes.map { recipe in
            makeRecord(for: recipe)
        }

        let plannedRecordsForInsights = plannedEventRecords.isEmpty ? currentPlannedRecords : plannedEventRecords
        let topPlannedRecipes = buildRecipeInsights(from: plannedRecordsForInsights)
        let cuisineRecords = combinedCuisineRecords(
            plannedRecords: plannedRecordsForInsights,
            savedRecipeRecords: savedRecipeRecords,
            viewedRecords: viewedRecords
        )
        let topCuisines = buildCuisineInsights(from: cuisineRecords)
        let ingredientRecords = ingredientRecords(
            plannedRecords: plannedRecordsForInsights,
            savedRecipeRecords: savedRecipeRecords,
            viewedRecords: viewedRecords
        )
        let dailyCalories = plannedCaloriesByDay(from: weeklyMeals)
        let macroSplit = MacroSplit(
            summary: NutritionCalculator.summary(
                from: weeklyMeals,
                resolvingRecipesByID: recipeRepository.recipe(id:)
            )
        )

        return AnalyticsSummary(
            savedRecipes: savedRecipes,
            weeklyPlannedMeals: weeklyMeals,
            plannedDishesThisWeek: weeklyMeals.count,
            averagePlannedCaloriesPerDay: dailyCalories.isEmpty
                ? nil
                : Int((dailyCalories.reduce(0.0, +) / Double(dailyCalories.count)).rounded()),
            savedRecipeCount: favoritesStore.favoriteRecipeIDs.count,
            topRecipeSnapshot: topPlannedRecipes.first,
            macroSplit: macroSplit,
            topCuisine: topCuisines.first,
            topCuisines: topCuisines,
            topIngredients: buildIngredientInsights(from: ingredientRecords.records),
            topPlannedRecipes: topPlannedRecipes,
            ingredientSource: ingredientRecords.source,
            usesCookedHistory: false
        )
    }

    private func resolvedSavedRecipes() -> [Recipe] {
        favoritesStore.favoriteRecipeIDs
            .compactMap(recipeRepository.recipe(id:))
            .sorted { lhs, rhs in
                let lhsDate = favoritesStore.favoriteDate(for: lhs.id) ?? .distantPast
                let rhsDate = favoritesStore.favoriteDate(for: rhs.id) ?? .distantPast
                return lhsDate > rhsDate
            }
    }

    private func usageRecords(for type: UsageEventType) -> [RecipeUsageRecord] {
        usageTrackingStore.events.compactMap { event in
            guard event.type == type else {
                return nil
            }

            return makeRecord(for: event)
        }
    }

    private func currentPlannedMealRecords() -> [RecipeUsageRecord] {
        mealPlannerStore.plannedMeals.compactMap { meal in
            if let recipeID = meal.recipeID, let recipe = recipeRepository.recipe(id: recipeID) {
                return makeRecord(for: recipe, mealType: meal.slot.title)
            }

            return RecipeUsageRecord(
                key: meal.recipeID ?? meal.title.fallbackUsageKey,
                recipe: nil,
                recipeID: meal.recipeID,
                recipeTitle: meal.title,
                recipeSubtitle: nil,
                imageName: meal.imageName,
                cuisine: nil,
                category: nil,
                mealType: meal.slot.title,
                ingredientNames: [],
                calories: Double(meal.calories),
                proteinGrams: Double(meal.proteinGrams),
                carbGrams: Double(meal.carbsGrams),
                fatGrams: Double(meal.fatGrams)
            )
        }
    }

    private func combinedCuisineRecords(
        plannedRecords: [RecipeUsageRecord],
        savedRecipeRecords: [RecipeUsageRecord],
        viewedRecords: [RecipeUsageRecord]
    ) -> [RecipeUsageRecord] {
        let combined = plannedRecords + savedRecipeRecords
        return combined.isEmpty ? viewedRecords : combined
    }

    private func ingredientRecords(
        plannedRecords: [RecipeUsageRecord],
        savedRecipeRecords: [RecipeUsageRecord],
        viewedRecords: [RecipeUsageRecord]
    ) -> (source: IngredientInsightSource, records: [RecipeUsageRecord]) {
        if !plannedRecords.isEmpty {
            return (.plannedMeals, plannedRecords)
        }

        if !savedRecipeRecords.isEmpty {
            return (.savedRecipes, savedRecipeRecords)
        }

        if !viewedRecords.isEmpty {
            return (.viewedRecipes, viewedRecords)
        }

        return (.none, [])
    }

    private func plannedCaloriesByDay(from meals: [PlannedMeal]) -> [Double] {
        Dictionary(grouping: meals) { calendar.startOfDay(for: $0.date) }
            .values
            .map { dayMeals in
                NutritionCalculator.summary(
                    from: dayMeals,
                    resolvingRecipesByID: recipeRepository.recipe(id:)
                ).calories
            }
            .filter { $0 > 0 }
    }

    private func makeRecord(for event: UsageEvent) -> RecipeUsageRecord {
        let resolvedRecipe = event.recipeID.flatMap(recipeRepository.recipe(id:))

        return RecipeUsageRecord(
            key: event.recipeID ?? event.recipeTitle?.fallbackUsageKey ?? UUID().uuidString,
            recipe: resolvedRecipe,
            recipeID: resolvedRecipe?.id ?? event.recipeID,
            recipeTitle: resolvedRecipe?.title ?? event.recipeTitle ?? "Recipe",
            recipeSubtitle: resolvedRecipe?.subtitle,
            imageName: resolvedRecipe?.imageName,
            cuisine: resolvedRecipe.flatMap { RecipeInsightResolver.cuisineName(for: $0) } ?? event.cuisine,
            category: resolvedRecipe?.category.title ?? event.category,
            mealType: event.mealType,
            ingredientNames: event.ingredientNames.isEmpty
                ? resolvedRecipe.map { recipe in
                    RecipeInsightResolver.normalizedIngredientNames(for: recipe)
                } ?? []
                : event.ingredientNames,
            calories: event.calories,
            proteinGrams: event.proteinGrams,
            carbGrams: event.carbGrams,
            fatGrams: event.fatGrams
        )
    }

    private func makeRecord(for recipe: Recipe, mealType: String? = nil) -> RecipeUsageRecord {
        let nutrition = RecipeInsightResolver.nutritionSummary(for: recipe)

        return RecipeUsageRecord(
            key: recipe.id,
            recipe: recipe,
            recipeID: recipe.id,
            recipeTitle: recipe.title,
            recipeSubtitle: recipe.subtitle,
            imageName: recipe.imageName,
            cuisine: RecipeInsightResolver.cuisineName(for: recipe),
            category: recipe.category.title,
            mealType: mealType,
            ingredientNames: RecipeInsightResolver.normalizedIngredientNames(for: recipe),
            calories: nutrition.calories,
            proteinGrams: nutrition.proteinGrams,
            carbGrams: nutrition.carbohydrateGrams,
            fatGrams: nutrition.fatGrams
        )
    }

    private func buildRecipeInsights(from records: [RecipeUsageRecord]) -> [RecipeUsageInsight] {
        var counts: [String: (record: RecipeUsageRecord, count: Int)] = [:]

        for record in records {
            guard !record.key.isEmpty else {
                continue
            }

            var current = counts[record.key] ?? (record, 0)
            current.count += 1

            if current.record.recipe == nil && record.recipe != nil {
                current.record = record
            }

            counts[record.key] = current
        }

        return counts.values
            .map { value in
                RecipeUsageInsight(
                    recipeID: value.record.recipeID,
                    recipeTitle: value.record.recipeTitle,
                    recipeSubtitle: value.record.recipeSubtitle,
                    imageName: value.record.imageName,
                    count: value.count,
                    recipe: value.record.recipe
                )
            }
            .sorted { lhs, rhs in
                if lhs.count == rhs.count {
                    return lhs.recipeTitle.localizedCaseInsensitiveCompare(rhs.recipeTitle) == .orderedAscending
                }

                return lhs.count > rhs.count
            }
    }

    private func buildIngredientInsights(from records: [RecipeUsageRecord]) -> [IngredientInsight] {
        var counts: [String: IngredientInsight] = [:]

        for record in records {
            for normalizedName in record.ingredientNames where !normalizedName.isEmpty {
                let catalogItem = SampleShoppingIngredientCatalog.byNormalizedName[normalizedName]
                let displayName = catalogItem?.displayName ?? normalizedName.displayIngredientName
                let imageName = catalogItem?.imageName
                let currentCount = counts[normalizedName]?.count ?? 0

                counts[normalizedName] = IngredientInsight(
                    normalizedName: normalizedName,
                    displayName: displayName,
                    imageName: imageName,
                    count: currentCount + 1
                )
            }
        }

        return counts.values
            .sorted { lhs, rhs in
                if lhs.count == rhs.count {
                    return lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) == .orderedAscending
                }

                return lhs.count > rhs.count
            }
            .prefix(5)
            .map { $0 }
    }

    private func buildCuisineInsights(from records: [RecipeUsageRecord]) -> [CuisineInsight] {
        var counts: [String: Int] = [:]

        for record in records {
            guard let cuisine = record.cuisine?.trimmedNonEmpty else {
                continue
            }

            counts[cuisine, default: 0] += 1
        }

        return counts
            .map { CuisineInsight(name: $0.key, count: $0.value) }
            .sorted { lhs, rhs in
                if lhs.count == rhs.count {
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }

                return lhs.count > rhs.count
            }
            .prefix(3)
            .map { $0 }
    }
}

enum IngredientInsightSource: Hashable {
    case plannedMeals
    case savedRecipes
    case viewedRecipes
    case none
}

struct CuisineInsight: Identifiable, Hashable {
    let name: String
    let count: Int

    var id: String { name }

    var countText: String {
        count == 1 ? "1 recipe" : "\(count) recipes"
    }
}

struct IngredientInsight: Identifiable, Hashable {
    let normalizedName: String
    let displayName: String
    let imageName: String?
    let count: Int

    var id: String { normalizedName }

    var countText: String {
        count == 1 ? "1 use" : "\(count) uses"
    }
}

struct RecipeUsageInsight: Identifiable, Hashable {
    let recipeID: String?
    let recipeTitle: String
    let recipeSubtitle: String?
    let imageName: String?
    let count: Int
    let recipe: Recipe?

    var id: String {
        recipeID ?? recipeTitle.fallbackUsageKey
    }

    var countText: String {
        count == 1 ? "1 plan" : "\(count) plans"
    }
}

struct MacroSplit: Hashable {
    let totalCalories: Int
    let slices: [MacroSplitSlice]

    init?(summary: NutritionSummary) {
        let proteinCalories = max(summary.proteinGrams, 0) * 4
        let carbsCalories = max(summary.carbohydrateGrams, 0) * 4
        let fatCalories = max(summary.fatGrams, 0) * 9
        let macroCalories = proteinCalories + carbsCalories + fatCalories

        guard macroCalories > 0 else {
            return nil
        }

        let totalDisplayCalories = Int((summary.calories > 0 ? summary.calories : macroCalories).rounded())

        self.totalCalories = totalDisplayCalories
        self.slices = [
            MacroSplitSlice(
                title: "Protein",
                calories: Int(proteinCalories.rounded()),
                grams: Int(summary.proteinGrams.rounded()),
                percentage: proteinCalories / macroCalories
            ),
            MacroSplitSlice(
                title: "Carbs",
                calories: Int(carbsCalories.rounded()),
                grams: Int(summary.carbohydrateGrams.rounded()),
                percentage: carbsCalories / macroCalories
            ),
            MacroSplitSlice(
                title: "Fat",
                calories: Int(fatCalories.rounded()),
                grams: Int(summary.fatGrams.rounded()),
                percentage: fatCalories / macroCalories
            )
        ]
    }
}

struct MacroSplitSlice: Identifiable, Hashable {
    let title: String
    let calories: Int
    let grams: Int
    let percentage: Double

    var id: String { title }

    var percentageText: String {
        NutritionSummary.percentageText(percentage * 100)
    }

    var caloriesText: String {
        "\(calories) cal"
    }

    var gramsText: String {
        NutritionSummary.gramsText(Double(grams))
    }
}

private struct RecipeUsageRecord: Hashable {
    let key: String
    let recipe: Recipe?
    let recipeID: String?
    let recipeTitle: String
    let recipeSubtitle: String?
    let imageName: String?
    let cuisine: String?
    let category: String?
    let mealType: String?
    let ingredientNames: [String]
    let calories: Double?
    let proteinGrams: Double?
    let carbGrams: Double?
    let fatGrams: Double?
}

private extension String {
    var fallbackUsageKey: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: #"[^\p{L}\p{N}]+"#, with: "-", options: .regularExpression)
    }

    var displayIngredientName: String {
        split(separator: " ")
            .map { substring in
                let word = String(substring)
                return word.prefix(1).uppercased() + word.dropFirst()
            }
            .joined(separator: " ")
    }

    var trimmedNonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
