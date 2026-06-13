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

    static let suggestedItems: [ShoppingCartItem] = [
        ShoppingCartItem(name: "Avocado", unit: "each", category: .produce, price: 1.79, storeName: ShoppingStoreOption.wholeFoods.displayName, imageName: "salad"),
        ShoppingCartItem(name: "Cherry Tomatoes", unit: "pint", category: .produce, price: 3.49, storeName: ShoppingStoreOption.traderJoes.displayName, imageName: "bowl"),
        ShoppingCartItem(name: "Greek Yogurt", unit: "cup", category: .dairy, price: 2.39, storeName: ShoppingStoreOption.wholeFoods.displayName, imageName: "citrus"),
        ShoppingCartItem(name: "Garlic", unit: "bulb", category: .pantry, price: 0.89, storeName: ShoppingStoreOption.costco.displayName, imageName: "pasta"),
        ShoppingCartItem(name: "Chicken Breast", unit: "lb", category: .protein, price: 4.99, storeName: ShoppingStoreOption.costco.displayName, imageName: "salmon"),
        ShoppingCartItem(name: "Baby Spinach", unit: "bag", category: .produce, price: 2.99, storeName: ShoppingStoreOption.traderJoes.displayName, imageName: "salad"),
        ShoppingCartItem(name: "Salmon Fillet", unit: "lb", category: .protein, price: 12.99, storeName: ShoppingStoreOption.wholeFoods.displayName, imageName: "salmon"),
        ShoppingCartItem(name: "Mozzarella", unit: "ball", category: .dairy, price: 4.49, storeName: ShoppingStoreOption.localMarket.displayName, imageName: "pasta")
    ]
}
