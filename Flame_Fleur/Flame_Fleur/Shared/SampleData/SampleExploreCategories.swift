import Foundation

enum SampleExploreCategories {
    static let groups: [ExploreCategoryGroup] = [
        makeGroup(
            id: "world-cuisine",
            title: "World Cuisine",
            subtitle: "Explore cuisines from around the world",
            subcategories: [
                SubcategorySeed("Italian", imageName: "ff_subcat_world_cuisine_italian", category: .italian),
                SubcategorySeed("Mexican", imageName: "ff_subcat_world_cuisine_mexican", category: .mexican),
                SubcategorySeed("Korean", imageName: "ff_subcat_world_cuisine_korean", category: .korean),
                SubcategorySeed("German", imageName: "ff_subcat_world_cuisine_german"),
                SubcategorySeed("Japanese", imageName: "ff_subcat_world_cuisine_japanese"),
                SubcategorySeed("Thai", imageName: "ff_subcat_world_cuisine_thai"),
                SubcategorySeed("Indian", imageName: "ff_subcat_world_cuisine_indian"),
                SubcategorySeed("Chinese", imageName: "ff_subcat_world_cuisine_chinese"),
                SubcategorySeed("French", imageName: "ff_subcat_world_cuisine_french"),
                SubcategorySeed("Greek", imageName: "ff_subcat_world_cuisine_greek"),
                SubcategorySeed("Spanish", imageName: "ff_subcat_world_cuisine_spanish"),
                SubcategorySeed("Middle Eastern", imageName: "ff_subcat_world_cuisine_middle_eastern")
            ]
        ),
        makeGroup(
            id: "meat-seafood",
            title: "Meat & Seafood",
            subtitle: "Browse savory proteins, fish, and shellfish",
            subcategories: [
                SubcategorySeed("Fish", imageName: "ff_subcat_meat_seafood_fish", category: .fish),
                SubcategorySeed("Shrimp", imageName: "ff_subcat_meat_seafood_shrimp", category: .seafood),
                SubcategorySeed("Salmon", imageName: "ff_subcat_meat_seafood_salmon", category: .fish),
                SubcategorySeed("Tuna", imageName: "ff_subcat_meat_seafood_tuna", category: .fish),
                SubcategorySeed("Beef", imageName: "ff_subcat_meat_seafood_beef", category: .meat),
                SubcategorySeed("Pork", imageName: "ff_subcat_meat_seafood_pork", category: .meat),
                SubcategorySeed("Lamb", imageName: "ff_subcat_meat_seafood_lamb", category: .meat),
                SubcategorySeed("Turkey", imageName: "ff_subcat_meat_seafood_turkey", category: .meat),
                SubcategorySeed("Shellfish", imageName: "ff_subcat_meat_seafood_shellfish", category: .seafood)
            ]
        ),
        makeGroup(
            id: "vegetarian",
            title: "Vegetarian",
            subtitle: "Plant-forward meals with texture and warmth",
            subcategories: [
                SubcategorySeed("Tofu & Tempeh", imageName: "ff_subcat_vegetarian_tofu_tempeh", category: .tofuTempeh),
                SubcategorySeed("Beans & Lentils", imageName: "ff_subcat_vegetarian_beans_lentils", category: .beansLentils),
                SubcategorySeed("Mushrooms", imageName: "ff_subcat_vegetarian_mushrooms", category: .mushrooms),
                SubcategorySeed("Eggplant", imageName: "ff_subcat_vegetarian_eggplant", category: .vegetarian),
                SubcategorySeed("Cauliflower", imageName: "ff_subcat_vegetarian_cauliflower", category: .vegetarian),
                SubcategorySeed("Chickpeas", imageName: "ff_subcat_vegetarian_chickpeas", category: .beansLentils),
                SubcategorySeed("Leafy Greens", imageName: "ff_subcat_vegetarian_leafy_greens", category: .salad),
                SubcategorySeed("Root Vegetables", imageName: "ff_subcat_vegetarian_root_vegetables", category: .vegetarian),
                SubcategorySeed("Plant-Based Bowls", imageName: "ff_subcat_vegetarian_plant_based_bowls", category: .grainBowl)
            ]
        ),
        makeGroup(
            id: "chicken",
            title: "Chicken",
            subtitle: "Comforting chicken ideas for every weeknight",
            subcategories: [
                SubcategorySeed("Grilled Chicken", imageName: "ff_subcat_chicken_grilled_chicken", category: .grilledChicken),
                SubcategorySeed("Roast Chicken", imageName: "ff_subcat_chicken_roast_chicken", category: .chicken),
                SubcategorySeed("Chicken Bowls", imageName: "ff_subcat_chicken_chicken_bowls", category: .chickenBowls),
                SubcategorySeed("Chicken Pasta", imageName: "ff_subcat_chicken_chicken_pasta", category: .chickenPasta),
                SubcategorySeed("Chicken Soup", imageName: "ff_subcat_chicken_chicken_soup", category: .chicken),
                SubcategorySeed("Chicken Tacos", imageName: "ff_subcat_chicken_chicken_tacos", category: .chicken),
                SubcategorySeed("Chicken Curry", imageName: "ff_subcat_chicken_chicken_curry", category: .chicken),
                SubcategorySeed("Chicken Salad", imageName: "ff_subcat_chicken_chicken_salad", category: .chicken),
                SubcategorySeed("Chicken Skewers", imageName: "ff_subcat_chicken_chicken_skewers", category: .grilledChicken)
            ]
        ),
        makeGroup(
            id: "bakery",
            title: "Bakery",
            subtitle: "Bakes, sweets, and warm oven favorites",
            subcategories: [
                SubcategorySeed("Bread", imageName: "ff_subcat_bakery_bread", category: .bread),
                SubcategorySeed("Cakes", imageName: "ff_subcat_bakery_cakes", category: .cakes),
                SubcategorySeed("Pastries", imageName: "ff_subcat_bakery_pastries", category: .pastries),
                SubcategorySeed("Cookies", imageName: "ff_subcat_bakery_cookies", category: .dessert),
                SubcategorySeed("Muffins", imageName: "ff_subcat_bakery_muffins", category: .bakery),
                SubcategorySeed("Pies & Tarts", imageName: "ff_subcat_bakery_pies_tarts", category: .dessert),
                SubcategorySeed("Brownies", imageName: "ff_subcat_bakery_brownies", category: .dessert),
                SubcategorySeed("Breakfast Bakes", imageName: "ff_subcat_bakery_breakfast_bakes", category: .breakfast),
                SubcategorySeed("Savory Bakes", imageName: "ff_subcat_bakery_savory_bakes", category: .bakery)
            ]
        ),
        makeGroup(
            id: "high-protein",
            title: "High Protein",
            subtitle: "Balanced meals with satisfying protein",
            subcategories: [
                SubcategorySeed("Protein Bowls", imageName: "ff_subcat_high_protein_protein_bowls", category: .proteinBowls),
                SubcategorySeed("Lean Chicken", imageName: "ff_subcat_high_protein_lean_chicken", category: .leanMeals),
                SubcategorySeed("Egg-Based Meals", imageName: "ff_subcat_high_protein_egg_based_meals", category: .highProtein),
                SubcategorySeed("Greek Yogurt", imageName: "ff_subcat_high_protein_greek_yogurt", category: .highProtein),
                SubcategorySeed("Seafood Protein", imageName: "ff_subcat_high_protein_seafood_protein", category: .seafood),
                SubcategorySeed("Legume Protein", imageName: "ff_subcat_high_protein_legume_protein", category: .beansLentils),
                SubcategorySeed("Post-Workout Meals", imageName: "ff_subcat_high_protein_post_workout_meals", category: .fitnessMeals),
                SubcategorySeed("Low-Carb Protein", imageName: "ff_subcat_high_protein_low_carb_protein", category: .leanMeals),
                SubcategorySeed("High-Protein Breakfast", imageName: "ff_subcat_high_protein_high_protein_breakfast", category: .breakfast)
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