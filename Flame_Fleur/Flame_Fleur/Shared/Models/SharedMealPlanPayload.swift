import Foundation

struct SharedMealPlanPayload: Codable, Hashable {
    static let schemaVersionValue = 1
    static let sourceAppValue = "AllSpiced"

    let schemaVersion: Int
    let sourceApp: String
    let exportedAt: Date
    let weekStartDate: Date?
    let weekEndDate: Date?
    let days: [SharedMealPlanDay]

    init(
        exportedAt: Date = Date(),
        weekStartDate: Date? = nil,
        weekEndDate: Date? = nil,
        days: [SharedMealPlanDay]
    ) {
        self.schemaVersion = Self.schemaVersionValue
        self.sourceApp = Self.sourceAppValue
        self.exportedAt = exportedAt
        self.weekStartDate = weekStartDate
        self.weekEndDate = weekEndDate
        self.days = days
    }
}

struct SharedMealPlanDay: Codable, Hashable {
    let date: Date
    let meals: [SharedMealPlanItem]
}

struct SharedMealPlanItem: Codable, Hashable {
    let mealSlot: MealSlot
    let recipeID: String?
    let title: String
    let imageName: String?
    let calories: Int
    let proteinGrams: Int
    let carbsGrams: Int
    let fatGrams: Int
    let servings: Int
}
