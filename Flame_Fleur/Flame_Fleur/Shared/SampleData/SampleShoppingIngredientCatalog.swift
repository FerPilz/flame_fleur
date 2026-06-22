import Foundation

enum SampleShoppingIngredientCatalog {
    static let all: [ShoppingIngredientCatalogItem] = loadCatalog()

    static let byNormalizedName: [String: ShoppingIngredientCatalogItem] = Dictionary(
        uniqueKeysWithValues: all.map { ($0.normalizedName, $0) }
    )

    private static func loadCatalog(bundle: Bundle = .main) -> [ShoppingIngredientCatalogItem] {
        let candidateURLs = [
            bundle.url(forResource: "shopping_ingredients.seed.full", withExtension: "json"),
            bundle.url(forResource: "shopping_ingredients.seed.sample", withExtension: "json"),
            bundle.url(forResource: "shopping_ingredients.seed.full", withExtension: "json", subdirectory: "Resources"),
            bundle.url(forResource: "shopping_ingredients.seed.sample", withExtension: "json", subdirectory: "Resources")
        ]

        for url in candidateURLs.compactMap({ $0 }) {
            if let data = try? Data(contentsOf: url),
               let items = try? JSONDecoder().decode([ShoppingIngredientCatalogItem].self, from: data),
               !items.isEmpty {
                return items
            }
        }

        return []
    }
}
