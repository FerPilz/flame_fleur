import Combine
import Foundation

struct SavedShoppingCart: Identifiable, Hashable, Codable {
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
    static let shared = ShoppingCartStore()

    private static let persistenceKey = "shoppingCartStore.state.v1"

    @Published private(set) var items: [ShoppingCartItem]
    @Published private(set) var savedCarts: [SavedShoppingCart]

    init(items: [ShoppingCartItem] = [], savedCarts: [SavedShoppingCart] = []) {
        if let persistedState = Self.loadPersistedState() {
            self.items = persistedState.items
            self.savedCarts = persistedState.savedCarts
        } else {
            self.items = items
            self.savedCarts = savedCarts
        }
    }

    func addItem(_ item: ShoppingCartItem, shouldRecordUsage: Bool = true) {
        if let existingIndex = items.firstIndex(where: { existingItem in
            existingItem.normalizedName == item.normalizedName
        }) {
            items[existingIndex].quantity += item.quantity
        } else {
            items.append(item)
        }

        persist()

        if shouldRecordUsage {
            recordCartEvent(type: .cartItemAdded, item: item)
        }
    }

    func item(for catalogItem: ShoppingIngredientCatalogItem, quantity: Int = 1) -> ShoppingCartItem {
        let category = Self.shoppingCategory(from: catalogItem.category)

        return ShoppingCartItem(
            name: catalogItem.displayName,
            quantity: quantity,
            unit: catalogItem.defaultUnit,
            category: category,
            price: catalogItem.estimatedPrice,
            storeName: Self.defaultStore(for: category).displayName,
            imageName: catalogItem.imageName
        )
    }

    func addItems(_ newItems: [ShoppingCartItem], shouldRecordUsage: Bool = true) {
        for item in newItems {
            addItem(item, shouldRecordUsage: shouldRecordUsage)
        }
    }

    func clearCart() {
        let removedItems = items
        items.removeAll()
        persist()
        recordCartEvents(type: .cartItemRemoved, items: removedItems)
    }

    func startNewCart() {
        clearCart()
    }

    func deleteSavedCart(id: UUID) {
        savedCarts.removeAll { $0.id == id }
        persist()
    }

    func addRecipeIngredients(
        _ ingredients: [RecipeIngredient],
        from recipe: Recipe? = nil,
        selectedIngredientIndexes: Set<Int>? = nil,
        shouldRecordUsage: Bool = true
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

        addItems(itemsToAdd, shouldRecordUsage: shouldRecordUsage)
    }

    func removeItem(_ item: ShoppingCartItem) {
        removeItem(id: item.id)
    }

    func removeItem(id: ShoppingCartItem.ID) {
        let removedItems = items.filter { $0.id == id }
        items.removeAll { $0.id == id }
        persist()
        recordCartEvents(type: .cartItemRemoved, items: removedItems)
    }

