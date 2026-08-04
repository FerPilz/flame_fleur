import Foundation

enum IngredientSuggestionEngine {
    static func suggestions(
        for query: String,
        limit: Int = 20,
        catalog: [ShoppingIngredientCatalogItem] = SampleShoppingIngredientCatalog.all
    ) -> [ShoppingIngredientCatalogItem] {
        let normalizedQuery = normalize(query)
        guard !normalizedQuery.isEmpty else { return [] }

        let filtered = catalog.filter { item in
            item.normalizedName.contains(normalizedQuery)
        }

        let sorted = filtered.sorted { lhs, rhs in
            let lhsScore = score(lhs, query: normalizedQuery)
            let rhsScore = score(rhs, query: normalizedQuery)

            if lhsScore != rhsScore {
                return lhsScore > rhsScore
            }

            return lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) == .orderedAscending
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
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: #"[^\p{L}\p{N}]+"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func score(_ item: ShoppingIngredientCatalogItem, query: String) -> Int {
        if item.normalizedName == query {
            return 4
        }

        if item.normalizedName.hasPrefix(query) {
            return 3
        }

        if item.normalizedName.contains(query) {
            return 2
        }

        return 1
    }
}
