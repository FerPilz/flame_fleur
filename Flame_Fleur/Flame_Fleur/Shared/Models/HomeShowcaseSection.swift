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

    var systemImage: String {
        switch self {
        case .featured:
            return "leaf.fill"
        case .beef:
            return "fork.knife"
        case .vegetarian:
            return "leaf.fill"
        case .chickenSalad:
            return "leaf.circle.fill"
        case .tuna:
            return "fish.fill"
        case .plantBasedBowls:
            return "takeoutbag.and.cup.and.straw.fill"
        case .piesAndTarts:
            return "birthday.cake.fill"
        case .mexican:
            return "taco.fill"
        case .korean:
            return "bowl.fill"
        case .breakfastBakes:
            return "croissant.fill"
        case .cookies:
            return "cookie.fill"
        case .highProtein:
            return "dumbbell.fill"
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
        TopSegmentOption(id: id, title: selectorTitle, systemImage: systemImage)
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
