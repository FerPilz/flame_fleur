import Foundation

enum RecipeSeedLoader {
    static func loadRecipes(
        bundle: Bundle = .main,
        fallbackRecipes: @autoclosure () -> [Recipe] = []
    ) -> [Recipe] {
        let seededRecipes = uniqueRecipes(loadPrimarySeedRecipes(bundle: bundle) + CookflowSnacksBreakfastSeed.recipes)

        guard !seededRecipes.isEmpty else {
            return uniqueRecipes(fallbackRecipes() + CookflowSnacksBreakfastSeed.recipes)
        }

        return seededRecipes
    }

    private static func loadPrimarySeedRecipes(bundle: Bundle) -> [Recipe] {
        let candidateURLs = [
            bundle.url(forResource: "recipes.seed", withExtension: "json"),
            bundle.url(forResource: "recipes.seed.enriched.full", withExtension: "json"),
            bundle.url(forResource: "recipes.seed", withExtension: "json", subdirectory: "Resources"),
            bundle.url(forResource: "recipes.seed.enriched.full", withExtension: "json", subdirectory: "Resources")
        ]

        guard let url = candidateURLs.compactMap({ $0 }).first,
              let data = try? Data(contentsOf: url),
              let recipes = try? JSONDecoder().decode([Recipe].self, from: data) else {
            return []
        }

        return recipes
    }

    private static func uniqueRecipes(_ recipes: [Recipe]) -> [Recipe] {
        var seenIDs = Set<String>()
        return recipes.filter { seenIDs.insert($0.id).inserted }
    }
}
