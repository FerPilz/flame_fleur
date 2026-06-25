import Foundation

struct PlannedMeal: Identifiable, Hashable, Codable {
    let id: UUID
    var date: Date
    var slot: MealSlot
    var recipeID: String?
    var title: String
    var calories: Int
    var proteinGrams: Int
    var carbsGrams: Int
    var fatGrams: Int
    var imageName: String?

    init(
        id: UUID = UUID(),
        date: Date,
        slot: MealSlot,
        recipeID: String? = nil,
        title: String,
        calories: Int,
        proteinGrams: Int,
        carbsGrams: Int,
        fatGrams: Int,
        imageName: String? = nil
    ) {
        self.id = id
        self.date = date
        self.slot = slot
        self.recipeID = recipeID
        self.title = title
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatGrams = fatGrams
        self.imageName = imageName
    }
}

extension PlannedMeal {
    var nutritionSummary: NutritionSummary {
        NutritionCalculator.summary(from: self)
    }
}
