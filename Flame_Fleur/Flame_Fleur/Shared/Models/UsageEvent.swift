import Foundation

enum UsageEventType: String, Codable, CaseIterable, Hashable {
    case recipeViewed
    case recipeSaved
    case recipeUnSaved
    case recipePlanned
    case recipeRemovedFromPlanner
    case planAddedToCart
    case cartItemAdded
    case cartItemRemoved
    case cartSaved
    case cartShared
    case planShared
}

struct UsageEvent: Identifiable, Codable, Hashable {
    let id: UUID
    let type: UsageEventType
    let date: Date
    let recipeID: String?
    let recipeTitle: String?
    let cuisine: String?
    let category: String?
    let mealType: String?
    let ingredientNames: [String]
    let calories: Double?
    let proteinGrams: Double?
    let carbGrams: Double?
    let fatGrams: Double?

    init(
        id: UUID = UUID(),
        type: UsageEventType,
        date: Date = Date(),
        recipeID: String? = nil,
        recipeTitle: String? = nil,
        cuisine: String? = nil,
        category: String? = nil,
        mealType: String? = nil,
        ingredientNames: [String] = [],
        calories: Double? = nil,
        proteinGrams: Double? = nil,
        carbGrams: Double? = nil,
        fatGrams: Double? = nil
    ) {
        self.id = id
        self.type = type
        self.date = date
        self.recipeID = recipeID
        self.recipeTitle = recipeTitle
        self.cuisine = cuisine
        self.category = category
        self.mealType = mealType
        self.ingredientNames = ingredientNames
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbGrams = carbGrams
        self.fatGrams = fatGrams
    }
}
