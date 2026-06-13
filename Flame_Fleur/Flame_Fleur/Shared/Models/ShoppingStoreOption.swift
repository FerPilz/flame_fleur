import Foundation

enum ShoppingStoreOption: String, CaseIterable, Identifiable, Codable, Hashable {
    case wholeFoods
    case traderJoes
    case costco
    case localMarket
    case marketBasket

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .wholeFoods:
            return "Whole Foods"
        case .traderJoes:
            return "Trader Joe's"
        case .costco:
            return "Costco"
        case .localMarket:
            return "Local Market"
        case .marketBasket:
            return "Market Basket"
        }
    }

    var compactDisplayName: String {
        switch self {
        case .wholeFoods:
            return "Whole..."
        case .traderJoes:
            return "Trader..."
        case .costco:
            return "Costco"
        case .localMarket:
            return "Local"
        case .marketBasket:
            return "Market"
        }
    }

    static func option(named storeName: String) -> ShoppingStoreOption {
        allCases.first { $0.displayName == storeName } ?? .localMarket
    }
}
