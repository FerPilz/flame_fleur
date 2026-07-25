import Foundation

enum RecipeInsightResolver {
    nonisolated static func cuisineName(
        for recipe: Recipe,
        includeCategoryFallback: Bool = true
    ) -> String? {
        if recipe.categoryGroupID == "world-cuisine",
           let subcategoryTitle = recipe.subcategoryTitle?.trimmedNonEmpty {
            return subcategoryTitle
        }

        switch recipe.category {
        case .italian, .mexican, .korean:
            return recipe.category.title
        default:
            break
        }

        let searchableText = [
            recipe.title,
            recipe.subtitle,
            recipe.subcategoryTitle ?? "",
            recipe.description,
            recipe.tags.joined(separator: " ")
        ]
        .joined(separator: " ")
        .lowercased()

        for entry in knownCuisineKeywords where searchableText.contains(entry.keyword) {
            return entry.displayName
        }

        guard includeCategoryFallback else {
            return nil
        }

        if let subcategoryTitle = recipe.subcategoryTitle?.trimmedNonEmpty {
            return subcategoryTitle
        }

        return recipe.category.title
    }

    nonisolated static func normalizedIngredientNames(for recipe: Recipe) -> [String] {
        recipe.structuredIngredients
            .map(\.normalizedName)
            .filter { !$0.isEmpty }
    }

    nonisolated static func nutritionSummary(for recipe: Recipe) -> NutritionSummary {
        NutritionCalculator.summary(from: recipe)
    }

    private static let knownCuisineKeywords: [(keyword: String, displayName: String)] = [
        ("italian", "Italian"),
        ("mexican", "Mexican"),
        ("korean", "Korean"),
        ("german", "German"),
        ("japanese", "Japanese"),
        ("thai", "Thai"),
        ("indian", "Indian"),
        ("chinese", "Chinese")
    ]
}

private extension String {
    var trimmedNonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
