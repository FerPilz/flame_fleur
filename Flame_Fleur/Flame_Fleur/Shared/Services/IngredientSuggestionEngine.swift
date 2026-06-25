import Foundation

enum IngredientSuggestionEngine {
    static func suggestions(
        for query: String,
        limit: Int = 6,
        catalog: [ShoppingIngredientCatalogItem] = SampleShoppingIngredientCatalog.all
    ) -> [ShoppingIngredientCatalogItem] {
        let normalizedQuery = normalize(query)
        guard !normalizedQuery.isEmpty else { return [] }

        let filtered = catalog.filter { item in
            let normalizedName = normalize(item.displayName)
            let catalogName = normalize(item.normalizedName)
            return normalizedName.contains(normalizedQuery) || catalogName.contains(normalizedQuery)
        }

        let sorted = filtered.sorted { lhs, rhs in
            score(lhs, query: normalizedQuery) > score(rhs, query: normalizedQuery)
        }

        var seen = Set<String>()
        return Array(sorted.compactMap { item in
            let key = normalize(item.normalizedName)
            guard !key.isEmpty, seen.insert(key).inserted else { return nil }
            return item
        }.prefix(limit))
    }

    static func hasExactMatch(for query: String, in catalog: [ShoppingIngredientCatalogItem] = SampleShoppingIngredientCatalog.all) -> Bool {
        let normalizedQuery = normalize(query)
        guard !normalizedQuery.isEmpty else { return false }

        return catalog.contains { item in
            normalize(item.normalizedName) == normalizedQuery || normalize(item.displayName) == normalizedQuery
        }
    }

    static func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: #"[^\p{L}\p{N}]+"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func score(_ item: ShoppingIngredientCatalogItem, query: String) -> Int {
        let normalizedDisplay = normalize(item.displayName)
        let normalizedCatalog = normalize(item.normalizedName)

        if normalizedDisplay == query || normalizedCatalog == query {
            return 4
        }

        if normalizedDisplay.hasPrefix(query) || normalizedCatalog.hasPrefix(query) {
            return 3
        }

        if normalizedDisplay.contains(query) || normalizedCatalog.contains(query) {
            return 2
        }

        return 1
    }
}
