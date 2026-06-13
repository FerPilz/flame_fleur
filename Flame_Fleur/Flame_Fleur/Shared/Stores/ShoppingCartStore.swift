import Combine
import Foundation

final class ShoppingCartStore: ObservableObject {
    static let shared = ShoppingCartStore(items: SampleShoppingCartItems.currentWeek)

    @Published private(set) var items: [ShoppingCartItem]

    init(items: [ShoppingCartItem] = []) {
        self.items = items
    }

    func addItem(_ item: ShoppingCartItem) {
        if let existingIndex = items.firstIndex(where: { existingItem in
            existingItem.name.caseInsensitiveCompare(item.name) == .orderedSame
            && existingItem.unit == item.unit
            && existingItem.category == item.category
            && existingItem.storeName == item.storeName
        }) {
            items[existingIndex].quantity += item.quantity
        } else {
            items.append(item)
        }
    }

    func addItems(_ newItems: [ShoppingCartItem]) {
        newItems.forEach(addItem)
    }

    func removeItem(_ item: ShoppingCartItem) {
        removeItem(id: item.id)
    }

    func removeItem(id: ShoppingCartItem.ID) {
        items.removeAll { $0.id == id }
    }

    func incrementQuantity(for itemID: ShoppingCartItem.ID) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[index].quantity += 1
    }

    func decrementQuantity(for itemID: ShoppingCartItem.ID) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[index].quantity = max(1, items[index].quantity - 1)
    }

    func updateStore(for itemID: ShoppingCartItem.ID, to store: ShoppingStoreOption) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[index].storeName = store.displayName
    }

    func toggleChecked(for itemID: ShoppingCartItem.ID) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[index].isChecked.toggle()
    }

    func clearChecked() {
        items.removeAll(where: \.isChecked)
    }

    var groupedItems: [ShoppingCartCategory: [ShoppingCartItem]] {
        Dictionary(grouping: items, by: \.category)
    }

    func items(for category: ShoppingCartCategory) -> [ShoppingCartItem] {
        groupedItems[category, default: []]
    }

    var populatedCategories: [ShoppingCartCategory] {
        ShoppingCartCategory.allCases.filter { !items(for: $0).isEmpty }
    }

    var totalEstimatedCost: Double {
        items.reduce(0) { $0 + $1.estimatedLineCost }
    }

    var totalItemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var categoryCount: Int {
        Set(items.map(\.category)).count
    }

    var cartSummaryText: String {
        let itemLines = items.map { item in
            "- \(item.name): \(item.quantityText) at \(item.storeName)"
        }
        .joined(separator: "\n")

        return """
        Flame & Fleur Shopping Cart
        Estimated total: \(Self.currencyString(totalEstimatedCost))
        Items: \(totalItemCount)

        \(itemLines)
        """
    }

    static func currencyString(_ value: Double) -> String {
        value.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }
}
