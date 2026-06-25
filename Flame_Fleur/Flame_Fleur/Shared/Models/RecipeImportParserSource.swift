import Foundation

enum RecipeImportParserSource: String, Codable, Hashable {
    case jsonLD
    case htmlFallback
    case manualFallback
}
