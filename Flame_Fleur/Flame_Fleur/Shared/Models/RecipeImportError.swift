import Foundation

enum RecipeImportError: String, Error, Codable, Hashable, LocalizedError {
    case invalidURL
    case networkFailure
    case emptyResponse
    case noRecipeFound
    case parsingFailed
    case unsupportedPage
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Enter a valid recipe URL."
        case .networkFailure:
            return "CookFlow could not load that page."
        case .emptyResponse:
            return "The page returned no content."
        case .noRecipeFound:
            return "No recipe data was found on that page."
        case .parsingFailed:
            return "CookFlow could not parse the recipe data."
        case .unsupportedPage:
            return "That page format is not supported yet."
        case .unknown:
            return "Something went wrong while importing the recipe."
        }
    }
}
