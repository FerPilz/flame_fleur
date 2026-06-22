import Foundation

enum SampleShoppingCartItems {
    static let currentWeek: [ShoppingCartItem] = [
        ShoppingCartItem(
            name: "Cherry Tomatoes",
            quantity: 2,
            unit: "pints",
            category: .produce,
            price: 3.49,
            storeName: ShoppingStoreOption.wholeFoods.displayName,
            imageName: "bowl"
        ),
        ShoppingCartItem(
            name: "Baby Spinach",
            quantity: 1,
            unit: "bag",
            category: .produce,
            price: 2.99,
            storeName: ShoppingStoreOption.traderJoes.displayName,
            imageName: "salad"
        ),
        ShoppingCartItem(
            name: "Bell Peppers",
            quantity: 3,
            unit: "count",
            category: .produce,
            price: 1.49,
            storeName: ShoppingStoreOption.costco.displayName,
            imageName: "bowl"
        ),
        ShoppingCartItem(
            name: "Greek Yogurt",
            quantity: 2,
            unit: "cups",
            category: .dairy,
            price: 2.39,
            storeName: ShoppingStoreOption.wholeFoods.displayName,
            imageName: "citrus"
        ),
        ShoppingCartItem(
            name: "Smoked Mozzarella",
            quantity: 1,
            unit: "block",
            category: .dairy,
            price: 5.49,
            storeName: ShoppingStoreOption.traderJoes.displayName,
            imageName: "pasta"
        ),
        ShoppingCartItem(
            name: "Unsalted Butter",
            quantity: 1,
            unit: "lb",
            category: .dairy,
            price: 3.99,
            storeName: ShoppingStoreOption.costco.displayName,
            imageName: "citrus"
        ),
        ShoppingCartItem(
            name: "Chicken Breast",
            quantity: 2,
            unit: "lb",
            category: .protein,
            price: 9.98,
            storeName: ShoppingStoreOption.costco.displayName,
            imageName: "salmon"
        ),
        ShoppingCartItem(
            name: "Salmon Fillet",
            quantity: 1,
            unit: "lb",
            category: .protein,
            price: 12.99,
            storeName: ShoppingStoreOption.wholeFoods.displayName,
            imageName: "salmon"
        ),
        ShoppingCartItem(
            name: "Sourdough",
            quantity: 1,
            unit: "loaf",
            category: .bakery,
            price: 5.99,
            storeName: ShoppingStoreOption.localMarket.displayName,
            imageName: "dessert"
        )
    ]

    private static let baseSuggestedItems: [ShoppingCartItem] = [
        ShoppingCartItem(name: "Avocado", unit: "each", category: .produce, price: 1.79, storeName: ShoppingStoreOption.wholeFoods.displayName, imageName: "salad"),
        ShoppingCartItem(name: "Cherry Tomatoes", unit: "pint", category: .produce, price: 3.49, storeName: ShoppingStoreOption.traderJoes.displayName, imageName: "bowl"),
        ShoppingCartItem(name: "Greek Yogurt", unit: "cup", category: .dairy, price: 2.39, storeName: ShoppingStoreOption.wholeFoods.displayName, imageName: "citrus"),
        ShoppingCartItem(name: "Garlic", unit: "bulb", category: .pantry, price: 0.89, storeName: ShoppingStoreOption.costco.displayName, imageName: "pasta"),
        ShoppingCartItem(name: "Chicken Breast", unit: "lb", category: .protein, price: 4.99, storeName: ShoppingStoreOption.costco.displayName, imageName: "salmon"),
        ShoppingCartItem(name: "Baby Spinach", unit: "bag", category: .produce, price: 2.99, storeName: ShoppingStoreOption.traderJoes.displayName, imageName: "salad"),
        ShoppingCartItem(name: "Salmon Fillet", unit: "lb", category: .protein, price: 12.99, storeName: ShoppingStoreOption.wholeFoods.displayName, imageName: "salmon"),
        ShoppingCartItem(name: "Mozzarella", unit: "ball", category: .dairy, price: 4.49, storeName: ShoppingStoreOption.localMarket.displayName, imageName: "pasta")
    ]

    static let suggestedItems: [ShoppingCartItem] = {
        mergeSuggestedItems(
            baseSuggestedItems,
            catalogSuggestedItems(),
            recipeIngredientItems()
        )
    }()

