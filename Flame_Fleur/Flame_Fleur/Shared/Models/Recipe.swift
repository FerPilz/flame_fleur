import Foundation

struct Recipe: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let subtitle: String
    let categoryGroupID: String?
    let subcategoryID: String?
    let subcategoryTitle: String?
    let creatorName: String?
    let creatorAvatarName: String?
    let category: RecipeCategory
    let sectionTags: Set<RecipeSectionTag>
    let cookingTimeMinutes: Int
    let calories: Int
    let servings: Int
    let difficulty: RecipeDifficulty
    let tags: [String]
    let imageName: String?
    let isPremium: Bool
    let isCommunityRecipe: Bool
    let ingredients: [String]
    let instructions: [String]

    init(
        id: String,
        title: String,
        subtitle: String,
        categoryGroupID: String? = nil,
        subcategoryID: String? = nil,
        subcategoryTitle: String? = nil,
        creatorName: String? = nil,
        creatorAvatarName: String? = nil,
        category: RecipeCategory,
        sectionTags: [RecipeSectionTag],
        cookingTimeMinutes: Int,
        calories: Int,
        servings: Int,
        difficulty: RecipeDifficulty,
        tags: [String] = [],
        imageName: String? = nil,
        isPremium: Bool = false,
        isCommunityRecipe: Bool = false,
        ingredients: [String] = [],
        instructions: [String] = []
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.categoryGroupID = categoryGroupID
        self.subcategoryID = subcategoryID
        self.subcategoryTitle = subcategoryTitle
        self.creatorName = creatorName
        self.creatorAvatarName = creatorAvatarName
        self.category = category
        self.sectionTags = Set(sectionTags)
        self.cookingTimeMinutes = cookingTimeMinutes
        self.calories = calories
        self.servings = servings
        self.difficulty = difficulty
        self.tags = tags
        self.imageName = imageName
        self.isPremium = isPremium
        self.isCommunityRecipe = isCommunityRecipe
        self.ingredients = ingredients
        self.instructions = instructions
    }

    var cookingTimeText: String {
        "\(cookingTimeMinutes) min"
    }

    var caloriesText: String {
        "\(calories) cal"
    }

    var servingsText: String {
        servings == 1 ? "1 serving" : "\(servings) servings"
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
