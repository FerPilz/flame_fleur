import Foundation

enum SampleRecipes {
    static let all: [Recipe] = homeRecipes + exploreCategoryRecipes

    private static let homeRecipes: [Recipe] = [
        Recipe(
            id: "recipe-featured-salmon",
            title: "Creamy Lemon Herb Salmon",
            subtitle: "Light, fresh & zesty",
            category: .seafood,
            sectionTags: [.featured],
            cookingTimeMinutes: 30,
            calories: 650,
            servings: 2,
            difficulty: .easy,
            imageName: "salmon"
        ),
        Recipe(
            id: "recipe-featured-tuscan-gnocchi",
            title: "Tuscan Tomato Gnocchi",
            subtitle: "Velvety, bright & cozy",
            category: .pasta,
            sectionTags: [.featured],
            cookingTimeMinutes: 28,
            calories: 520,
            servings: 3,
            difficulty: .easy,
            imageName: "pasta"
        ),
        Recipe(
            id: "recipe-featured-chicken-risotto",
            title: "Golden Chicken Risotto",
            subtitle: "Creamy saffron comfort",
            category: .chicken,
            sectionTags: [.featured],
            cookingTimeMinutes: 45,
            calories: 610,
            servings: 4,
            difficulty: .moderate,
            imageName: "bowl",
            isPremium: true
        ),
        Recipe(
            id: "recipe-featured-peach-salad",
            title: "Charred Peach Salad",
            subtitle: "Sweet, peppery & fresh",
            category: .salad,
            sectionTags: [.featured],
            cookingTimeMinutes: 18,
            calories: 340,
            servings: 2,
            difficulty: .easy,
            imageName: "salad"
        ),
        Recipe(
            id: "recipe-community-pesto-primavera",
            title: "Pesto Primavera",
            subtitle: "Basil ribbons",
            creatorName: "@marina.cooks",
            creatorAvatarName: "avatar-marina",
            category: .pasta,
            sectionTags: [.community],
            cookingTimeMinutes: 25,
            calories: 410,
            servings: 2,
            difficulty: .easy,
            imageName: "pasta",
            isCommunityRecipe: true
        ),
        Recipe(
            id: "recipe-community-lentil-soup",
            title: "Hearty Lentil Soup",
            subtitle: "Cozy bowl",
            creatorName: "@homechef.anna",
            creatorAvatarName: "avatar-anna",
            category: .soup,
            sectionTags: [.community],
            cookingTimeMinutes: 40,
            calories: 360,
            servings: 4,
            difficulty: .easy,
            imageName: "bowl",
            isCommunityRecipe: true
        ),
        Recipe(
            id: "recipe-community-fudgy-brownie",
            title: "Fudgy Brownie",
            subtitle: "Dark cocoa",
            creatorName: "@bakewithleo",
            creatorAvatarName: "avatar-leo",
            category: .dessert,
            sectionTags: [.community],
            cookingTimeMinutes: 50,
            calories: 260,
            servings: 6,
            difficulty: .moderate,
            imageName: "dessert",
            isCommunityRecipe: true
        ),
        Recipe(
            id: "recipe-community-veggie-bowl",
            title: "Roasted Veggie Bowl",
            subtitle: "Herby tahini",
            creatorName: "@freshkitchen",
            creatorAvatarName: "avatar-fresh",
            category: .grainBowl,
            sectionTags: [.community],
            cookingTimeMinutes: 32,
            calories: 390,
            servings: 2,
            difficulty: .easy,
            imageName: "salad",
            isCommunityRecipe: true
        ),
        Recipe(
            id: "recipe-community-ricotta-toast",
            title: "Lemon Ricotta Toast",
            subtitle: "Crisp and creamy",
            creatorName: "@chef.luna",
            creatorAvatarName: "avatar-luna",
            category: .toast,
            sectionTags: [.community],
            cookingTimeMinutes: 12,
            calories: 310,
            servings: 1,
            difficulty: .easy,
            imageName: "citrus",
            isCommunityRecipe: true
        ),
        Recipe(
            id: "recipe-community-chickpea-stew",
            title: "Spiced Chickpea Stew",
            subtitle: "Warm pantry favorite",
            creatorName: "@tableandthyme",
            creatorAvatarName: "avatar-thyme",
            category: .vegetarian,
            sectionTags: [.community],
            cookingTimeMinutes: 35,
            calories: 430,
            servings: 4,
            difficulty: .easy,
            imageName: "bowl",
            isCommunityRecipe: true
        ),
        Recipe(
            id: "recipe-top-butter-chicken",
            title: "Butter Chicken",
            subtitle: "Silky tomato",
            category: .chicken,
            sectionTags: [.topPicks],
            cookingTimeMinutes: 35,
            calories: 480,
            servings: 3,
            difficulty: .moderate,
            imageName: "bowl"
        ),
        Recipe(
            id: "recipe-top-garlic-parmesan-pasta",
            title: "Garlic Parmesan Pasta",
            subtitle: "Creamy garlic",
            category: .pasta,
            sectionTags: [.topPicks],
            cookingTimeMinutes: 20,
            calories: 430,
            servings: 2,
            difficulty: .easy,
            imageName: "pasta"
        ),
        Recipe(
            id: "recipe-top-quinoa-power-bowl",
            title: "Quinoa Power Bowl",
            subtitle: "Bright and crisp",
            category: .grainBowl,
            sectionTags: [.topPicks],
            cookingTimeMinutes: 25,
            calories: 390,
            servings: 2,
            difficulty: .easy,
            imageName: "salad"
        ),
        Recipe(
            id: "recipe-top-miso-eggplant",
            title: "Miso Glazed Eggplant",
            subtitle: "Savory and glossy",
            category: .vegetarian,
            sectionTags: [.topPicks],
            cookingTimeMinutes: 30,
            calories: 360,
            servings: 2,
            difficulty: .moderate,
            imageName: "bowl"
        ),
        Recipe(
            id: "recipe-top-fish-tacos",
            title: "Crispy Fish Tacos",
            subtitle: "Lime and crunch",
            category: .seafood,
            sectionTags: [.topPicks],
            cookingTimeMinutes: 24,
            calories: 470,
            servings: 3,
            difficulty: .moderate,
            imageName: "citrus"
        ),
        Recipe(
            id: "recipe-top-mushroom-toast",
            title: "Wild Mushroom Toast",
            subtitle: "Earthy brunch plate",
            category: .toast,
            sectionTags: [.topPicks],
            cookingTimeMinutes: 18,
            calories: 330,
            servings: 2,
            difficulty: .easy,
            imageName: "salad",
            isPremium: true
        ),
        Recipe(
            id: "recipe-ai-pantry-pasta",
            title: "Pantry Pasta",
            subtitle: "Simple, silky sauce",
            category: .pantry,
            sectionTags: [.aiRecommended],
            cookingTimeMinutes: 18,
            calories: 420,
            servings: 2,
            difficulty: .easy,
            imageName: "pasta"
        ),
        Recipe(
            id: "recipe-ai-green-curry",
            title: "20-Minute Green Curry",
            subtitle: "Fragrant and bright",
            category: .curry,
            sectionTags: [.aiRecommended],
            cookingTimeMinutes: 20,
            calories: 460,
            servings: 3,
            difficulty: .easy,
            imageName: "bowl"
        ),
        Recipe(
            id: "recipe-ai-breakfast-bowl",
            title: "High-Protein Breakfast Bowl",
            subtitle: "Balanced morning fuel",
            category: .breakfast,
            sectionTags: [.aiRecommended],
            cookingTimeMinutes: 15,
            calories: 380,
            servings: 1,
            difficulty: .easy,
            imageName: "salad"
        ),
        Recipe(
            id: "recipe-ai-lentil-dal",
            title: "Cozy Lentil Dal",
            subtitle: "Golden and calming",
            category: .vegetarian,
            sectionTags: [.aiRecommended],
            cookingTimeMinutes: 34,
            calories: 410,
            servings: 4,
            difficulty: .easy,
            imageName: "bowl"
        ),
        Recipe(
            id: "recipe-ai-salmon-rice",
            title: "Salmon Rice Plate",
            subtitle: "Fresh weekday bowl",
            category: .seafood,
            sectionTags: [.aiRecommended],
            cookingTimeMinutes: 22,
            calories: 540,
            servings: 2,
            difficulty: .easy,
            imageName: "salmon",
            isPremium: true
        ),
        Recipe(
            id: "recipe-ai-citrus-chicken",
            title: "Quick Citrus Chicken",
            subtitle: "Zesty skillet dinner",
            category: .chicken,
            sectionTags: [.aiRecommended],
            cookingTimeMinutes: 26,
            calories: 450,
            servings: 3,
            difficulty: .easy,
            imageName: "citrus"
        )
    ]

