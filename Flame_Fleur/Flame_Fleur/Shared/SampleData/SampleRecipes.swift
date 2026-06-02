import Foundation

enum SampleRecipes {
    static let all: [Recipe] = loadSeedRecipes()
    static let seedCoverage = RecipeSeedCoverage(
        recipes: all,
        expectedSubcategoryIDs: SampleExploreCategories.groups.flatMap { group in
            group.subcategories.map(\.id)
        }
    )

    private static func loadSeedRecipes(bundle: Bundle = .main) -> [Recipe] {
        let candidateURLs = [
            bundle.url(forResource: "recipes.seed", withExtension: "json"),
            bundle.url(forResource: "recipes.seed", withExtension: "json", subdirectory: "Resources")
        ]

        guard let url = candidateURLs.compactMap({ $0 }).first,
              let data = try? Data(contentsOf: url),
              let recipes = try? JSONDecoder().decode([Recipe].self, from: data),
              !recipes.isEmpty else {
            return fallbackRecipes
        }

        return recipes
    }

    private static let fallbackRecipes: [Recipe] = [
        Recipe(
            id: "recipe-fallback-featured-salmon",
            title: "Creamy Lemon Herb Salmon",
            subtitle: "Light, fresh & zesty",
            categoryGroupID: "meat-seafood",
            subcategoryID: "meat-seafood-salmon",
            subcategoryTitle: "Salmon",
            category: .fish,
            sectionTags: [.featured],
            cookingTimeMinutes: 30,
            calories: 650,
            servings: 2,
            difficulty: .easy,
            tags: ["easy", "quick", "highProtein"],
            imageName: "salmon",
            ingredients: ["salmon", "lemon", "olive oil", "fresh herbs", "garlic"],
            instructions: ["Season the salmon.", "Cook until tender.", "Finish with herbs and lemon."]
        ),
        Recipe(
            id: "recipe-fallback-community-lentil-soup",
            title: "Hearty Lentil Soup",
            subtitle: "Cozy bowl",
            categoryGroupID: "vegetarian",
            subcategoryID: "vegetarian-beans-lentils",
            subcategoryTitle: "Beans & Lentils",
            creatorName: "@homechef.anna",
            creatorAvatarName: "avatar-anna",
            category: .beansLentils,
            sectionTags: [.community],
            cookingTimeMinutes: 40,
            calories: 360,
            servings: 4,
            difficulty: .easy,
            tags: ["community", "easy", "vegetarian"],
            imageName: "bowl",
            isCommunityRecipe: true,
            ingredients: ["lentils", "vegetable stock", "carrots", "garlic", "fresh herbs"],
            instructions: ["Soften the vegetables.", "Simmer with lentils and stock.", "Season and serve warm."]
        ),
        Recipe(
            id: "recipe-fallback-top-butter-chicken",
            title: "Butter Chicken",
            subtitle: "Silky tomato",
            categoryGroupID: "chicken",
            subcategoryID: "chicken-chicken-curry",
            subcategoryTitle: "Chicken Curry",
            category: .chicken,
            sectionTags: [.topPicks],
            cookingTimeMinutes: 35,
            calories: 480,
            servings: 3,
            difficulty: .moderate,
            tags: ["familyFriendly", "highProtein"],
            imageName: "bowl",
            ingredients: ["chicken", "tomatoes", "Greek yogurt", "garlic", "ginger"],
            instructions: ["Brown the chicken.", "Simmer the sauce.", "Fold together and serve."]
        ),
        Recipe(
            id: "recipe-fallback-ai-pantry-pasta",
            title: "Pantry Pasta",
            subtitle: "Simple, silky sauce",
            categoryGroupID: "bakery",
            subcategoryID: "bakery-savory-bakes",
            subcategoryTitle: "Savory Bakes",
            category: .bakery,
            sectionTags: [.aiRecommended],
            cookingTimeMinutes: 18,
            calories: 420,
            servings: 2,
            difficulty: .easy,
            tags: ["easy", "quick"],
            imageName: "pasta",
            ingredients: ["pasta", "olive oil", "garlic", "parmesan", "fresh herbs"],
            instructions: ["Boil the pasta.", "Make a quick sauce.", "Toss together and serve."]
        )
    ]
}

struct RecipeSeedCoverage {
    let totalRecipeCount: Int
    let totalSubcategoryCount: Int
    let missingSubcategoryIDs: [String]
    let invalidSubcategoryCounts: [String: Int]

    init(recipes: [Recipe], expectedSubcategoryIDs: [String]) {
        let counts = Dictionary(grouping: recipes.compactMap(\.subcategoryID), by: { $0 })
            .mapValues(\.count)
        let expectedIDs = Set(expectedSubcategoryIDs)

        self.totalRecipeCount = recipes.count
        self.totalSubcategoryCount = counts.keys.count
        self.missingSubcategoryIDs = expectedSubcategoryIDs.filter { counts[$0] == nil }
        self.invalidSubcategoryCounts = counts.filter { subcategoryID, count in
            expectedIDs.contains(subcategoryID) && count != 6
        }
    }

    var hasExactlySixRecipesPerSubcategory: Bool {
        missingSubcategoryIDs.isEmpty && invalidSubcategoryCounts.isEmpty
    }
}
