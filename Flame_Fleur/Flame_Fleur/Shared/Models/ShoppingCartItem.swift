import Foundation

struct ShoppingCartItem: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var quantity: Int
    var unit: String
    var displayQuantity: String?
    var category: ShoppingCartCategory
    var price: Double
    var storeName: String
    var imageName: String?
    var sourceRecipeID: String?
    var sourceRecipeTitle: String?
    var isChecked: Bool
    var notes: String?

    init(
        id: UUID = UUID(),
        name: String,
        quantity: Int = 1,
        unit: String,
        displayQuantity: String? = nil,
        category: ShoppingCartCategory,
        price: Double,
        storeName: String = ShoppingStoreOption.localMarket.displayName,
        imageName: String? = nil,
        sourceRecipeID: String? = nil,
        sourceRecipeTitle: String? = nil,
        isChecked: Bool = false,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.quantity = max(1, quantity)
        self.unit = unit
        self.displayQuantity = displayQuantity
        self.category = category
        self.price = price
        self.storeName = storeName
        self.imageName = imageName
        self.sourceRecipeID = sourceRecipeID
        self.sourceRecipeTitle = sourceRecipeTitle
        self.isChecked = isChecked
        self.notes = notes
    }

    var estimatedLineCost: Double {
        price * Double(quantity)
    }

    var quantityText: String {
        if let displayQuantity = displayQuantity?.trimmingCharacters(in: .whitespacesAndNewlines),
           !displayQuantity.isEmpty {
            return displayQuantity
        }

        return unit.isEmpty ? "\(quantity)" : "\(quantity) \(unit)"
    }

    var normalizedName: String {
        name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: #"[^\p{L}\p{N}]+"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
