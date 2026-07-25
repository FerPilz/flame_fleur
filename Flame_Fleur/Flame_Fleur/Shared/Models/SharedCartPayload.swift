import Foundation

struct SharedCartPayload: Codable, Hashable {
    static let schemaVersionValue = 1
    static let sourceAppValue = "AllSpiced"

    let schemaVersion: Int
    let sourceApp: String
    let exportedAt: Date
    let cartName: String?
    let items: [SharedCartItem]

    init(
        exportedAt: Date = Date(),
        cartName: String? = nil,
        items: [SharedCartItem]
    ) {
        self.schemaVersion = Self.schemaVersionValue
        self.sourceApp = Self.sourceAppValue
        self.exportedAt = exportedAt
        self.cartName = cartName
        self.items = items
    }
}

struct SharedCartItem: Codable, Hashable {
    let name: String?
    let quantity: Int?
    let unit: String?
    let category: String?
    let storeName: String?
    let isChecked: Bool?
    let price: Double?
    let notes: String?
    let displayQuantity: String?
}

struct SharedCartImportSummary {
    let importedItemCount: Int
    let unresolvedItemCount: Int
}
