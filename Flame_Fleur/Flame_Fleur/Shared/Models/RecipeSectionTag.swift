import Foundation

enum RecipeSectionTag: String, CaseIterable, Identifiable {
    case featured
    case community
    case topPicks
    case aiRecommended
    case favorites

    var id: String { rawValue }

    var title: String {
        switch self {
        case .featured:
            return "Featured"
        case .community:
            return "Community"
        case .topPicks:
            return "Top Picks"
        case .aiRecommended:
            return "AI Recommend"
        case .favorites:
            return "Favorites"
        }
    }
}
