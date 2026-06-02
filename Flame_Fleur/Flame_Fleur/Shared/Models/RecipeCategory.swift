import Foundation

enum RecipeCategory: String, CaseIterable, Identifiable, Codable {
    case italian
    case mexican
    case korean
    case fish
    case meat
    case seafood
    case tofuTempeh
    case beansLentils
    case mushrooms
    case pasta
    case chicken
    case grilledChicken
    case chickenBowls
    case chickenPasta
    case bakery
    case bread
    case cakes
    case pastries
    case highProtein
    case proteinBowls
    case leanMeals
    case fitnessMeals
    case vegetarian
    case soup
    case dessert
    case breakfast
    case salad
    case curry
    case grainBowl
    case pantry
    case toast

    var id: String { rawValue }

    var title: String {
        switch self {
        case .italian:
            return "Italian"
        case .mexican:
            return "Mexican"
        case .korean:
            return "Korean"
        case .fish:
            return "Fish"
        case .meat:
            return "Meat"
        case .seafood:
            return "Seafood"
        case .tofuTempeh:
            return "Tofu & Tempeh"
        case .beansLentils:
            return "Beans & Lentils"
        case .mushrooms:
            return "Mushrooms"
        case .pasta:
            return "Pasta"
        case .chicken:
            return "Chicken"
        case .grilledChicken:
            return "Grilled Chicken"
        case .chickenBowls:
            return "Chicken Bowls"
        case .chickenPasta:
            return "Chicken Pasta"
        case .bakery:
            return "Bakery"
        case .bread:
            return "Bread"
        case .cakes:
            return "Cakes"
        case .pastries:
            return "Pastries"
        case .highProtein:
            return "High Protein"
        case .proteinBowls:
            return "Protein Bowls"
        case .leanMeals:
            return "Lean Meals"
        case .fitnessMeals:
            return "Fitness Meals"
        case .vegetarian:
            return "Vegetarian"
        case .soup:
            return "Soup"
        case .dessert:
            return "Dessert"
        case .breakfast:
            return "Breakfast"
        case .salad:
            return "Salad"
        case .curry:
            return "Curry"
        case .grainBowl:
            return "Grain Bowl"
        case .pantry:
            return "Pantry"
        case .toast:
            return "Toast"
        }
    }
}
