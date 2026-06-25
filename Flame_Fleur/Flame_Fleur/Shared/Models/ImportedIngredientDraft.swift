import Foundation

struct ImportedIngredientDraft: Identifiable, Hashable, Codable {
    let id: String
    var rawText: String
    var quantity: Double?
    var unit: String?
    var name: String
    var matchedCatalogItemID: String?

    init(
        id: String? = nil,
        rawText: String,
        quantity: Double? = nil,
        unit: String? = nil,
        name: String? = nil,
        matchedCatalogItemID: String? = nil
    ) {
        let trimmedRawText = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        self.id = id ?? ImportedIngredientDraft.stableID(for: trimmedRawText)
        self.rawText = trimmedRawText
        self.quantity = quantity
        self.unit = unit?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.name = (name?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty ?? trimmedRawText)
        self.matchedCatalogItemID = matchedCatalogItemID
    }

    var isMatched: Bool {
        matchedCatalogItemID?.isEmpty == false
    }

    var displayText: String {
        let resolvedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return resolvedName.isEmpty ? rawText : resolvedName
    }

    private static func stableID(for rawText: String) -> String {
        let token = normalize(rawText)
            .replacingOccurrences(of: #"[^\w]+"#, with: "_", options: .regularExpression)
            .replacingOccurrences(of: #"_+"#, with: "_", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "_"))
        return token.isEmpty ? UUID().uuidString.lowercased() : "imported_ingredient_\(token)"
    }

    private static func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
    }
}

private extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
