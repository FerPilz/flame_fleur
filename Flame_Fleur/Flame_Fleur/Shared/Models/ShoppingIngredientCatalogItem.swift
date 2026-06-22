import Foundation

struct ShoppingIngredientCatalogItem: Identifiable, Hashable, Codable {
    let id: String
    let displayName: String
    let normalizedName: String
    let category: String
    let defaultUnit: String
    let estimatedPrice: Double
    let imageName: String?
}
