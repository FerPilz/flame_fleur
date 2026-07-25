import SwiftUI

enum CartCategoryIconResolver {
    static func assetName(for category: ShoppingCartCategory) -> String {
        switch category {
        case .produce:
            return "cart_category_produce"
        case .dairy:
            return "cart_category_dairy_eggs"
        case .protein:
            return "cart_category_meat_seafood"
        case .pantry:
            return "cart_category_pantry"
        case .bakery:
            return "cart_category_bakery"
        case .frozen:
            return "cart_category_frozen"
        case .beverages:
            return "cart_category_beverages"
        case .household:
            return "cart_category_household"
        case .other:
            return "cart_category_other"
        }
    }

    static func fallbackSystemImageName(for category: ShoppingCartCategory) -> String {
        category.systemImage
    }

    static func tintColor(for category: ShoppingCartCategory) -> Color {
        switch category {
        case .produce:
            return AppColors.olive
        case .dairy:
            return AppColors.premiumGold
        case .protein:
            return AppColors.burntOrange
        case .pantry, .household:
            return AppColors.secondaryText
        case .frozen:
            return AppColors.tertiaryText
        case .bakery, .beverages:
            return AppColors.olive
        case .other:
            return AppColors.darkOlive
        }
    }
}
