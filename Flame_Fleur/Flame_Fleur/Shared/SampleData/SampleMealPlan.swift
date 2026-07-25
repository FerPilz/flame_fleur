import Foundation

enum SampleMealPlan {
    static var anchorDate: Date {
        Calendar.current.startOfDay(for: Date())
    }

    static var meals: [PlannedMeal] {
        let calendar = Calendar.current
        let start = startOfWeek(for: anchorDate)
        let recipes = SampleRecipes.all

        return [
            meal(dayOffset: 0, slot: .breakfast, recipe: recipes[safe: 0], fallbackTitle: "Avocado Toast", start: start, calendar: calendar),
            meal(dayOffset: 0, slot: .lunch, recipe: recipes[safe: 1], fallbackTitle: "Tomato Pasta", start: start, calendar: calendar),
            meal(dayOffset: 0, slot: .dinner, recipe: recipes[safe: 2], fallbackTitle: "Citrus Couscous Bowl", start: start, calendar: calendar),
            meal(dayOffset: 0, slot: .snack, recipe: recipes[safe: 3], fallbackTitle: "Berry Smoothie", start: start, calendar: calendar),
            meal(dayOffset: 1, slot: .breakfast, recipe: recipes[safe: 4], fallbackTitle: "Overnight Oats", start: start, calendar: calendar),
            meal(dayOffset: 1, slot: .dinner, recipe: recipes[safe: 5], fallbackTitle: "Lemon Herb Salmon", start: start, calendar: calendar),
            meal(dayOffset: 2, slot: .breakfast, recipe: recipes[safe: 6], fallbackTitle: "Greek Yogurt Bowl", start: start, calendar: calendar),
            meal(dayOffset: 2, slot: .lunch, recipe: recipes[safe: 7], fallbackTitle: "Quinoa Salad", start: start, calendar: calendar),
            meal(dayOffset: 2, slot: .snack, recipe: recipes[safe: 8], fallbackTitle: "Trail Mix", start: start, calendar: calendar),
            meal(dayOffset: 3, slot: .lunch, recipe: recipes[safe: 9], fallbackTitle: "Pesto Primavera", start: start, calendar: calendar),
            meal(dayOffset: 3, slot: .dinner, recipe: recipes[safe: 10], fallbackTitle: "Golden Chicken Risotto", start: start, calendar: calendar),
            meal(dayOffset: 4, slot: .dinner, recipe: recipes[safe: 11], fallbackTitle: "Mushroom Toast", start: start, calendar: calendar)
        ]
    }

    private static func meal(
        dayOffset: Int,
        slot: MealSlot,
        recipe: Recipe?,
        fallbackTitle: String,
        start: Date,
        calendar: Calendar
    ) -> PlannedMeal {
        let date = calendar.date(byAdding: .day, value: dayOffset, to: start) ?? start

        if let recipe {
            return PlannedMeal(
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

        return PlannedMeal(
            date: date,
            slot: slot,
            title: fallbackTitle,
            calories: 420,
            proteinGrams: 24,
            carbsGrams: 42,
            fatGrams: 16,
            imageName: "world_italian_spicy_tomato_basil_pasta"
        )
    }

    private static func startOfWeek(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components).map { calendar.startOfDay(for: $0) } ?? calendar.startOfDay(for: date)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
