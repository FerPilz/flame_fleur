import Foundation

enum ShoppingCartCategory: String, CaseIterable, Identifiable, Codable, Hashable {
    case produce
    case dairy
    case protein
    case pantry
    case frozen
    case bakery
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .produce:
            return "Produce"
        case .dairy:
            return "Dairy"
        case .protein:
            return "Protein"
        case .pantry:
            return "Pantry"
        case .frozen:
            return "Frozen"
        case .bakery:
            return "Bakery"
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
        case .frozen:
            return "snowflake"
        case .bakery:
            return "birthday.cake.fill"
        case .other:
            return "basket.fill"
        }
    }
}
