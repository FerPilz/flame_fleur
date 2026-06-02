import Foundation

enum SampleExploreCategories {
    static let groups: [ExploreCategoryGroup] = [
        makeGroup(
            id: "world-cuisine",
            title: "World Cuisine",
            subtitle: "Explore cuisines from around the world",
            subcategories: [
                SubcategorySeed("Italian", imageName: "pasta", category: .italian),
                SubcategorySeed("Mexican", imageName: "citrus", category: .mexican),
                SubcategorySeed("Korean", imageName: "bowl", category: .korean),
                SubcategorySeed("German", imageName: "bowl"),
                SubcategorySeed("Japanese", imageName: "salmon"),
                SubcategorySeed("Thai", imageName: "citrus"),
                SubcategorySeed("Indian", imageName: "bowl"),
                SubcategorySeed("Chinese", imageName: "bowl"),
                SubcategorySeed("French", imageName: "dessert"),
                SubcategorySeed("Greek", imageName: "salad"),
                SubcategorySeed("Spanish", imageName: "citrus"),
                SubcategorySeed("Middle Eastern", imageName: "bowl")
            ]
        ),
        makeGroup(
            id: "meat-seafood",
            title: "Meat & Seafood",
            subtitle: "Browse savory proteins, fish, and shellfish",
            subcategories: [
                SubcategorySeed("Fish", imageName: "salmon", category: .fish),
                SubcategorySeed("Shrimp", imageName: "salmon", category: .seafood),
                SubcategorySeed("Salmon", imageName: "salmon", category: .fish),
                SubcategorySeed("Tuna", imageName: "salmon", category: .fish),
                SubcategorySeed("Beef", imageName: "bowl", category: .meat),
                SubcategorySeed("Pork", imageName: "bowl", category: .meat),
                SubcategorySeed("Lamb", imageName: "bowl", category: .meat),
                SubcategorySeed("Turkey", imageName: "salad", category: .meat),
                SubcategorySeed("Shellfish", imageName: "salmon", category: .seafood)
            ]
        ),
        makeGroup(
            id: "vegetarian",
            title: "Vegetarian",
            subtitle: "Plant-forward meals with texture and warmth",
            subcategories: [
                SubcategorySeed("Tofu & Tempeh", imageName: "salad", category: .tofuTempeh),
                SubcategorySeed("Beans & Lentils", imageName: "bowl", category: .beansLentils),
                SubcategorySeed("Mushrooms", imageName: "salad", category: .mushrooms),
                SubcategorySeed("Eggplant", imageName: "bowl", category: .vegetarian),
                SubcategorySeed("Cauliflower", imageName: "salad", category: .vegetarian),
                SubcategorySeed("Chickpeas", imageName: "bowl", category: .beansLentils),
                SubcategorySeed("Leafy Greens", imageName: "salad", category: .salad),
                SubcategorySeed("Root Vegetables", imageName: "citrus", category: .vegetarian),
                SubcategorySeed("Plant-Based Bowls", imageName: "bowl", category: .grainBowl)
            ]
        ),
        makeGroup(
            id: "chicken",
            title: "Chicken",
            subtitle: "Comforting chicken ideas for every weeknight",
            subcategories: [
                SubcategorySeed("Grilled Chicken", imageName: "salmon", category: .grilledChicken),
                SubcategorySeed("Roast Chicken", imageName: "bowl", category: .chicken),
                SubcategorySeed("Chicken Bowls", imageName: "bowl", category: .chickenBowls),
                SubcategorySeed("Chicken Pasta", imageName: "pasta", category: .chickenPasta),
                SubcategorySeed("Chicken Soup", imageName: "bowl", category: .chicken),
                SubcategorySeed("Chicken Tacos", imageName: "citrus", category: .chicken),
                SubcategorySeed("Chicken Curry", imageName: "bowl", category: .chicken),
                SubcategorySeed("Chicken Salad", imageName: "salad", category: .chicken),
                SubcategorySeed("Chicken Skewers", imageName: "salmon", category: .grilledChicken)
            ]
        ),
        makeGroup(
            id: "bakery",
            title: "Bakery",
            subtitle: "Bakes, sweets, and warm oven favorites",
            subcategories: [
                SubcategorySeed("Bread", imageName: "dessert", category: .bread),
                SubcategorySeed("Cakes", imageName: "dessert", category: .cakes),
                SubcategorySeed("Pastries", imageName: "dessert", category: .pastries),
                SubcategorySeed("Cookies", imageName: "dessert", category: .dessert),
                SubcategorySeed("Muffins", imageName: "dessert", category: .bakery),
                SubcategorySeed("Pies & Tarts", imageName: "dessert", category: .dessert),
                SubcategorySeed("Brownies", imageName: "dessert", category: .dessert),
                SubcategorySeed("Breakfast Bakes", imageName: "dessert", category: .breakfast),
                SubcategorySeed("Savory Bakes", imageName: "pasta", category: .bakery)
            ]
        ),
        makeGroup(
            id: "high-protein",
            title: "High Protein",
            subtitle: "Balanced meals with satisfying protein",
            subcategories: [
                SubcategorySeed("Protein Bowls", imageName: "salad", category: .proteinBowls),
                SubcategorySeed("Lean Chicken", imageName: "salmon", category: .leanMeals),
                SubcategorySeed("Egg-Based Meals", imageName: "bowl", category: .highProtein),
                SubcategorySeed("Greek Yogurt", imageName: "dessert", category: .highProtein),
                SubcategorySeed("Seafood Protein", imageName: "salmon", category: .seafood),
                SubcategorySeed("Legume Protein", imageName: "bowl", category: .beansLentils),
                SubcategorySeed("Post-Workout Meals", imageName: "salad", category: .fitnessMeals),
                SubcategorySeed("Low-Carb Protein", imageName: "salad", category: .leanMeals),
                SubcategorySeed("High-Protein Breakfast", imageName: "bowl", category: .breakfast)
            ]
        )
    ]

    private static func makeGroup(
        id: String,
        title: String,
        subtitle: String,
        subcategories: [SubcategorySeed]
    ) -> ExploreCategoryGroup {
        ExploreCategoryGroup(
            id: id,
            title: title,
            subtitle: subtitle,
            subcategories: subcategories.map { seed in
                ExploreSubcategory(
                    id: "\(id)-\(slug(seed.title))",
                    title: seed.title,
                    parentGroupID: id,
                    imageName: seed.imageName,
                    category: seed.category
                )
            }
        )
    }

    private static func slug(_ value: String) -> String {
        value
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
    }
}

private struct SubcategorySeed {
    let title: String
    let imageName: String?
    let category: RecipeCategory?

    init(_ title: String, imageName: String?, category: RecipeCategory? = nil) {
        self.title = title
        self.imageName = imageName
        self.category = category
    }
}
