import Combine
import Foundation

struct SavedShoppingCart: Identifiable, Hashable {
    let id: UUID
    let name: String
    let savedAt: Date
    let estimatedTotal: Double
    let items: [ShoppingCartItem]

    init(
        id: UUID = UUID(),
        name: String,
        savedAt: Date = Date(),
        estimatedTotal: Double,
        items: [ShoppingCartItem]
    ) {
        self.id = id
        self.name = name
        self.savedAt = savedAt
        self.estimatedTotal = estimatedTotal
        self.items = items
    }

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
}

final class ShoppingCartStore: ObservableObject {
    static let shared = ShoppingCartStore(items: SampleShoppingCartItems.currentWeek)

    @Published private(set) var items: [ShoppingCartItem]
    @Published private(set) var savedCarts: [SavedShoppingCart]

    init(items: [ShoppingCartItem] = [], savedCarts: [SavedShoppingCart] = []) {
        self.items = items
        self.savedCarts = savedCarts
    }

    func addItem(_ item: ShoppingCartItem) {
        if let existingIndex = items.firstIndex(where: { existingItem in
            existingItem.normalizedName == item.normalizedName
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

    func addRecipeIngredients(
        _ ingredients: [RecipeIngredient],
        from recipe: Recipe? = nil,
        selectedIngredientIndexes: Set<Int>? = nil
    ) {
        let chosenIngredients: [RecipeIngredient]
        if let selectedIngredientIndexes {
            chosenIngredients = ingredients.enumerated().compactMap { index, ingredient in
                selectedIngredientIndexes.contains(index) ? ingredient : nil
            }
        } else {
            chosenIngredients = ingredients
        }

        let itemsToAdd = chosenIngredients.map { ingredient in
            shoppingCartItem(for: ingredient, from: recipe)
        }

        addItems(itemsToAdd)
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

    var selectedItems: [ShoppingCartItem] {
        items.filter(\.isChecked)
    }

    var selectedItemCount: Int {
        selectedItems.count
    }

    var hasSelectedItems: Bool {
        !selectedItems.isEmpty
    }

    @discardableResult
    func saveCurrentCart(named name: String) -> SavedShoppingCart {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let savedCart = SavedShoppingCart(
            name: trimmedName.isEmpty ? "Untitled Cart" : trimmedName,
            estimatedTotal: totalEstimatedCost,
            items: items
        )
        savedCarts.insert(savedCart, at: 0)
        return savedCart
    }

    func restoreCart(_ savedCart: SavedShoppingCart) {
        items = savedCart.items
    }

    func clearChecked() {
        items.removeAll(where: \.isChecked)
    }

    func removeSelectedItems() {
        clearChecked()
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

    var recipeNutritionSummary: NutritionSummary {
        NutritionCalculator.summary(from: items) { RecipeRepository.shared.recipe(id: $0) }
    }

    var recipeMacroBalance: MacroBalance {
        MacroBalance(summary: recipeNutritionSummary)
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

    private func shoppingCartItem(for ingredient: RecipeIngredient, from recipe: Recipe?) -> ShoppingCartItem {
        let normalizedName = ingredient.normalizedName
        let catalogItem = SampleShoppingIngredientCatalog.byNormalizedName[normalizedName]

        let category = catalogItem.map {
            ShoppingCartStore.shoppingCategory(from: $0.category)
        } ?? ShoppingCartStore.shoppingCategory(from: ingredient.category)

        let displayName = catalogItem?.displayName ?? ingredient.name
        let unit = ingredient.unit.isEmpty ? (catalogItem?.defaultUnit ?? "") : ingredient.unit
        let price = catalogItem?.estimatedPrice ?? ShoppingCartStore.defaultPrice(for: category)
        let imageName = catalogItem?.imageName ?? ShoppingCartStore.defaultImageName(for: category)
        let storeName = ShoppingCartStore.defaultStore(for: category).displayName

        return ShoppingCartItem(
            name: displayName,
            quantity: 1,
            unit: unit,
            displayQuantity: ingredient.displayLine,
            category: category,
            price: price,
            storeName: storeName,
            imageName: imageName,
            sourceRecipeID: recipe?.id,
            sourceRecipeTitle: recipe?.title,
            notes: ingredient.notes
        )
    }

    private static func shoppingCategory(from value: String) -> ShoppingCartCategory {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        switch normalized {
        case "produce":
            return .produce
        case "dairy":
            return .dairy
        case "protein":
            return .protein
        case "pantry":
            return .pantry
        case "frozen":
            return .frozen
        case "bakery":
            return .bakery
        default:
            return .other
        }
    }

    private static func defaultPrice(for category: ShoppingCartCategory) -> Double {
        switch category {
        case .produce:
            return 2.49
        case .dairy:
            return 3.29
        case .protein:
            return 7.49
        case .pantry:
            return 2.99
        case .frozen:
            return 4.99
        case .bakery:
            return 4.49
        case .other:
            return 2.19
        }
    }

    private static func defaultImageName(for category: ShoppingCartCategory) -> String? {
        switch category {
        case .produce:
            return "salad"
        case .dairy:
            return "citrus"
        case .protein:
            return "salmon"
        case .pantry:
            return "pasta"
        case .frozen:
            return "bowl"
        case .bakery:
            return "dessert"
        case .other:
            return nil
        }
    }

    private static func defaultStore(for category: ShoppingCartCategory) -> ShoppingStoreOption {
        switch category {
        case .protein:
            return .costco
        case .dairy:
            return .wholeFoods
        case .bakery:
            return .localMarket
        case .pantry:
            return .traderJoes
        case .frozen:
            return .costco
        case .produce, .other:
            return .wholeFoods
        }
    }
}
