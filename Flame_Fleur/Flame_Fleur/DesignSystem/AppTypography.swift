import SwiftUI

enum AppTypography {
    static let brandTitle = Font.system(size: 18, weight: .medium, design: .serif)
    static let screenTitle = Font.system(size: 30, weight: .semibold, design: .serif)
    static let recipeDetailTitle = Font.system(size: 30, weight: .semibold, design: .serif)
    static let heroTitle = Font.system(size: 24, weight: .semibold, design: .serif)
    static let sectionTitle = Font.system(size: 17, weight: .semibold)
    static let exploreSectionTitle = Font.system(size: 16, weight: .semibold)
    static let cardTitle = Font.system(size: 16, weight: .semibold)
    static let compactRecipeTitle = Font.system(size: 12.5, weight: .semibold)
    static let categoryCircleLabel = Font.system(size: 12, weight: .medium)
    static let body = Font.system(size: 15.5, weight: .regular)
    static let bodyEmphasis = Font.system(size: 15.5, weight: .semibold)
    static let callout = Font.system(size: 13.5, weight: .regular)
    static let caption = Font.system(size: 12, weight: .medium)
    static let metadata = Font.system(size: 11, weight: .medium)
    static let button = Font.system(size: 15, weight: .semibold)
    static let smallButton = Font.system(size: 12, weight: .semibold)
    static let tabLabel = Font.system(size: 10.5, weight: .medium)

    static let recipeTitle = sectionTitle
    static let smallTitle = compactRecipeTitle
}
