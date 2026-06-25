import Foundation

enum ImportedRecipeDraftValidationError: String, Error, Hashable, LocalizedError {
    case missingTitle
    case missingIngredients
    case missingInstructions

    var errorDescription: String? {
        switch self {
        case .missingTitle:
            return "Add a recipe title before saving."
        case .missingIngredients:
            return "Add at least one ingredient before saving."
        case .missingInstructions:
            return "Add at least one instruction before saving."
        }
    }
}
