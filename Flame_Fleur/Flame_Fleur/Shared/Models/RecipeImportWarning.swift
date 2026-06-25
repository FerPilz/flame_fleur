import Foundation

enum RecipeImportWarning: String, Codable, Hashable, CaseIterable {
    case missingTitle
    case missingIngredients
    case missingInstructions
    case missingImage
    case partialParse

    var displayText: String {
        switch self {
        case .missingTitle:
            return "Title was missing; CookFlow used a fallback title."
        case .missingIngredients:
            return "No ingredient list was found."
        case .missingInstructions:
            return "No instruction steps were found."
        case .missingImage:
            return "No image was found on the page."
        case .partialParse:
            return "Only part of the recipe could be imported."
        }
    }
}
