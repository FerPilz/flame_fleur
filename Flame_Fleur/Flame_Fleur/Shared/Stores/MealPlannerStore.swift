import Combine
import Foundation

final class MealPlannerStore: ObservableObject {
    static let shared = MealPlannerStore()

    @Published var selectedDate: Date
    @Published var visibleMonth: Date
    @Published private(set) var plannedMeals: [PlannedMeal]
    @Published private(set) var savedPlanNames: [String] = []

    private let calendar: Calendar
    private let recipeRepository = RecipeRepository.shared
    private var cancellables = Set<AnyCancellable>()

    init(
        selectedDate: Date = Date(),
        visibleMonth: Date? = nil,
        plannedMeals: [PlannedMeal] = [],
        calendar: Calendar = .current
    ) {
        self.calendar = calendar
        self.selectedDate = calendar.startOfDay(for: selectedDate)
        self.visibleMonth = visibleMonth.map { calendar.startOfDay(for: $0) } ?? calendar.startOfDay(for: selectedDate)
        self.plannedMeals = plannedMeals.map { meal in
            var normalizedMeal = meal
            normalizedMeal.date = calendar.startOfDay(for: meal.date)
            return normalizedMeal
        }

        UserRecipeStore.shared.$recipes
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    var weekDates: [Date] {
        let start = startOfWeek(for: selectedDate)

        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: start).map {
                calendar.startOfDay(for: $0)
            }
        }
    }

    func meals(for date: Date) -> [PlannedMeal] {
        plannedMeals.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func meal(for date: Date, slot: MealSlot) -> PlannedMeal? {
        plannedMeals.first { meal in
            calendar.isDate(meal.date, inSameDayAs: date) && meal.slot == slot
        }
    }

    func addMeal(_ meal: PlannedMeal) {
        var normalizedMeal = meal
        normalizedMeal.date = calendar.startOfDay(for: meal.date)

        let replacedMeals = plannedMeals.filter { existingMeal in
            calendar.isDate(existingMeal.date, inSameDayAs: normalizedMeal.date)
            && existingMeal.slot == normalizedMeal.slot
        }

        plannedMeals.removeAll { existingMeal in
            calendar.isDate(existingMeal.date, inSameDayAs: normalizedMeal.date)
            && existingMeal.slot == normalizedMeal.slot
        }

        recordRemovedPlannerEvents(for: replacedMeals)

        plannedMeals.append(normalizedMeal)
        recordPlannedEvent(for: normalizedMeal)
    }

    @discardableResult
    func addRecipe(_ recipe: Recipe, on date: Date) -> Bool {
        guard let slot = firstEmptySlot(on: date) else { return false }

        return addRecipe(recipe, on: date, slot: slot)
    }

    @discardableResult
    func addRecipe(_ recipe: Recipe, on date: Date, slot: MealSlot) -> Bool {
        addMeal(
            plannedMeal(from: recipe, date: date, slot: slot)
        )

        return true
    }

    @discardableResult
    func addRecipeToPlannerSlot(
        recipeID: String,
        date: Date,
        mealType: MealSlot,
        slotID: String? = nil,
        mode: PlannerRecipeSelectionContext.Mode = .add
    ) -> Bool {
        guard let recipe = recipeRepository.recipe(id: recipeID) else {
            return false
        }

        let didAdd = addRecipe(recipe, on: date, slot: mealType)
        guard didAdd else { return false }

        selectDate(date)
        _ = slotID
        _ = mode
        return true
    }

    @discardableResult
    func addRecipeToFirstAvailableWeekSlot(_ recipe: Recipe, preferredDate: Date) -> Bool {
        if addRecipe(recipe, on: preferredDate) {
            return true
        }

        for weekDate in weekDates where !calendar.isDate(weekDate, inSameDayAs: preferredDate) {
            if addRecipe(recipe, on: weekDate) {
                selectDate(weekDate)
                return true
            }
        }

        return false
    }

    func removeMeal(_ meal: PlannedMeal) {
        removeMeal(on: meal.date, slot: meal.slot)
    }

    func removeMeal(on date: Date, slot: MealSlot) {
        let removedMeals = plannedMeals.filter { meal in
            calendar.isDate(meal.date, inSameDayAs: date) && meal.slot == slot
        }

        plannedMeals.removeAll { meal in
            calendar.isDate(meal.date, inSameDayAs: date) && meal.slot == slot
        }

        recordRemovedPlannerEvents(for: removedMeals)
    }

    func clearPlannerDay(_ date: Date) {
        let removedMeals = plannedMeals.filter { meal in
            calendar.isDate(meal.date, inSameDayAs: date)
        }

        plannedMeals.removeAll { meal in
            calendar.isDate(meal.date, inSameDayAs: date)
        }

        recordRemovedPlannerEvents(for: removedMeals)
    }

    func clearPlanner() {
        let removedMeals = plannedMeals
        plannedMeals.removeAll()
        recordRemovedPlannerEvents(for: removedMeals)
    }

    func sharedMealPlanPayload() -> SharedMealPlanPayload {
        let calendar = self.calendar
        let groupedMeals = Dictionary(grouping: plannedMeals) { meal in
            calendar.startOfDay(for: meal.date)
        }

        let orderedDates = groupedMeals.keys.sorted()
        let days = orderedDates.map { date in
            let meals = (groupedMeals[date] ?? []).sorted { lhs, rhs in
                lhs.slot.sortOrder < rhs.slot.sortOrder
            }.map { meal in
                SharedMealPlanItem(
                    mealSlot: meal.slot,
                    recipeID: meal.recipeID,
                    title: meal.title,
                    imageName: meal.imageName,
                    calories: meal.calories,
                    proteinGrams: meal.proteinGrams,
                    carbsGrams: meal.carbsGrams,
                    fatGrams: meal.fatGrams,
                    servings: 1
                )
            }

            return SharedMealPlanDay(date: date, meals: meals)
        }

        let weekStartDate = orderedDates.first ?? startOfWeek(for: selectedDate)
        let weekEndDate = orderedDates.last ?? calendar.date(byAdding: .day, value: 6, to: weekStartDate)

        return SharedMealPlanPayload(
            exportedAt: Date(),
            weekStartDate: weekStartDate,
            weekEndDate: weekEndDate,
            days: days
        )
    }

    func replacePlanner(with payload: SharedMealPlanPayload) -> MealPlanImportSummary {
        let importedMeals: [PlannedMeal] = payload.days.flatMap { sharedDay in
            sharedDay.meals.map { sharedMeal in
                if let recipeID = sharedMeal.recipeID, let recipe = recipeRepository.recipe(id: recipeID) {
                    var plannedMeal = plannedMeal(from: recipe, date: sharedDay.date, slot: sharedMeal.mealSlot)
                    plannedMeal.date = calendar.startOfDay(for: sharedDay.date)
                    return plannedMeal
                }

                return PlannedMeal(
                    date: sharedDay.date,
                    slot: sharedMeal.mealSlot,
                    recipeID: sharedMeal.recipeID,
                    title: sharedMeal.title,
                    calories: sharedMeal.calories,
                    proteinGrams: sharedMeal.proteinGrams,
                    carbsGrams: sharedMeal.carbsGrams,
                    fatGrams: sharedMeal.fatGrams,
                    imageName: sharedMeal.imageName
                )
            }
        }

        plannedMeals = importedMeals.map { meal in
            var normalizedMeal = meal
            normalizedMeal.date = calendar.startOfDay(for: meal.date)
            return normalizedMeal
        }

        let selectedImportDate = payload.weekStartDate
            ?? importedMeals.map(\.date).min()
            ?? selectedDate
        selectDate(selectedImportDate)

        let unresolvedCount = payload.days.reduce(0) { runningTotal, sharedDay in
            runningTotal + sharedDay.meals.filter { meal in
                guard let recipeID = meal.recipeID else {
                    return true
                }

                return recipeRepository.recipe(id: recipeID) == nil
            }.count
        }

        return MealPlanImportSummary(
            importedMealCount: importedMeals.count,
            unresolvedMealCount: unresolvedCount
        )
    }

    func selectDate(_ date: Date) {
        selectedDate = calendar.startOfDay(for: date)
        visibleMonth = selectedDate
    }

    func savePlan(named name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        savedPlanNames.append(trimmedName)
    }

    func moveWeek(by value: Int) {
        guard let nextDate = calendar.date(byAdding: .day, value: value * 7, to: selectedDate) else { return }
        selectDate(nextDate)
    }

    func moveMonth(by value: Int) {
        guard let nextMonth = calendar.date(byAdding: .month, value: value, to: visibleMonth) else { return }
        let components = calendar.dateComponents([.year, .month], from: nextMonth)
        let firstDay = calendar.date(from: components) ?? nextMonth
        selectDate(firstDay)
    }

    var weeklySummary: MealPlanSummary {
        let weeklyMeals = mealsInVisibleWeek
        let caloriesByDay = weekDates.map { date in
            Int(nutritionSummary(for: date).calories.rounded())
        }
        let averageCalories = caloriesByDay.isEmpty ? 0 : caloriesByDay.reduce(0, +) / caloriesByDay.count
        let mealsPlanned = weeklyMeals.count
        let score = min(100, 54 + mealsPlanned * 3)

        return MealPlanSummary(
            averageCalories: averageCalories,
            mealsPlanned: mealsPlanned,
            goalScore: score,
            goalLabel: score >= 88 ? "Goal on track" : "Keep planning"
        )
    }

    var macroBalance: MacroBalance {
        MacroBalance(summary: weeklyNutritionSummary)
    }

    var selectedDayNutritionSummary: NutritionSummary {
        nutritionSummary(for: selectedDate)
    }

    var selectedDayMacroBalance: MacroBalance {
        MacroBalance(summary: selectedDayNutritionSummary)
    }

    func totalCalories(for date: Date) -> Int {
        Int(nutritionSummary(for: date).calories.rounded())
    }

    var mealsInSelectedWeek: [PlannedMeal] {
        mealsInVisibleWeek
    }

    var weeklyNutritionSummary: NutritionSummary {
        NutritionCalculator.summary(
            from: mealsInVisibleWeek,
            resolvingRecipesByID: recipeRepository.recipe(id:)
        )
    }

    private var mealsInVisibleWeek: [PlannedMeal] {
        plannedMeals.filter { meal in
            weekDates.contains { calendar.isDate($0, inSameDayAs: meal.date) }
        }
    }

    private func firstEmptySlot(on date: Date) -> MealSlot? {
        MealSlot.allCases.first { slot in
            meal(for: date, slot: slot) == nil
        }
    }

    private func plannedMeal(from recipe: Recipe, date: Date, slot: MealSlot) -> PlannedMeal {
        let nutrition = NutritionCalculator.summary(from: recipe)

        return PlannedMeal(
            date: date,
            slot: slot,
            recipeID: recipe.id,
            title: recipe.title,
            calories: Int(nutrition.calories.rounded()),
            proteinGrams: Int(nutrition.proteinGrams.rounded()),
            carbsGrams: Int(nutrition.carbohydrateGrams.rounded()),
            fatGrams: Int(nutrition.fatGrams.rounded()),
            imageName: recipe.imageName
        )
    }

    private func nutritionSummary(for date: Date) -> NutritionSummary {
        NutritionCalculator.summary(
            from: meals(for: date),
            resolvingRecipesByID: recipeRepository.recipe(id:)
        )
    }

    private func recordPlannedEvent(for meal: PlannedMeal) {
        let resolvedRecipe = meal.recipeID.flatMap(recipeRepository.recipe(id:))

        UsageTrackingStore.shared.record(
            type: .recipePlanned,
            recipe: resolvedRecipe,
            recipeID: meal.recipeID,
            recipeTitle: meal.title,
            mealType: meal.slot.title,
            calories: Double(meal.calories),
            proteinGrams: Double(meal.proteinGrams),
            carbGrams: Double(meal.carbsGrams),
            fatGrams: Double(meal.fatGrams)
        )
    }

    private func recordRemovedPlannerEvents(for meals: [PlannedMeal]) {
        for meal in meals {
            let resolvedRecipe = meal.recipeID.flatMap(recipeRepository.recipe(id:))

            UsageTrackingStore.shared.record(
                type: .recipeRemovedFromPlanner,
                recipe: resolvedRecipe,
                recipeID: meal.recipeID,
                recipeTitle: meal.title,
                mealType: meal.slot.title,
                calories: Double(meal.calories),
                proteinGrams: Double(meal.proteinGrams),
                carbGrams: Double(meal.carbsGrams),
                fatGrams: Double(meal.fatGrams)
            )
        }
    }

    private func startOfWeek(for date: Date) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components).map { calendar.startOfDay(for: $0) } ?? calendar.startOfDay(for: date)
    }
}

struct MealPlanImportSummary {
    let importedMealCount: Int
    let unresolvedMealCount: Int
}

private extension MealSlot {
    var sortOrder: Int {
        switch self {
        case .breakfast:
            return 0
        case .lunch:
            return 1
        case .snack:
            return 2
        case .dinner:
            return 3
        }
    }
}