    private static let exploreCategoryRecipes: [Recipe] = [
        makeRecipes(
            category: .italian,
            imageName: "pasta",
            items: [
                ("Tuscan White Bean Pasta", "Silky beans, herbs & lemon", 24, 430, 2, .easy),
                ("Sicilian Eggplant Caponata", "Sweet-sour vegetables", 36, 310, 4, .moderate),
                ("Roman Cacio e Pepe", "Peppery, glossy pasta", 18, 520, 2, .easy),
                ("Ligurian Pesto Trofie", "Basil, potato & green beans", 26, 480, 3, .easy),
                ("Florentine Chicken Skillet", "Creamy spinach sauce", 32, 540, 3, .moderate),
                ("Lemon Ricotta Ravioli", "Soft cheese and citrus", 28, 510, 2, .moderate)
            ]
        ),
        makeRecipes(
            category: .mexican,
            imageName: "citrus",
            items: [
                ("Charred Corn Tacos", "Smoky corn and lime crema", 22, 390, 3, .easy),
                ("Chicken Tinga Bowls", "Tomato-chipotle shredded chicken", 34, 520, 4, .moderate),
                ("Roasted Poblano Enchiladas", "Creamy green chile bake", 45, 560, 4, .moderate),
                ("Citrus Shrimp Tostadas", "Bright shrimp and avocado", 20, 430, 2, .easy),
                ("Black Bean Chilaquiles", "Saucy tortilla breakfast", 25, 470, 3, .easy),
                ("Mushroom Quesadillas", "Earthy, melty filling", 18, 410, 2, .easy)
            ]
        ),
        makeRecipes(
            category: .korean,
            imageName: "bowl",
            items: [
                ("Sesame Beef Bulgogi", "Sweet soy marinated beef", 30, 560, 3, .moderate),
                ("Kimchi Fried Rice", "Crisp rice and soft egg", 20, 430, 2, .easy),
                ("Gochujang Tofu Bowls", "Spicy glazed tofu", 26, 460, 2, .easy),
                ("Korean Chicken Lettuce Cups", "Crunchy and savory wraps", 28, 390, 3, .easy),
                ("Japchae Noodle Stir-Fry", "Glass noodles and vegetables", 35, 450, 4, .moderate),
                ("Miso-Kimchi Soup", "Warming broth and greens", 24, 320, 3, .easy)
            ]
        ),
        makeRecipes(
            category: .fish,
            imageName: "salmon",
            items: [
                ("Herb-Crusted Cod", "Tender fish with lemon crumbs", 25, 390, 2, .easy),
                ("Seared Trout Almondine", "Toasty almonds and brown butter", 22, 470, 2, .moderate),
                ("Miso Glazed Salmon", "Savory glaze and rice", 24, 540, 2, .easy),
                ("Crispy Fish Tacos", "Lime slaw and warm tortillas", 24, 470, 3, .moderate),
                ("Lemon Dill Halibut", "Clean, bright weeknight fish", 28, 410, 2, .easy),
                ("Paprika Fish Stew", "Tomato broth and herbs", 38, 430, 4, .moderate)
            ]
        ),
        makeRecipes(
            category: .meat,
            imageName: "bowl",
            items: [
                ("Rosemary Steak Bites", "Garlic butter skillet", 20, 580, 2, .easy),
                ("Braised Short Rib Ragu", "Slow-simmered comfort", 120, 690, 6, .advanced),
                ("Lamb Meatball Couscous", "Mint yogurt and grains", 42, 610, 4, .moderate),
                ("Pork Tenderloin Medallions", "Apple pan sauce", 34, 520, 3, .moderate),
                ("Beef & Mushroom Skillet", "Savory one-pan dinner", 30, 560, 3, .easy),
                ("Herbed Turkey Patties", "Light and juicy", 24, 420, 3, .easy)
            ]
        ),
        makeRecipes(
            category: .seafood,
            imageName: "salmon",
            items: [
                ("Garlic Butter Shrimp", "Fast skillet shellfish", 15, 380, 2, .easy),
                ("Scallop Lemon Risotto", "Creamy rice and seared scallops", 42, 610, 3, .moderate),
                ("Clam Linguine", "White wine and parsley", 28, 520, 3, .moderate),
                ("Coconut Mussel Pot", "Fragrant broth and herbs", 24, 460, 4, .easy),
                ("Crab Cake Salad", "Golden cakes and greens", 32, 480, 2, .moderate),
                ("Shrimp Rice Noodle Bowl", "Fresh herbs and citrus", 25, 430, 2, .easy)
            ]
        ),
        makeRecipes(
            category: .tofuTempeh,
            imageName: "salad",
            items: [
                ("Crispy Sesame Tofu", "Golden cubes and greens", 26, 410, 2, .easy),
                ("Tempeh Satay Bowls", "Peanut sauce and rice", 32, 520, 3, .moderate),
                ("Maple Miso Tofu", "Sweet-savory glaze", 24, 390, 2, .easy),
                ("Tofu Banh Mi Salad", "Pickled crunch and herbs", 22, 370, 2, .easy),
                ("Smoky Tempeh Tacos", "Cabbage and avocado", 25, 450, 3, .easy),
                ("Ginger Tofu Soup", "Clear broth and noodles", 30, 340, 3, .easy)
            ]
        ),
        makeRecipes(
            category: .beansLentils,
            imageName: "bowl",
            items: [
                ("French Lentil Salad", "Mustard vinaigrette", 30, 390, 3, .easy),
                ("Creamy White Bean Stew", "Rosemary and greens", 34, 430, 4, .easy),
                ("Black Bean Stuffed Peppers", "Smoky rice filling", 48, 460, 4, .moderate),
                ("Chickpea Tomato Skillet", "Saucy pantry dinner", 24, 410, 3, .easy),
                ("Red Lentil Dal", "Golden spices and lime", 32, 420, 4, .easy),
                ("Herbed Bean Toasts", "Lemon beans on sourdough", 16, 350, 2, .easy)
            ]
        ),
        makeRecipes(
            category: .mushrooms,
            imageName: "salad",
            items: [
                ("Wild Mushroom Toast", "Earthy brunch plate", 18, 330, 2, .easy),
                ("Creamy Mushroom Gnocchi", "Soft dumplings and thyme", 28, 540, 3, .moderate),
                ("Mushroom Barley Soup", "Deep, cozy broth", 45, 380, 4, .moderate),
                ("Garlic Portobello Steaks", "Balsamic and herbs", 25, 310, 2, .easy),
                ("Miso Mushroom Rice", "Umami skillet grains", 30, 420, 3, .easy),
                ("Crispy Oyster Mushrooms", "Light batter and aioli", 34, 460, 3, .moderate)
            ]
        ),
        makeRecipes(
            category: .chicken,
            imageName: "bowl",
            items: [
                ("Grilled Lemon Chicken", "Herby citrus marinade", 30, 450, 3, .easy),
                ("Chicken Shawarma Bowls", "Spiced chicken and tahini", 38, 560, 4, .moderate),
                ("Chicken Pesto Pasta", "Basil cream and tomatoes", 26, 610, 3, .easy),
                ("Honey Mustard Chicken", "Sheet-pan comfort", 35, 520, 4, .easy),
                ("Crispy Chicken Cutlets", "Golden crumbs and salad", 32, 590, 3, .moderate),
                ("Thai Basil Chicken", "Fast wok dinner", 22, 480, 3, .easy)
            ]
        ),
        makeRecipes(
            category: .grilledChicken,
            imageName: "salmon",
            items: [
                ("Rosemary Grilled Chicken", "Woodsy herbs and lemon", 28, 430, 3, .easy),
                ("Yogurt-Marinated Chicken", "Tender, tangy grill plate", 35, 470, 4, .easy),
                ("Smoky Paprika Chicken", "Charred edges and spice", 30, 450, 3, .easy),
                ("Peach Glazed Chicken", "Sweet fruit and herbs", 32, 490, 3, .moderate),
                ("Garlic Skewer Chicken", "Juicy bites and tzatziki", 26, 420, 4, .easy),
                ("Chimichurri Chicken", "Fresh herb sauce", 24, 440, 2, .easy)
            ]
        ),
        makeRecipes(
            category: .chickenBowls,
            imageName: "bowl",
            items: [
                ("Teriyaki Chicken Bowl", "Glossy sauce and rice", 30, 560, 3, .easy),
                ("Mediterranean Chicken Bowl", "Cucumber, olives and herbs", 28, 520, 2, .easy),
                ("Buffalo Chicken Grain Bowl", "Spicy, crisp and creamy", 24, 540, 2, .easy),
                ("Tandoori Chicken Bowl", "Warm spices and yogurt", 36, 570, 3, .moderate),
                ("Chicken Fajita Bowl", "Peppers, rice and lime", 28, 530, 3, .easy),
                ("Green Goddess Chicken Bowl", "Herby dressing and greens", 22, 490, 2, .easy)
            ]
        ),
        makeRecipes(
            category: .chickenPasta,
            imageName: "pasta",
            items: [
                ("Chicken Alfredo Twirls", "Classic creamy noodles", 28, 650, 3, .easy),
                ("Sun-Dried Tomato Chicken Pasta", "Tangy tomato cream", 30, 610, 3, .easy),
                ("Chicken Piccata Linguine", "Lemon caper sauce", 32, 560, 3, .moderate),
                ("Broccoli Chicken Penne", "Green, creamy and simple", 25, 540, 4, .easy),
                ("Cajun Chicken Rigatoni", "Smoky spice and peppers", 30, 620, 3, .moderate),
                ("Roasted Garlic Chicken Orzo", "Silky one-pot pasta", 26, 550, 3, .easy)
            ]
        ),
        makeRecipes(
            category: .bakery,
            imageName: "dessert",
            items: [
                ("No-Knead Olive Bread", "Crackly crust and herbs", 95, 210, 8, .moderate),
                ("Lemon Yogurt Cake", "Tender, bright crumb", 60, 320, 8, .easy),
                ("Almond Croissant Bake", "Buttery brunch pastry", 45, 430, 6, .moderate),
                ("Herbed Focaccia", "Olive oil and rosemary", 90, 280, 8, .moderate),
                ("Chocolate Rye Cookies", "Deep cocoa and sea salt", 35, 240, 12, .easy),
                ("Berry Breakfast Scones", "Jammy fruit and cream", 42, 310, 8, .moderate)
            ]
        ),
        makeRecipes(
            category: .bread,
            imageName: "dessert",
            items: [
                ("Seeded Country Loaf", "Hearty crumb and crust", 105, 230, 10, .moderate),
                ("Skillet Cornbread", "Golden edges and honey", 35, 280, 8, .easy),
                ("Milk Bread Rolls", "Soft pull-apart rolls", 90, 210, 12, .moderate),
                ("Garlic Pull-Apart Bread", "Buttery herbs in every fold", 55, 330, 8, .easy),
                ("Whole Wheat Pita", "Puffy pocket breads", 75, 190, 8, .moderate),
                ("Parmesan Dinner Rolls", "Savory cheese finish", 70, 240, 10, .easy)
            ]
        ),
        makeRecipes(
            category: .cakes,
            imageName: "dessert",
            items: [
                ("Olive Oil Citrus Cake", "Moist, fragrant slices", 58, 340, 8, .easy),
                ("Chocolate Espresso Cake", "Deep cocoa and coffee", 65, 430, 10, .moderate),
                ("Strawberry Almond Cake", "Jammy fruit and nuts", 55, 360, 8, .easy),
                ("Carrot Spice Cake", "Warm spice and cream cheese", 70, 420, 10, .moderate),
                ("Vanilla Bean Snack Cake", "Simple buttery crumb", 45, 310, 9, .easy),
                ("Pistachio Honey Cake", "Nutty and floral", 60, 390, 8, .moderate)
            ]
        ),
        makeRecipes(
            category: .pastries,
            imageName: "dessert",
            items: [
                ("Apple Hand Pies", "Flaky pockets and cinnamon", 55, 330, 8, .moderate),
                ("Raspberry Danish Twists", "Creamy fruit pastry", 65, 360, 8, .advanced),
                ("Savory Spinach Puffs", "Buttery pastry bites", 38, 290, 10, .easy),
                ("Chocolate Hazelnut Palmiers", "Crisp caramelized layers", 32, 260, 12, .easy),
                ("Pear Frangipane Tartlets", "Almond cream and fruit", 58, 340, 6, .moderate),
                ("Cheddar Chive Biscuits", "Tender savory layers", 28, 240, 8, .easy)
            ]
        ),
        makeRecipes(
            category: .highProtein,
            imageName: "salad",
            items: [
                ("Protein Power Bowl", "Chicken, quinoa and greens", 28, 540, 2, .easy),
                ("Lean Turkey Chili", "Beans and warm spice", 45, 480, 5, .easy),
                ("Salmon Egg Breakfast Plate", "Morning fuel", 18, 520, 1, .easy),
                ("Cottage Cheese Toast Trio", "Savory high-protein toast", 12, 360, 1, .easy),
                ("Steak & Farro Salad", "Peppery greens and herbs", 30, 590, 2, .moderate),
                ("Greek Chicken Meal Prep", "Yogurt marinade and rice", 40, 560, 4, .easy)
            ]
        ),
        makeRecipes(
            category: .proteinBowls,
            imageName: "salad",
            items: [
                ("Citrus Salmon Protein Bowl", "Rice, avocado and greens", 24, 570, 2, .easy),
                ("Steak Chimichurri Bowl", "Farro and peppery greens", 30, 620, 2, .moderate),
                ("Tofu Edamame Bowl", "Plant protein and sesame", 25, 480, 2, .easy),
                ("Turkey Taco Protein Bowl", "Lean turkey and beans", 28, 540, 3, .easy),
                ("Tuna Crunch Bowl", "Cucumber, rice and nori", 15, 430, 1, .easy),
                ("Egg & Lentil Power Bowl", "Jammy eggs and herbs", 22, 460, 2, .easy)
            ]
        ),
        makeRecipes(
            category: .leanMeals,
            imageName: "bowl",
            items: [
                ("Turkey Zucchini Skillet", "Light, herby and quick", 24, 390, 3, .easy),
                ("Lemon Cod with Greens", "Clean citrus plate", 22, 360, 2, .easy),
                ("Chicken Lettuce Wraps", "Crunchy and bright", 20, 340, 3, .easy),
                ("Herbed Shrimp Quinoa", "Fresh herbs and grains", 25, 430, 2, .easy),
                ("Lean Beef Rice Bowl", "Simple protein dinner", 28, 510, 3, .easy),
                ("Cottage Cheese Frittata", "Tender eggs and herbs", 30, 380, 4, .easy)
            ]
        ),
        makeRecipes(
            category: .fitnessMeals,
            imageName: "salad",
            items: [
                ("Post-Workout Chicken Plate", "Rice, greens and yogurt", 30, 580, 2, .easy),
                ("Macro-Friendly Burrito Bowl", "Balanced beans and turkey", 26, 560, 3, .easy),
                ("Salmon Sweet Potato Tray", "Omega-rich sheet pan", 32, 590, 2, .easy),
                ("Egg White Breakfast Tacos", "Light morning protein", 16, 340, 2, .easy),
                ("Greek Tuna Salad Pitas", "Fast, bright and filling", 14, 420, 2, .easy),
                ("Tempeh Recovery Bowl", "Plant protein and grains", 28, 520, 2, .easy)
            ]
        )
    ].flatMap { $0 }

    private static func makeRecipes(
        category: RecipeCategory,
        imageName: String,
        items: [(String, String, Int, Int, Int, RecipeDifficulty)]
    ) -> [Recipe] {
        items.enumerated().map { index, item in
            Recipe(
                id: "recipe-explore-\(category.rawValue)-\(index + 1)",
                title: item.0,
                subtitle: item.1,
                category: category,
                sectionTags: [],
                cookingTimeMinutes: item.2,
                calories: item.3,
                servings: item.4,
                difficulty: item.5,
                imageName: imageName
            )
        }
    }
}
