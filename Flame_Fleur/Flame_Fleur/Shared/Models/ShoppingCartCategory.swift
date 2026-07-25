import Foundation

enum ShoppingCartCategory: String, CaseIterable, Identifiable, Codable, Hashable {
    case produce
    case dairy
    case protein
    case pantry
    case bakery
    case frozen
    case beverages
    case household
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .produce:
            return "Produce"
        case .dairy:
            return "Dairy & Eggs"
        case .protein:
            return "Meat & Seafood"
        case .pantry:
            return "Pantry"
        case .bakery:
            return "Bakery"
        case .frozen:
            return "Frozen"
        case .beverages:
            return "Beverages"
        case .household:
            return "Household"
        case .other:
            return "Other"
        }
    }

    var systemImage: String {
        switch self {
        case .produce:
            return "leaf.fill"
        case .dairy:
            return "cup.and.saucer.fill"
        case .protein:
            return "flame.fill"
        case .pantry:
            return "cabinet.fill"
        case .bakery:
            return "birthday.cake.fill"
        case .frozen:
            return "snowflake"
        case .beverages:
            return "cup.and.saucer.fill"
        case .household:
            return "house.fill"
        case .other:
            return "basket.fill"
        }
    }
}
