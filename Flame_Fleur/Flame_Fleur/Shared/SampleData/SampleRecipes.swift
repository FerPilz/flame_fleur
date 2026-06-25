import Foundation

enum SampleRecipes {
    static let all: [Recipe] = uniqueRecipes(loadSeedRecipes() + CookflowSnacksBreakfastSeed.recipes)
    static let seedCoverage = RecipeSeedCoverage(
        recipes: all,
        expectedRecipeCountsBySubcategoryID: Dictionary(
            uniqueKeysWithValues: SampleExploreCategories.groups.flatMap { group in
                group.subcategories.map { subcategory in
                    let expectedCount: Int
                    if subcategory.id == "breakfast-egg-based" {
                        expectedCount = 6
                    } else {
                        expectedCount = ["snacks", "breakfast"].contains(subcategory.parentGroupID) ? 5 : 6
                    }
                    return (subcategory.id, expectedCount)
                }
            }
        )
    )

    private static func loadSeedRecipes(bundle: Bundle = .main) -> [Recipe] {
        let candidateURLs = [
            bundle.url(forResource: "recipes.seed.enriched.full", withExtension: "json"),
            bundle.url(forResource: "recipes.seed", withExtension: "json"),
            bundle.url(forResource: "recipes.seed.enriched.full", withExtension: "json", subdirectory: "Resources"),
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

    private static func uniqueRecipes(_ recipes: [Recipe]) -> [Recipe] {
        var seenIDs = Set<String>()
        return recipes.filter { seenIDs.insert($0.id).inserted }
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
            imageName: "ff_home_recipe_meat_seafood_fish_honey_garlic_salmon",
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
            imageName: "ff_home_recipe_world_cuisine_italian_spicy_tomato_basil_pasta",
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

    init(recipes: [Recipe], expectedRecipeCountsBySubcategoryID: [String: Int]) {
        let counts = Dictionary(grouping: recipes.compactMap(\.subcategoryID), by: { $0 })
            .mapValues(\.count)
        let expectedIDs = Set(expectedRecipeCountsBySubcategoryID.keys)

        self.totalRecipeCount = recipes.count
        self.totalSubcategoryCount = counts.keys.count
        self.missingSubcategoryIDs = expectedRecipeCountsBySubcategoryID.keys.filter { counts[$0] == nil }
        self.invalidSubcategoryCounts = counts.filter { subcategoryID, count in
            expectedIDs.contains(subcategoryID) && count != expectedRecipeCountsBySubcategoryID[subcategoryID, default: count]
        }
    }

    var hasExpectedRecipeCountPerSubcategory: Bool {
        missingSubcategoryIDs.isEmpty && invalidSubcategoryCounts.isEmpty
    }
}
