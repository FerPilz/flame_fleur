import Foundation

struct Recipe: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let creatorName: String?
    let creatorAvatarName: String?
    let category: RecipeCategory
    let sectionTags: Set<RecipeSectionTag>
    let cookingTimeMinutes: Int
    let calories: Int
    let servings: Int
    let difficulty: RecipeDifficulty
    let imageName: String?
    let isPremium: Bool
    let isCommunityRecipe: Bool

    init(
        id: String,
        title: String,
        subtitle: String,
        creatorName: String? = nil,
        creatorAvatarName: String? = nil,
        category: RecipeCategory,
        sectionTags: [RecipeSectionTag],
        cookingTimeMinutes: Int,
        calories: Int,
        servings: Int,
        difficulty: RecipeDifficulty,
        imageName: String? = nil,
        isPremium: Bool = false,
        isCommunityRecipe: Bool = false
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.creatorName = creatorName
        self.creatorAvatarName = creatorAvatarName
        self.category = category
        self.sectionTags = Set(sectionTags)
        self.cookingTimeMinutes = cookingTimeMinutes
        self.calories = calories
        self.servings = servings
        self.difficulty = difficulty
        self.imageName = imageName
        self.isPremium = isPremium
        self.isCommunityRecipe = isCommunityRecipe
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

enum RecipeDifficulty: String, CaseIterable, Identifiable {
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
