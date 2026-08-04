import SwiftUI

enum AppTypography {
    // MARK: - Brand / Main titles

    static let brandTitle = Font.system(size: 18, weight: .medium, design: .serif)
    static let allSpicedBrandTitle = Font.custom("Copperplate-Bold", size: 25)
    static let screenTitle = Font.system(size: 30, weight: .semibold, design: .serif)

    // MARK: - Charter Bold title typography

    // Use Charter Bold for category, subcategory, and recipe titles.
    // SwiftUI reference:
    // .custom("Charter-Bold", size: SIZE)
    //
    // UIKit reference:
    // UIFont(name: "Charter-Bold", size: SIZE)

    static let recipeDetailTitle = Font.custom("Charter-Bold", size: 28)
    static let heroTitle = Font.custom("Charter-Bold", size: 24)

    static let sectionTitle = Font.custom("Charter-Bold", size: 20)
    static let exploreSectionTitle = Font.custom("Charter-Bold", size: 16)

    static let cardTitle = Font.custom("Charter-Bold", size: 16)
    static let compactRecipeTitle = Font.custom("Charter-Bold", size: 12.5)
    static let compactRecipePreviewTitle = Font.system(size: 14.5, weight: .semibold)

    static let categoryCircleLabel = Font.custom("Charter-Bold", size: 12)
    static let exploreCategoryCircleLabel = Font.custom("Charter-Bold", size: 15)
    static let exploreSubcategoryCircleLabel = Font.custom("Charter-Bold", size: 14)

    // MARK: - Body / metadata / buttons

    static let body = Font.system(size: 15.5, weight: .regular)
    static let bodyEmphasis = Font.system(size: 15.5, weight: .semibold)
    static let callout = Font.system(size: 13.5, weight: .regular)
    static let caption = Font.system(size: 12, weight: .medium)
    static let exploreIngredientLabel = Font.system(size: 12, weight: .medium)
    static let metadata = Font.system(size: 11, weight: .medium)
    static let button = Font.system(size: 15, weight: .semibold)
    static let smallButton = Font.system(size: 12, weight: .semibold)
    static let ingredientActionButton = Font.system(size: 13.5, weight: .semibold)
    static let tabLabel = Font.system(size: 10.5, weight: .medium)

    // MARK: - Aliases

    static let recipeTitle = sectionTitle
    static let smallTitle = compactRecipeTitle
}
