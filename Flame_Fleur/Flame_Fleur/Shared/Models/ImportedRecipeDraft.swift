import Foundation

struct ImportedRecipeDraft: Identifiable, Hashable, Codable {
    let id: String
    var title: String
    var sourceURL: URL
    var sourceHost: String?
    var imageURL: URL?
    var localImageName: String?
    var localImagePath: String?
    var servings: Int?
    var prepTimeMinutes: Int?
    var cookTimeMinutes: Int?
    var totalTimeMinutes: Int?
    var ingredients: [ImportedIngredientDraft]
    var instructions: [String]
    var notes: String?
    var importedAt: Date
    var parserSource: RecipeImportParserSource

    init(
        id: String? = nil,
        title: String,
        sourceURL: URL,
        sourceHost: String? = nil,
        imageURL: URL? = nil,
        localImageName: String? = nil,
        localImagePath: String? = nil,
        servings: Int? = nil,
        prepTimeMinutes: Int? = nil,
        cookTimeMinutes: Int? = nil,
        totalTimeMinutes: Int? = nil,
        ingredients: [ImportedIngredientDraft] = [],
        instructions: [String] = [],
        notes: String? = nil,
        importedAt: Date = .now,
        parserSource: RecipeImportParserSource = .manualFallback
    ) {
        self.id = id ?? ImportedRecipeDraft.stableID(title: title, sourceURL: sourceURL)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceURL = sourceURL
        self.sourceHost = sourceHost ?? sourceURL.host
        self.imageURL = imageURL
        self.localImageName = localImageName
        self.localImagePath = localImagePath
        self.servings = servings
        self.prepTimeMinutes = prepTimeMinutes
        self.cookTimeMinutes = cookTimeMinutes
        self.totalTimeMinutes = totalTimeMinutes
        self.ingredients = ingredients
        self.instructions = instructions.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        self.notes = notes
        self.importedAt = importedAt
        self.parserSource = parserSource
    }

    var hasResolvedSourceHost: Bool {
        sourceHost?.isEmpty == false
    }

    var resolvedTotalTimeMinutes: Int? {
        if let totalTimeMinutes {
            return totalTimeMinutes
        }
        if let prepTimeMinutes, let cookTimeMinutes {
            return prepTimeMinutes + cookTimeMinutes
        }
        return nil
    }

    private static func stableID(title: String, sourceURL: URL) -> String {
        let token = [title, sourceURL.absoluteString]
            .map { normalize($0) }
            .joined(separator: "_")
            .replacingOccurrences(of: #"[^\w]+"#, with: "_", options: .regularExpression)
            .replacingOccurrences(of: #"_+"#, with: "_", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "_"))
        return token.isEmpty ? UUID().uuidString.lowercased() : "imported_recipe_\(token)"
    }

    private static func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
    }
}
