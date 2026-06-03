import Foundation

struct Recipe: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let subtitle: String
    let description: String
    let categoryGroupID: String?
    let subcategoryID: String?
    let subcategoryTitle: String?
    let creatorName: String?
    let creatorAvatarName: String?
    let category: RecipeCategory
    let sectionTags: Set<RecipeSectionTag>
    let prepTimeMinutes: Int
    let cookingTimeMinutes: Int
    let totalTimeMinutes: Int
    let calories: Int
    let servings: Int
    let difficulty: RecipeDifficulty
    let tags: [String]
    let imageName: String?
    let isPremium: Bool
    let isCommunityRecipe: Bool
    let ingredients: [String]
    let instructions: [String]
    let nutrition: RecipeNutrition
    let equipment: [String]
    let tips: [String]

    init(
        id: String,
        title: String,
        subtitle: String,
        description: String = "",
        categoryGroupID: String? = nil,
        subcategoryID: String? = nil,
        subcategoryTitle: String? = nil,
        creatorName: String? = nil,
        creatorAvatarName: String? = nil,
        category: RecipeCategory,
        sectionTags: [RecipeSectionTag],
        prepTimeMinutes: Int = 10,
        cookingTimeMinutes: Int,
        totalTimeMinutes: Int? = nil,
        calories: Int,
        servings: Int,
        difficulty: RecipeDifficulty,
        tags: [String] = [],
        imageName: String? = nil,
        isPremium: Bool = false,
        isCommunityRecipe: Bool = false,
        ingredients: [String] = [],
        instructions: [String] = [],
        nutrition: RecipeNutrition? = nil,
        equipment: [String] = [],
        tips: [String] = []
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.description = description.isEmpty ? subtitle : description
        self.categoryGroupID = categoryGroupID
        self.subcategoryID = subcategoryID
        self.subcategoryTitle = subcategoryTitle
        self.creatorName = creatorName
        self.creatorAvatarName = creatorAvatarName
        self.category = category
        self.sectionTags = Set(sectionTags)
        self.prepTimeMinutes = prepTimeMinutes
        self.cookingTimeMinutes = cookingTimeMinutes
        self.totalTimeMinutes = totalTimeMinutes ?? prepTimeMinutes + cookingTimeMinutes
        self.calories = calories
        self.servings = servings
        self.difficulty = difficulty
        self.tags = tags
        self.imageName = imageName
        self.isPremium = isPremium
        self.isCommunityRecipe = isCommunityRecipe
        self.ingredients = ingredients
        self.instructions = instructions
        self.nutrition = nutrition ?? RecipeNutrition.estimated(calories: calories, tags: tags)
        self.equipment = equipment
        self.tips = tips
    }

    var prepTimeText: String {
        "\(prepTimeMinutes) min"
    }

    var cookingTimeText: String {
        "\(cookingTimeMinutes) min"
    }

    var totalTimeText: String {
        "\(totalTimeMinutes) min"
    }

    var caloriesText: String {
        "\(calories) cal"
    }

    var servingsText: String {
        servings == 1 ? "1 serving" : "\(servings) servings"
    }
}

struct RecipeNutrition: Hashable, Codable {
    let calories: Int
    let proteinGrams: Int
    let carbsGrams: Int
    let fatGrams: Int
    let fiberGrams: Int
    let sugarGrams: Int
    let sodiumMilligrams: Int

    static func estimated(calories: Int, tags: [String]) -> RecipeNutrition {
        let isHighProtein = tags.contains("highProtein")
        let isLowCarb = tags.contains("lowCarb")

        return RecipeNutrition(
            calories: calories,
            proteinGrams: isHighProtein ? max(28, calories / 14) : max(10, calories / 28),
            carbsGrams: isLowCarb ? max(12, calories / 34) : max(22, calories / 10),
            fatGrams: max(8, calories / 32),
            fiberGrams: max(3, calories / 95),
            sugarGrams: max(3, calories / 110),
            sodiumMilligrams: max(280, calories + 120)
        )
    }
}

enum RecipeDifficulty: String, CaseIterable, Identifiable, Codable {
    case easy
    case moderate
    case advanced

    var id: String { rawValue }

    var title: String {
        switch self {
        case .easy:
            return "Easy"
        case .moderate:
            return "Moderate"
        case .advanced:
            return "Advanced"
        }
    }
}
