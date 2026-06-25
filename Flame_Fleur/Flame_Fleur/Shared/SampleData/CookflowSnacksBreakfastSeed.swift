import Foundation

enum CookflowSnacksBreakfastSeed {
    static let groups: [ExploreCategoryGroup] = loadGroups()
    static let recipes: [Recipe] = loadRecipes()
    static let expectedRecipeCountsBySubcategoryID: [String: Int] = loadExpectedRecipeCountsBySubcategoryID()

    private static let resourceName = "cookflow_snacks_breakfast_seed"

    private static func loadGroups(bundle: Bundle = .main) -> [ExploreCategoryGroup] {
        guard let document = loadDocument(bundle: bundle) else {
            return []
        }

        let subcategoriesByCategoryID = Dictionary(
            grouping: document.subcategories.sorted { compareSubcategories($0, $1) },
            by: \.categoryId
        )

        return document.categories
            .sorted { compareCategories($0, $1) }
            .map { category in
                let subcategories = (subcategoriesByCategoryID[category.id] ?? [])
                    .map { subcategory in
                        ExploreSubcategory(
                            id: subcategory.id,
                            title: subcategory.title,
                            parentGroupID: category.id,
                            imageName: subcategory.imageKey,
                            category: recipeCategory(for: subcategory.id)
                        )
                    }

                return ExploreCategoryGroup(
                    id: category.id,
                    title: category.title,
                    subtitle: category.description,
                    imageName: category.imageKey,
                    subcategories: subcategories
                )
            }
    }

    private static func loadRecipes(bundle: Bundle = .main) -> [Recipe] {
        guard let document = loadDocument(bundle: bundle) else {
            return []
        }

        let subcategoryTitles = Dictionary(uniqueKeysWithValues: document.subcategories.map { ($0.id, $0.title) })

        return document.recipes
            .filter { $0.enabled }
            .sorted { compareRecipes($0, $1) }
            .map { seedRecipe in
                Recipe(
                    id: seedRecipe.id,
                    title: seedRecipe.title,
                    subtitle: seedRecipe.shortDescription,
                    description: seedRecipe.description,
                    categoryGroupID: seedRecipe.categoryId,
                    subcategoryID: seedRecipe.subcategoryId,
                    subcategoryTitle: subcategoryTitles[seedRecipe.subcategoryId],
                    category: recipeCategory(for: seedRecipe.subcategoryId),
                    sectionTags: seedRecipe.featured ? [.featured] : [],
                    prepTimeMinutes: seedRecipe.prepMinutes,
                    cookingTimeMinutes: seedRecipe.cookMinutes,
                    totalTimeMinutes: seedRecipe.totalMinutes,
                    calories: seedRecipe.calories,
                    servings: seedRecipe.servings,
                    difficulty: seedRecipe.difficulty.recipeDifficulty,
                    tags: seedRecipe.tags,
                    imageName: seedRecipe.imageKey,
                    ingredients: seedRecipe.ingredients.map(makeIngredientLine(from:)),
                    structuredIngredients: seedRecipe.ingredients.map(makeIngredient(from:)),
                    instructions: seedRecipe.instructions,
                    nutrition: RecipeNutrition(
                        calories: seedRecipe.nutrition.calories,
                        proteinGrams: seedRecipe.nutrition.proteinGrams,
                        carbsGrams: seedRecipe.nutrition.carbsGrams,
                        fatGrams: seedRecipe.nutrition.fatGrams,
                        fiberGrams: 0,
                        sugarGrams: 0,
                        sodiumMilligrams: 0
                    )
                )
            }
    }

    private static func loadExpectedRecipeCountsBySubcategoryID(bundle: Bundle = .main) -> [String: Int] {
        guard let document = loadDocument(bundle: bundle) else {
            return [:]
        }

        return Dictionary(
            uniqueKeysWithValues: document.subcategories.map { subcategory in
                let expectedCount: Int
                if subcategory.id == "breakfast-egg-based" {
                    expectedCount = 6
                } else {
                    expectedCount = ["snacks", "breakfast"].contains(subcategory.categoryId) ? 5 : 6
                }
                return (subcategory.id, expectedCount)
            }
        )
    }

