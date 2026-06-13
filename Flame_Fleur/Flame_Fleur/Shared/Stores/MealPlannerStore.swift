import Combine
import Foundation

final class MealPlannerStore: ObservableObject {
    static let shared = MealPlannerStore(
        selectedDate: SampleMealPlan.anchorDate,
        plannedMeals: SampleMealPlan.meals
    )

    @Published var selectedDate: Date
    @Published var visibleMonth: Date
    @Published private(set) var plannedMeals: [PlannedMeal]
    @Published private(set) var savedPlanNames: [String] = []

    private let calendar: Calendar

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

        plannedMeals.removeAll { existingMeal in
            calendar.isDate(existingMeal.date, inSameDayAs: normalizedMeal.date)
            && existingMeal.slot == normalizedMeal.slot
        }

        plannedMeals.append(normalizedMeal)
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
        plannedMeals.removeAll { $0.id == meal.id }
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
            meals(for: date).reduce(0) { $0 + $1.calories }
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
        mealsInVisibleWeek.reduce(MacroBalance(proteinGrams: 0, carbsGrams: 0, fatGrams: 0)) { balance, meal in
            MacroBalance(
                proteinGrams: balance.proteinGrams + meal.proteinGrams,
                carbsGrams: balance.carbsGrams + meal.carbsGrams,
                fatGrams: balance.fatGrams + meal.fatGrams
            )
        }
    }

    func totalCalories(for date: Date) -> Int {
        meals(for: date).reduce(0) { $0 + $1.calories }
    }

    var mealsInSelectedWeek: [PlannedMeal] {
        mealsInVisibleWeek
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
        PlannedMeal(
            date: date,
            slot: slot,
            recipeID: recipe.id,
            title: recipe.title,
            calories: recipe.calories,
            proteinGrams: recipe.nutrition.proteinGrams,
            carbsGrams: recipe.nutrition.carbsGrams,
            fatGrams: recipe.nutrition.fatGrams,
            imageName: recipe.imageName
        )
    }

    private func startOfWeek(for date: Date) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components).map { calendar.startOfDay(for: $0) } ?? calendar.startOfDay(for: date)
    }
}
