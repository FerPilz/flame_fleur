import Foundation

enum RecipeImportResult: Codable, Hashable {
    case success(ImportedRecipeDraft)
    case partial(ImportedRecipeDraft, warnings: [RecipeImportWarning])
    case failure(RecipeImportError)

    private enum CodingKeys: String, CodingKey {
        case kind
        case draft
        case warnings
        case error
    }

    private enum Kind: String, Codable {
        case success
        case partial
        case failure
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .success(let draft):
            try container.encode(Kind.success, forKey: .kind)
            try container.encode(draft, forKey: .draft)
        case .partial(let draft, let warnings):
            try container.encode(Kind.partial, forKey: .kind)
            try container.encode(draft, forKey: .draft)
            try container.encode(warnings, forKey: .warnings)
        case .failure(let error):
            try container.encode(Kind.failure, forKey: .kind)
            try container.encode(error, forKey: .error)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)

        switch kind {
        case .success:
            self = .success(try container.decode(ImportedRecipeDraft.self, forKey: .draft))
        case .partial:
            self = .partial(
                try container.decode(ImportedRecipeDraft.self, forKey: .draft),
                warnings: try container.decodeIfPresent([RecipeImportWarning].self, forKey: .warnings) ?? []
            )
        case .failure:
            self = .failure(try container.decode(RecipeImportError.self, forKey: .error))
        }
    }
}