    private static func recipeIngredientItems() -> [ShoppingCartItem] {
        var seen: Set<String> = []

        return RecipeRepository.shared.allRecipes.flatMap(\.structuredIngredients).compactMap { ingredient in
            let key = normalizedIngredientKey(ingredient.normalizedName)

            guard !key.isEmpty, !seen.contains(key) else {
                return nil
            }

            seen.insert(key)

            if let catalogItem = SampleShoppingIngredientCatalog.byNormalizedName[key] {
                return ShoppingCartItem(
                    name: catalogItem.displayName,
                    unit: catalogItem.defaultUnit,
                    displayQuantity: ingredient.displayLine,
                    category: shoppingCategory(from: catalogItem.category),
                    price: catalogItem.estimatedPrice,
                    storeName: defaultStore(for: shoppingCategory(from: catalogItem.category)).displayName,
                    imageName: catalogItem.imageName
                )
            }

            let category = category(for: ingredient.name)

            return ShoppingCartItem(
                name: displayIngredientName(ingredient.name),
                unit: defaultUnit(for: category),
                displayQuantity: ingredient.displayLine,
                category: category,
                price: defaultPrice(for: category),
                storeName: defaultStore(for: category).displayName,
                imageName: defaultImageName(for: category)
            )
        }
    }

    private static func catalogSuggestedItems() -> [ShoppingCartItem] {
        SampleShoppingIngredientCatalog.all.map { catalogItem in
            let category = shoppingCategory(from: catalogItem.category)

            return ShoppingCartItem(
                name: catalogItem.displayName,
                unit: catalogItem.defaultUnit,
                category: category,
                price: catalogItem.estimatedPrice,
                storeName: defaultStore(for: category).displayName,
                imageName: catalogItem.imageName
            )
        }
    }

    private static func mergeSuggestedItems(_ groups: [ShoppingCartItem]...) -> [ShoppingCartItem] {
        var seen: Set<String> = []
        var merged: [ShoppingCartItem] = []

        for item in groups.flatMap({ $0 }) {
            let key = normalizedIngredientKey(item.name)
            guard !key.isEmpty, !seen.contains(key) else { continue }
            seen.insert(key)
            merged.append(item)
        }

        return merged
    }

    private static func normalizedIngredientKey(_ name: String) -> String {
        name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: #"[^\p{L}\p{N}]+"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func displayIngredientName(_ name: String) -> String {
        name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .localizedCapitalized
    }

    private static func category(for name: String) -> ShoppingCartCategory {
        let key = normalizedIngredientKey(name)

        if ["milk", "yogurt", "cheese", "butter", "cream", "mozzarella", "parmesan", "feta", "ricotta", "cottage", "ghee"].contains(where: key.contains) {
            return .dairy
        }

        if ["chicken", "salmon", "fish", "shrimp", "tuna", "beef", "pork", "lamb", "turkey", "tofu", "tempeh", "egg", "eggs", "legume", "lentil", "beans", "chickpea"].contains(where: key.contains) {
            return .protein
        }

        if ["bread", "bun", "tortilla", "pasta", "rice", "quinoa", "flour", "sugar", "oat", "oats", "baking", "vanilla", "cinnamon", "nuts", "seed", "syrup"].contains(where: key.contains) {
            return .pantry
        }

        if ["frozen", "ice cream", "sorbet"].contains(where: key.contains) {
            return .frozen
        }

        if ["cake", "cookie", "muffin", "brownie", "pie", "tart", "pastry", "bake", "bagel", "sourdough", "croissant"].contains(where: key.contains) {
            return .bakery
        }

        if ["avocado", "spinach", "kale", "greens", "tomato", "pepper", "onion", "garlic", "lemon", "lime", "herb", "herbs", "basil", "parsley", "cilantro", "mushroom", "cauliflower", "eggplant", "broccoli", "carrot", "potato", "sweet potato", "cucumber", "celery", "zucchini", "beans", "peas", "lettuce", "salad", "berry", "berries", "fruit", "apple", "orange"].contains(where: key.contains) {
            return .produce
        }

        return .other
    }

    private static func defaultUnit(for category: ShoppingCartCategory) -> String {
        switch category {
        case .produce:
            return "each"
        case .dairy:
            return "unit"
        case .protein:
            return "lb"
        case .pantry:
            return "item"
        case .frozen:
            return "item"
        case .bakery:
            return "item"
        case .other:
            return "item"
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

    private static func shoppingCategory(from name: String) -> ShoppingCartCategory {
        switch name.lowercased() {
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
}