    func incrementQuantity(for itemID: ShoppingCartItem.ID) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[index].quantity += 1
        persist()
    }

    func decrementQuantity(for itemID: ShoppingCartItem.ID) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[index].quantity = max(1, items[index].quantity - 1)
        persist()
    }

    func updateStore(for itemID: ShoppingCartItem.ID, to store: ShoppingStoreOption) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[index].storeName = store.displayName
        persist()
    }

    func toggleChecked(for itemID: ShoppingCartItem.ID) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[index].isChecked.toggle()
        persist()
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
        persist()
        UsageTrackingStore.shared.record(
            type: .cartSaved,
            recipeTitle: savedCart.name,
            ingredientNames: items.map(\.normalizedName),
            calories: recipeNutritionSummary.calories,
            proteinGrams: recipeNutritionSummary.proteinGrams,
            carbGrams: recipeNutritionSummary.carbohydrateGrams,
            fatGrams: recipeNutritionSummary.fatGrams
        )
        return savedCart
    }

    func restoreCart(_ savedCart: SavedShoppingCart) {
        items = savedCart.items
        persist()
    }

    func clearChecked() {
        let removedItems = items.filter(\.isChecked)
        items.removeAll(where: \.isChecked)
        persist()
        recordCartEvents(type: .cartItemRemoved, items: removedItems)
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
        let itemSections = populatedCategories.map { category in
            let itemLines = items(for: category).map { item in
                "- \(item.quantityText) \(item.name) (\(item.storeName))"
            }
            .joined(separator: "\n")

            return "\(category.title)\n\(itemLines)"
        }
        .joined(separator: "\n")

        return """
        Flame & Fleur Shopping List
        Items: \(totalItemCount)

        \(itemSections.isEmpty ? "No items yet." : itemSections)
        """
    }

    func sharedCartPayload(cartName: String? = nil) -> SharedCartPayload {
        let sharedItems = items.map { item in
            SharedCartItem(
                name: item.name,
                quantity: item.quantity,
                unit: item.unit,
                category: item.category.rawValue,
                storeName: item.storeName,
                isChecked: item.isChecked,
                price: item.price,
                notes: item.notes,
                displayQuantity: item.displayQuantity
            )
        }

        return SharedCartPayload(
            exportedAt: Date(),
            cartName: cartName ?? "Current Cart",
            items: sharedItems
        )
    }

    func replaceCart(with payload: SharedCartPayload) -> SharedCartImportSummary {
        let importedItems: [ShoppingCartItem] = payload.items.compactMap { sharedItem in
            let category = Self.shoppingCategory(from: sharedItem.category)
            let resolvedStore = sharedItem.storeName.flatMap { ShoppingStoreOption.option(named: $0).displayName }
                ?? Self.defaultStore(for: category).displayName
            let resolvedName = sharedItem.name?.trimmingCharacters(in: .whitespacesAndNewlines)
            let name = resolvedName.flatMap { $0.isEmpty ? nil : $0 } ?? "Imported Item"
            let quantity = max(1, sharedItem.quantity ?? 1)
            let unit = sharedItem.unit ?? ""
            let price = sharedItem.price ?? Self.defaultPrice(for: category)

            return ShoppingCartItem(
                name: name,
                quantity: quantity,
                unit: unit,
                displayQuantity: sharedItem.displayQuantity,
                category: category,
                price: price,
                storeName: resolvedStore,
                imageName: Self.defaultImageName(for: category),
                isChecked: sharedItem.isChecked ?? false,
                notes: sharedItem.notes
            )
        }

        items = importedItems
        persist()

        let unresolvedCount = payload.items.filter { sharedItem in
            let hasValidName = !(sharedItem.name?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
            let hasKnownCategory = Self.isKnownCategoryString(sharedItem.category)
            return !hasValidName || !hasKnownCategory
        }.count

        return SharedCartImportSummary(
            importedItemCount: importedItems.count,
            unresolvedItemCount: unresolvedCount
        )
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

    private func recordCartEvents(type: UsageEventType, items: [ShoppingCartItem]) {
        for item in items {
            recordCartEvent(type: type, item: item)
        }
    }

    private func recordCartEvent(type: UsageEventType, item: ShoppingCartItem) {
        let resolvedRecipe = item.sourceRecipeID.flatMap(RecipeRepository.shared.recipe(id:))

        UsageTrackingStore.shared.record(
            type: type,
            recipe: resolvedRecipe,
            recipeID: item.sourceRecipeID,
            recipeTitle: item.sourceRecipeTitle,
            category: item.category.title,
            ingredientNames: [item.normalizedName]
        )
    }

    private func persist() {
        let state = PersistedState(items: items, savedCarts: savedCarts)

        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: Self.persistenceKey)
    }

    private static func loadPersistedState() -> PersistedState? {
        guard let data = UserDefaults.standard.data(forKey: persistenceKey) else { return nil }
        return try? JSONDecoder().decode(PersistedState.self, from: data)
    }

    private static func shoppingCategory(from value: String) -> ShoppingCartCategory {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        switch normalized {
        case "produce":
            return .produce
        case "dairy", "dairy & eggs", "dairy eggs", "dairy_eggs", "eggs":
            return .dairy
        case "protein", "meat", "meat & seafood", "meat seafood", "meat_seafood", "seafood", "fish", "shellfish":
            return .protein
        case "pantry":
            return .pantry
        case "bakery":
            return .bakery
        case "frozen":
            return .frozen
        case "beverages", "beverage", "drinks", "drink":
            return .beverages
        case "household", "household goods", "home":
            return .household
        default:
            return .other
        }
    }

    private static func shoppingCategory(from value: String?) -> ShoppingCartCategory {
        guard let value else { return .other }
        return shoppingCategory(from: value)
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
        case .bakery:
            return 4.49
        case .frozen:
            return 4.99
        case .beverages:
            return 2.89
        case .household:
            return 3.79
        case .other:
            return 2.19
        }
    }

    private static func defaultImageName(for category: ShoppingCartCategory) -> String? {
        switch category {
        case .produce:
            return nil
        case .dairy:
            return nil
        case .protein:
            return nil
        case .pantry:
            return nil
        case .bakery:
            return nil
        case .frozen:
            return nil
        case .beverages:
            return nil
        case .household:
            return nil
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
        case .beverages:
            return .wholeFoods
        case .household:
            return .marketBasket
        case .produce, .other:
            return .wholeFoods
        }
    }

    private static func isKnownCategoryString(_ value: String?) -> Bool {
        guard let value else { return false }

        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch normalized {
        case "produce",
            "dairy",
            "dairy & eggs",
            "dairy eggs",
            "dairy_eggs",
            "eggs",
            "protein",
            "meat",
            "meat & seafood",
            "meat seafood",
            "meat_seafood",
            "seafood",
            "fish",
            "shellfish",
            "pantry",
            "bakery",
            "frozen",
            "beverages",
            "beverage",
            "drinks",
            "drink",
            "household",
            "household goods",
            "home",
            "other":
            return true
        default:
            return false
        }
    }

    private struct PersistedState: Codable {
        var items: [ShoppingCartItem]
        var savedCarts: [SavedShoppingCart]
    }
}
