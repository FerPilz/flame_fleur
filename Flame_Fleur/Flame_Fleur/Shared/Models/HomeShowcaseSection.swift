import Foundation

enum HomeShowcaseSection: String, CaseIterable, Identifiable {
    case featured
    case beef
    case vegetarian
    case chickenSalad
    case tuna
    case plantBasedBowls
    case piesAndTarts
    case mexican
    case korean
    case breakfastBakes
    case cookies
    case highProtein

    var id: String { rawValue }

    var headerTitle: String {
        switch self {
        case .featured:
            return "Featured"
        case .beef:
            return "Beef"
        case .vegetarian:
            return "Vegetarian"
        case .chickenSalad:
            return "Chicken Salad"
        case .tuna:
            return "Tuna"
        case .plantBasedBowls:
            return "Plant Based Bowls"
        case .piesAndTarts:
            return "Pies & Tarts"
        case .mexican:
            return "Mexican"
        case .korean:
            return "Korean"
        case .breakfastBakes:
            return "Breakfast Bakes"
        case .cookies:
            return "Cookies"
        case .highProtein:
            return "High Protein"
        }
    }

    var selectorTitle: String {
        switch self {
        case .featured:
            return "Featured"
        case .beef:
            return "Beef"
        case .vegetarian:
            return "Vegetarian"
        case .chickenSalad:
            return "Chicken Salad"
        case .tuna:
            return "Tuna"
        case .plantBasedBowls:
            return "Plant Based Bowls"
        case .piesAndTarts:
            return "Pies & Tarts"
        case .mexican:
            return "Mexican"
        case .korean:
            return "Korean"
        case .breakfastBakes:
            return "Breakfast Bakes"
        case .cookies:
            return "Cookies"
        case .highProtein:
            return "High Protein"
        }
    }

    var iconAssetName: String {
        switch self {
        case .featured:
            return "icon_featured"
        case .beef:
            return "icon_beef"
        case .vegetarian:
            return "icon_vegetarian"
        case .chickenSalad:
            return "icon_chicken_salad"
        case .tuna:
            return "icon_tuna"
        case .plantBasedBowls:
            return "icon_plant_based_bowls"
        case .piesAndTarts:
            return "icon_pies_tarts"
        case .mexican:
            return "icon_mexican"
        case .korean:
            return "icon_korean"
        case .breakfastBakes:
            return "icon_breakfast_bakes"
        case .cookies:
            return "icon_cookies"
        case .highProtein:
            return "icon_high_protein"
        }
    }

    var exploreLaunchContext: ExploreLaunchContext {
        switch self {
        case .featured:
            return .featured
        case .beef, .tuna, .highProtein:
            return .highProtein
        case .vegetarian, .plantBasedBowls:
            return .highProtein
        case .chickenSalad:
            return .highProtein
        case .piesAndTarts, .cookies, .breakfastBakes:
            return .breakfast
        case .mexican, .korean:
            return .worldCuisine
        }
    }

    var selectorOption: TopSegmentOption {
        TopSegmentOption(id: id, title: selectorTitle, iconAssetName: iconAssetName)
    }

    static let carouselSections: [HomeShowcaseSection] = [
        .beef,
        .vegetarian,
        .chickenSalad,
        .tuna,
        .plantBasedBowls,
        .piesAndTarts,
        .mexican,
        .korean,
        .breakfastBakes,
        .cookies,
        .highProtein
    ]

    static let selectorSections: [HomeShowcaseSection] = [
        .featured,
        .beef,
        .vegetarian,
        .chickenSalad,
        .tuna,
        .plantBasedBowls,
        .piesAndTarts,
        .mexican,
        .korean,
        .breakfastBakes,
        .cookies,
        .highProtein
    ]
}
