import Foundation

enum HomeShowcaseSection: String, CaseIterable, Identifiable {
    case featured
    case community
    case worldCuisine
    case topPicks
    case aiRecommended
    case highProtein
    case snacks
    case breakfast
    case eggBased
    case salmon

    var id: String { rawValue }

    var headerTitle: String {
        switch self {
        case .featured:
            return "Featured"
        case .community:
            return "Community"
        case .worldCuisine:
            return "World Cuisine"
        case .topPicks:
            return "Top Picks for You"
        case .aiRecommended:
            return "AI Recommend"
        case .highProtein:
            return "High Protein"
        case .snacks:
            return "Snacks"
        case .breakfast:
            return "Breakfast"
        case .eggBased:
            return "Egg Based"
        case .salmon:
            return "Salmon"
        }
    }

    var selectorTitle: String {
        switch self {
        case .featured:
            return "Featured"
        case .community:
            return "Community"
        case .topPicks:
            return "Top Picks"
        case .aiRecommended:
            return "AI Recommend"
        default:
            return headerTitle
        }
    }

    var systemImage: String {
        switch self {
        case .featured:
            return "leaf.fill"
        case .community:
            return "person.2.fill"
        case .worldCuisine:
            return "globe.americas.fill"
        case .topPicks:
            return "star.fill"
        case .aiRecommended:
            return "sparkles"
        case .highProtein:
            return "bolt.fill"
        case .snacks:
            return "takeoutbag.and.cup.and.straw.fill"
        case .breakfast:
            return "cup.and.saucer.fill"
        case .eggBased:
            return "egg.fill"
        case .salmon:
            return "fish.fill"
        }
    }

    var exploreLaunchContext: ExploreLaunchContext {
        ExploreLaunchContext(rawValue: rawValue) ?? .featured
    }

    var selectorOption: TopSegmentOption {
        TopSegmentOption(id: id, title: selectorTitle, systemImage: systemImage)
    }

    static let carouselSections: [HomeShowcaseSection] = [
        .community,
        .topPicks,
        .aiRecommended,
        .worldCuisine,
        .highProtein,
        .snacks,
        .breakfast,
        .eggBased,
        .salmon
    ]

    static let selectorSections: [HomeShowcaseSection] = [
        .featured,
        .community,
        .topPicks,
        .aiRecommended,
        .worldCuisine,
        .highProtein,
        .snacks,
        .breakfast,
        .eggBased,
        .salmon
    ]
}
