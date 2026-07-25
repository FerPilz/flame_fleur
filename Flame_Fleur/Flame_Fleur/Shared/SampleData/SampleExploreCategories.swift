import Foundation

enum SampleExploreCategories {
    static let groups: [ExploreCategoryGroup] = [
        makeGroup(
            id: "world-cuisine",
            title: "World Cuisine",
            subtitle: "Explore cuisines from around the world",
            subcategories: [
                SubcategorySeed("Italian", imageName: "ff_subcat_world_cuisine_italian", category: .italian),
                SubcategorySeed("Mexican", imageName: "world_mexican_charred_corn_tacos", category: .mexican),
                SubcategorySeed("Korean", imageName: "world_korean_sesame_beef_bulgogi", category: .korean),
                SubcategorySeed("German", imageName: "world_german_herbed_bratwurst_plate"),
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
            id: "meat",
            title: "Meat",
            subtitle: "Browse beef, pork, lamb, and turkey",
            subcategories: [
                SubcategorySeed("Beef", id: "meat-seafood-beef", imageName: "ff_subcat_meat_seafood_beef", category: .meat),
                SubcategorySeed("Pork", id: "meat-seafood-pork", imageName: "ff_subcat_meat_seafood_pork", category: .meat),
                SubcategorySeed("Lamb", id: "meat-seafood-lamb", imageName: "ff_subcat_meat_seafood_lamb", category: .meat),
                SubcategorySeed("Turkey", id: "meat-seafood-turkey", imageName: "ff_subcat_meat_seafood_turkey", category: .meat)
            ]
        ),
        makeGroup(
            id: "seafood",
            title: "Seafood",
            subtitle: "Browse fish, shrimp, salmon, tuna, and shellfish",
            subcategories: [
                SubcategorySeed("Fish", id: "meat-seafood-fish", imageName: "ff_subcat_meat_seafood_fish", category: .fish),
                SubcategorySeed("Shrimp", id: "meat-seafood-shrimp", imageName: "ff_subcat_meat_seafood_shrimp", category: .seafood),
                SubcategorySeed("Salmon", id: "meat-seafood-salmon", imageName: "ff_subcat_meat_seafood_salmon", category: .fish),
                SubcategorySeed("Tuna", id: "meat-seafood-tuna", imageName: "ff_subcat_meat_seafood_tuna", category: .fish),
                SubcategorySeed("Shellfish", id: "meat-seafood-shellfish", imageName: "ff_subcat_meat_seafood_shellfish", category: .seafood)
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
            id: "lean-meals",
            title: "Lean Meals",
            subtitle: "Protein-forward meals with lighter balance",
            subcategories: [
                SubcategorySeed("Protein Bowls", id: "high-protein-protein-bowls", imageName: "ff_subcat_high_protein_protein_bowls", category: .proteinBowls),
                SubcategorySeed("Lean Chicken", id: "high-protein-lean-chicken", imageName: "ff_subcat_high_protein_lean_chicken", category: .leanMeals),
                SubcategorySeed("Post-Workout Meals", id: "high-protein-post-workout-meals", imageName: "ff_subcat_high_protein_post_workout_meals", category: .fitnessMeals),
                SubcategorySeed("Legume Protein", id: "high-protein-legume-protein", imageName: "ff_subcat_high_protein_legume_protein", category: .beansLentils)
            ]
        ),
        makeGroup(
            id: "breakfast-category",
            title: "Breakfast",
            subtitle: "Greek yogurt bowls and egg-centered meals",
            subcategories: [
                SubcategorySeed("Greek Yogurt", id: "high-protein-greek-yogurt", imageName: "ff_subcat_high_protein_greek_yogurt", category: .breakfast),
                SubcategorySeed("Egg-Based Meals", id: "high-protein-egg-based-meals", imageName: "ff_subcat_high_protein_egg_based_meals", category: .breakfast),
                SubcategorySeed("High-Protein Breakfast", id: "high-protein-high-protein-breakfast", imageName: "ff_subcat_high_protein_high_protein_breakfast", category: .breakfast)
            ]
        )
    ]

    private static func makeGroup(
        id: String,
        title: String,
        subtitle: String,
        bubbleDisplayMode: ExploreCategoryBubbleDisplayMode = .subcategories,
        subcategories: [SubcategorySeed]
    ) -> ExploreCategoryGroup {
        ExploreCategoryGroup(
            id: id,
            title: title,
            subtitle: subtitle,
            bubbleDisplayMode: bubbleDisplayMode,
            subcategories: subcategories.map { seed in
                ExploreSubcategory(
                    id: seed.id ?? "\(id)-\(slug(seed.title))",
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
    let id: String?
    let imageName: String?
    let category: RecipeCategory?

    init(_ title: String, id: String? = nil, imageName: String?, category: RecipeCategory? = nil) {
        self.title = title
        self.id = id
        self.imageName = imageName
        self.category = category
    }
}
