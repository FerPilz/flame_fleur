import Foundation

enum ExploreLaunchContext: String, Hashable {
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

    var title: String {
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

    var subtitle: String {
        switch self {
        case .featured:
            return "Editorial favorites and dishes worth saving."
        case .community:
            return "Recipes loved and shared by the ALLSPICED community."
        case .worldCuisine:
            return "Browse recipes from around the world."
        case .topPicks:
            return "Recommended recipes curated for you."
        case .aiRecommended:
            return "Personalized ideas for what to cook next."
        case .highProtein:
            return "Balanced meals with satisfying protein."
        case .snacks:
            return "Small bites, dips, and quick treats."
        case .breakfast:
            return "Morning meals and relaxed brunch ideas."
        case .eggBased:
            return "Egg-centered breakfasts and skillet plates."
        case .salmon:
            return "Salmon-forward recipes and seafood ideas."
        }
    }
}
