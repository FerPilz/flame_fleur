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
    let structuredIngredients: [RecipeIngredient]
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
        structuredIngredients: [RecipeIngredient] = [],
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

        let resolvedStructuredIngredients = structuredIngredients.isEmpty
            ? ingredients.map { RecipeIngredient(legacyName: $0) }
            : structuredIngredients
        self.structuredIngredients = resolvedStructuredIngredients
        self.ingredients = ingredients.isEmpty
            ? resolvedStructuredIngredients.map(\.name)
            : ingredients

        self.instructions = instructions
        self.nutrition = nutrition ?? RecipeNutrition.estimated(calories: calories, tags: tags)
        self.equipment = equipment
        self.tips = tips
    }

    var prepMinutes: Int { prepTimeMinutes }
    var cookMinutes: Int { cookingTimeMinutes }
    var totalMinutes: Int { totalTimeMinutes }
    var caloriesPerServing: Int { calories }
    var nutritionPerServing: RecipeNutrition { nutrition }

    var ingredientLines: [String] {
        structuredIngredients.map(\.displayLine)
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

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case subtitle
        case description
        case categoryGroupID
        case subcategoryID
        case subcategoryTitle
        case creatorName
        case creatorAvatarName
        case category
        case sectionTags
        case prepTimeMinutes
        case prepMinutes
        case cookingTimeMinutes
        case cookMinutes
        case totalTimeMinutes
        case totalMinutes
        case calories
        case caloriesPerServing
        case servings
        case difficulty
        case tags
        case imageName
        case isPremium
        case isCommunityRecipe
        case ingredients
        case instructions
        case nutrition
        case nutritionPerServing
        case equipment
        case tips
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let title = try container.decode(String.self, forKey: .title)
        let subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle) ?? ""
        let description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        let category = try container.decode(RecipeCategory.self, forKey: .category)
        let difficulty = try container.decode(RecipeDifficulty.self, forKey: .difficulty)
        let tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []

        let prepTimeMinutes = try container.decodeIfPresent(Int.self, forKey: .prepTimeMinutes)
            ?? container.decodeIfPresent(Int.self, forKey: .prepMinutes)
            ?? 10
        let cookingTimeMinutes = try container.decodeIfPresent(Int.self, forKey: .cookingTimeMinutes)
            ?? container.decodeIfPresent(Int.self, forKey: .cookMinutes)
            ?? 0
        let totalTimeMinutes = try container.decodeIfPresent(Int.self, forKey: .totalTimeMinutes)
            ?? container.decodeIfPresent(Int.self, forKey: .totalMinutes)
            ?? prepTimeMinutes + cookingTimeMinutes
        let calories = try container.decodeIfPresent(Int.self, forKey: .caloriesPerServing)
            ?? container.decodeIfPresent(Int.self, forKey: .calories)
            ?? 0
        let nutrition = try container.decodeIfPresent(RecipeNutrition.self, forKey: .nutritionPerServing)
            ?? container.decodeIfPresent(RecipeNutrition.self, forKey: .nutrition)
            ?? RecipeNutrition.estimated(calories: calories, tags: tags)

        let structuredIngredients = try container.decodeIfPresent([RecipeIngredient].self, forKey: .ingredients) ?? []
        let instructions = try container.decodeIfPresent([String].self, forKey: .instructions) ?? []

        self.init(
            id: try container.decode(String.self, forKey: .id),
            title: title,
            subtitle: subtitle,
            description: description,
            categoryGroupID: try container.decodeIfPresent(String.self, forKey: .categoryGroupID),
            subcategoryID: try container.decodeIfPresent(String.self, forKey: .subcategoryID),
            subcategoryTitle: try container.decodeIfPresent(String.self, forKey: .subcategoryTitle),
            creatorName: try container.decodeIfPresent(String.self, forKey: .creatorName),
            creatorAvatarName: try container.decodeIfPresent(String.self, forKey: .creatorAvatarName),
            category: category,
            sectionTags: Array(try container.decodeIfPresent(Set<RecipeSectionTag>.self, forKey: .sectionTags) ?? []),
            prepTimeMinutes: prepTimeMinutes,
            cookingTimeMinutes: cookingTimeMinutes,
            totalTimeMinutes: totalTimeMinutes,
            calories: calories,
            servings: try container.decodeIfPresent(Int.self, forKey: .servings) ?? 1,
            difficulty: difficulty,
            tags: tags,
            imageName: try container.decodeIfPresent(String.self, forKey: .imageName),
            isPremium: try container.decodeIfPresent(Bool.self, forKey: .isPremium) ?? false,
            isCommunityRecipe: try container.decodeIfPresent(Bool.self, forKey: .isCommunityRecipe) ?? false,
            ingredients: structuredIngredients.map(\.name),
            structuredIngredients: structuredIngredients,
            instructions: instructions,
            nutrition: nutrition,
            equipment: try container.decodeIfPresent([String].self, forKey: .equipment) ?? [],
            tips: try container.decodeIfPresent([String].self, forKey: .tips) ?? []
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(subtitle, forKey: .subtitle)
        try container.encode(description, forKey: .description)
        try container.encodeIfPresent(categoryGroupID, forKey: .categoryGroupID)
        try container.encodeIfPresent(subcategoryID, forKey: .subcategoryID)
        try container.encodeIfPresent(subcategoryTitle, forKey: .subcategoryTitle)
        try container.encodeIfPresent(creatorName, forKey: .creatorName)
        try container.encodeIfPresent(creatorAvatarName, forKey: .creatorAvatarName)
        try container.encode(category, forKey: .category)
        try container.encode(Array(sectionTags), forKey: .sectionTags)
        try container.encode(prepTimeMinutes, forKey: .prepTimeMinutes)
        try container.encode(prepMinutes, forKey: .prepMinutes)
        try container.encode(cookingTimeMinutes, forKey: .cookingTimeMinutes)
        try container.encode(cookMinutes, forKey: .cookMinutes)
        try container.encode(totalTimeMinutes, forKey: .totalTimeMinutes)
        try container.encode(totalMinutes, forKey: .totalMinutes)
        try container.encode(calories, forKey: .calories)
        try container.encode(caloriesPerServing, forKey: .caloriesPerServing)
        try container.encode(servings, forKey: .servings)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(tags, forKey: .tags)
        try container.encodeIfPresent(imageName, forKey: .imageName)
        try container.encode(isPremium, forKey: .isPremium)
        try container.encode(isCommunityRecipe, forKey: .isCommunityRecipe)
        try container.encode(structuredIngredients, forKey: .ingredients)
        try container.encode(instructions, forKey: .instructions)
        try container.encode(nutrition, forKey: .nutrition)
        try container.encode(nutritionPerServing, forKey: .nutritionPerServing)
        try container.encode(equipment, forKey: .equipment)
        try container.encode(tips, forKey: .tips)
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