    private static func loadDocument(bundle: Bundle) -> SeedDocument? {
        let candidateURLs = [
            bundle.url(forResource: resourceName, withExtension: "json"),
            bundle.url(forResource: resourceName, withExtension: "json", subdirectory: "Resources")
        ]

        guard let url = candidateURLs.compactMap({ $0 }).first,
              let data = try? Data(contentsOf: url) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(SeedDocument.self, from: data)
        } catch {
            print("CookflowSnacksBreakfastSeed: failed to load seed document: \(error)")
            return nil
        }
    }

    private static func compareCategories(_ lhs: SeedCategory, _ rhs: SeedCategory) -> Bool {
        if lhs.sortOrder != rhs.sortOrder {
            return lhs.sortOrder < rhs.sortOrder
        }

        return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
    }

    private static func compareSubcategories(_ lhs: SeedSubcategory, _ rhs: SeedSubcategory) -> Bool {
        if lhs.categoryId != rhs.categoryId {
            return lhs.categoryId < rhs.categoryId
        }

        if lhs.sortOrder != rhs.sortOrder {
            return lhs.sortOrder < rhs.sortOrder
        }

        return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
    }

    private static func compareRecipes(_ lhs: SeedRecipe, _ rhs: SeedRecipe) -> Bool {
        if lhs.categoryId != rhs.categoryId {
            return lhs.categoryId < rhs.categoryId
        }

        if lhs.subcategoryId != rhs.subcategoryId {
            return lhs.subcategoryId < rhs.subcategoryId
        }

        return lhs.sortOrder < rhs.sortOrder
    }

    private static func recipeCategory(for subcategoryID: String) -> RecipeCategory {
        switch subcategoryID {
        case "snacks-savory-bites":
            return .salad
        case "snacks-sweet-snacks":
            return .dessert
        case "snacks-high-protein-snacks":
            return .highProtein
        case "snacks-fresh-and-light":
            return .salad
        case "snacks-dips-and-spreads":
            return .pantry
        case "snacks-crunchy-snacks":
            return .pantry
        case "breakfast-high-protein-breakfast":
            return .highProtein
        case "breakfast-oats-and-grains":
            return .grainBowl
        case "breakfast-smoothies-and-bowls":
            return .grainBowl
        default:
            return .breakfast
        }
    }

    private static func makeIngredientLine(from ingredient: SeedRecipeIngredient) -> String {
        let quantity = ingredient.quantity.map { formatQuantity($0) }
        let unit = ingredient.unit?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
        let trimmedName = ingredient.name.trimmingCharacters(in: .whitespacesAndNewlines)
        var parts: [String] = []

        if let quantity {
            parts.append(quantity)
        }

        if let unit {
            parts.append(unit)
        }

        if !trimmedName.isEmpty {
            parts.append(trimmedName)
        }

        return parts.joined(separator: " ")
    }

    private static func makeIngredient(from ingredient: SeedRecipeIngredient) -> RecipeIngredient {
        let quantity = ingredient.quantity ?? 1
        let unit = ingredient.unit?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let displayQuantity = [formatQuantity(quantity), unit]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        let rawText = [displayQuantity, ingredient.name.trimmingCharacters(in: .whitespacesAndNewlines)]
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return RecipeIngredient(
            name: ingredient.name.trimmingCharacters(in: .whitespacesAndNewlines),
            quantity: quantity,
            unit: unit,
            category: ingredient.department.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: nil,
            rawText: rawText,
            displayQuantity: displayQuantity,
            isCustomIngredient: false
        )
    }

    private static func formatQuantity(_ quantity: Double) -> String {
        let rounded = quantity.rounded()
        if abs(quantity - rounded) < 0.001 {
            return String(Int(rounded))
        }

        let commonFractions: [(value: Double, text: String)] = [
            (0.25, "1/4"),
            (0.333, "1/3"),
            (0.5, "1/2"),
            (0.666, "2/3"),
            (0.75, "3/4")
        ]

        let whole = Int(quantity)
        let fractional = quantity - Double(whole)

        if let matched = commonFractions.first(where: { abs(fractional - $0.value) < 0.035 }) {
            if whole > 0 {
                return "\(whole) \(matched.text)"
            }

            return matched.text
        }

        return String(format: "%.2f", quantity)
            .replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\.$"#, with: "", options: .regularExpression)
    }
}

private struct SeedDocument: Decodable {
    let categories: [SeedCategory]
    let subcategories: [SeedSubcategory]
    let recipes: [SeedRecipe]
}

private struct SeedCategory: Decodable {
    let id: String
    let title: String
    let description: String
    let sortOrder: Int
    let enabled: Bool
    let imageKey: String
    let imageFile: String
}

private struct SeedSubcategory: Decodable {
    let id: String
    let slug: String
    let categoryId: String
    let title: String
    let description: String
    let sortOrder: Int
    let enabled: Bool
    let displayType: String
    let imageKey: String
    let imageFile: String
}

private struct SeedRecipe: Decodable {
    let id: String
    let slug: String
    let title: String
    let description: String
    let shortDescription: String
    let categoryId: String
    let subcategoryId: String
    let mealType: String
    let sortOrder: Int
    let enabled: Bool
    let featured: Bool
    let prepMinutes: Int
    let cookMinutes: Int
    let totalMinutes: Int
    let servings: Int
    let difficulty: SeedDifficulty
    let costLevel: String
    let cuisine: String
    let calories: Int
    let proteinGrams: Int
    let carbsGrams: Int
    let fatGrams: Int
    let nutrition: SeedNutrition
    let tags: [String]
    let dietary: [String]
    let ingredients: [SeedRecipeIngredient]
    let instructions: [String]
    let imageKey: String
    let imageFile: String
    let imageAlt: String
    let imagePrompt: String
}

private struct SeedRecipeIngredient: Decodable {
    let name: String
    let quantity: Double?
    let unit: String?
    let department: String
}

private struct SeedNutrition: Decodable {
    let calories: Int
    let proteinGrams: Int
    let carbsGrams: Int
    let fatGrams: Int
}

private enum SeedDifficulty: String, Decodable {
    case easy = "Easy"
    case moderate = "Medium"

    var recipeDifficulty: RecipeDifficulty {
        switch self {
        case .easy:
            return .easy
        case .moderate:
            return .moderate
        }
    }
}

private extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
