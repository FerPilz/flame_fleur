import Foundation

enum IngredientFilterService {
    struct RecipeIngredientIndex {
        let ingredientIDsByRecipeID: [Recipe.ID: Set<String>]
        let recipeIDsByIngredientID: [String: Set<Recipe.ID>]
        let rawIngredientLinesByRecipeID: [Recipe.ID: [String]]
        let normalizedIngredientLinesByRecipeID: [Recipe.ID: [String]]

        init(
            recipes: [Recipe],
            catalog: [ShoppingIngredientCatalogItem] = SampleShoppingIngredientCatalog.all
        ) {
            let resolver = IngredientAliasResolver(catalog: catalog)

            let rawIngredientLines = Dictionary(uniqueKeysWithValues: recipes.map { recipe in
                let rawValues = recipe.structuredIngredients.flatMap { ingredient in
                    [ingredient.catalogNormalizedName, ingredient.name, ingredient.rawText].compactMap { $0 }
                }
                return (recipe.id, rawValues)
            })
            let normalizedIngredientLines = Dictionary(uniqueKeysWithValues: rawIngredientLines.map {
                ($0.key, $0.value.map(IngredientFilterService.normalize))
            })
            let indexedIngredientIDs = Dictionary(uniqueKeysWithValues: recipes.map { recipe in
                let directIDs = Set(recipe.structuredIngredients.compactMap(\.catalogIngredientID))
                let rawValues = rawIngredientLines[recipe.id] ?? []
                let resolvedIDs = rawValues.reduce(into: directIDs) { ids, value in
                    ids.formUnion(resolver.ingredientIDs(in: value))
                    ids.formUnion(IngredientPickerCatalog.canonicalProteinIDs(in: value))
                }
                let indexedIDs = resolvedIDs
                    .union(resolver.metadataIngredientIDs(for: recipe))
                    .union(IngredientPickerCatalog.canonicalProteinIDs(for: recipe))

                return (recipe.id, indexedIDs)
            })

            self.rawIngredientLinesByRecipeID = rawIngredientLines
            self.normalizedIngredientLinesByRecipeID = normalizedIngredientLines
            self.ingredientIDsByRecipeID = indexedIngredientIDs
            self.recipeIDsByIngredientID = indexedIngredientIDs.reduce(into: [:]) { result, entry in
                let recipeID = entry.key
                for ingredientID in entry.value {
                    result[ingredientID, default: []].insert(recipeID)
                }
            }
        }

        func ingredientIDs(for recipeID: Recipe.ID) -> Set<String> {
            ingredientIDsByRecipeID[recipeID] ?? []
        }
    }

    /// Faceted availability for the recipe ingredient picker. The index is built
    /// outside SwiftUI rendering and this type only intersects its prebuilt sets.
    struct IngredientFacet {
        let baseRecipeIDs: Set<Recipe.ID>
        let recipeIDsByIngredientID: [String: Set<Recipe.ID>]

        init(recipes: [Recipe], index: RecipeIngredientIndex) {
            baseRecipeIDs = Set(recipes.map(\.id))
            recipeIDsByIngredientID = index.recipeIDsByIngredientID
        }

        func matchingRecipeIDs(for selectedIDs: Set<String>) -> Set<Recipe.ID> {
            guard !selectedIDs.isEmpty else {
                return []
            }

            return selectedIDs.reduce(baseRecipeIDs) { currentIDs, ingredientID in
                currentIDs.intersection(recipeIDsByIngredientID[ingredientID] ?? [])
            }
        }

        func projectedRecipeIDs(
            adding ingredientID: String,
            to selectedIDs: Set<String>
        ) -> Set<Recipe.ID> {
            let currentIDs = selectedIDs.isEmpty ? baseRecipeIDs : matchingRecipeIDs(for: selectedIDs)
            return currentIDs.intersection(recipeIDsByIngredientID[ingredientID] ?? [])
        }

        func projectedMatchCount(adding ingredientID: String, to selectedIDs: Set<String>) -> Int {
            projectedRecipeIDs(adding: ingredientID, to: selectedIDs).count
        }

        func availableIngredientIDs(
            catalog: [ShoppingIngredientCatalogItem],
            selectedIDs: Set<String>
        ) -> Set<String> {
            Set(catalog.compactMap { ingredient in
                if selectedIDs.contains(ingredient.id) {
                    return ingredient.id
                }

                return projectedMatchCount(adding: ingredient.id, to: selectedIDs) > 0
                    ? ingredient.id
                    : nil
            })
        }
    }

    struct MatchExplanation {
        let recipeTitle: String
        let rawIngredients: [String]
        let normalizedIngredients: [String]
        let resolvedCanonicalIDs: Set<String>
        let selectedCanonicalIDs: Set<String>
        let missingCanonicalIDs: Set<String>
        let matches: Bool
    }

    static func explainMatch(
        recipe: Recipe,
        selectedIngredientIDs: Set<String>,
        index: RecipeIngredientIndex
    ) -> MatchExplanation {
        let resolvedIDs = index.ingredientIDs(for: recipe.id)
        let missingIDs = selectedIngredientIDs.subtracting(resolvedIDs)

        return MatchExplanation(
            recipeTitle: recipe.title,
            rawIngredients: index.rawIngredientLinesByRecipeID[recipe.id] ?? [],
            normalizedIngredients: index.normalizedIngredientLinesByRecipeID[recipe.id] ?? [],
            resolvedCanonicalIDs: resolvedIDs,
            selectedCanonicalIDs: selectedIngredientIDs,
            missingCanonicalIDs: missingIDs,
            matches: !selectedIngredientIDs.isEmpty && missingIDs.isEmpty
        )
    }

    static func matchingRecipes(
        _ recipes: [Recipe],
        selectedIngredientIDs: Set<String>,
        index: RecipeIngredientIndex
    ) -> [Recipe] {
        guard !selectedIngredientIDs.isEmpty else {
            return []
        }

        let matchingRecipeIDs = IngredientFacet(recipes: recipes, index: index)
            .matchingRecipeIDs(for: selectedIngredientIDs)

        return recipes.enumerated()
            .filter { _, recipe in matchingRecipeIDs.contains(recipe.id) }
            .sorted { lhs, rhs in
                let lhsAdditionalIngredients = max(0, index.ingredientIDs(for: lhs.element.id).count - selectedIngredientIDs.count)
                let rhsAdditionalIngredients = max(0, index.ingredientIDs(for: rhs.element.id).count - selectedIngredientIDs.count)

                if lhsAdditionalIngredients != rhsAdditionalIngredients {
                    return lhsAdditionalIngredients < rhsAdditionalIngredients
                }

                return lhs.offset < rhs.offset
            }
            .map(\.element)
    }

    // Compatibility overload for focused unit tests and legacy callers that supply
    // canonical names instead of catalog IDs.
    static func matchingRecipes(
        _ recipes: [Recipe],
        selectedIngredients: Set<String>
    ) -> [Recipe] {
        guard !selectedIngredients.isEmpty else {
            return recipes
        }

        let normalizedSelection = Set(selectedIngredients.map(normalize).filter { !$0.isEmpty })
        guard !normalizedSelection.isEmpty else {
            return recipes
        }

        return recipes.enumerated()
            .filter { _, recipe in
                containsAll(normalizedSelection, in: recipe)
            }
            .sorted { lhs, rhs in
                let lhsAdditionalIngredients = max(0, lhs.element.structuredIngredients.count - normalizedSelection.count)
                let rhsAdditionalIngredients = max(0, rhs.element.structuredIngredients.count - normalizedSelection.count)

                if lhsAdditionalIngredients != rhsAdditionalIngredients {
                    return lhsAdditionalIngredients < rhsAdditionalIngredients
                }

                return lhs.offset < rhs.offset
            }
            .map(\.element)
    }

    static func containsAll(_ selectedIngredients: Set<String>, in recipe: Recipe) -> Bool {
        let normalizedSelection = Set(selectedIngredients.map(normalize).filter { !$0.isEmpty })
        guard !normalizedSelection.isEmpty else {
            return true
        }

        let ingredientValues = recipe.structuredIngredients.flatMap { ingredient in
            [ingredient.catalogNormalizedName, ingredient.name, ingredient.rawText]
                .compactMap { $0 }
                .map(normalize)
        }

        return normalizedSelection.allSatisfy { selectedIngredient in
            ingredientValues.contains { ingredientText in
                containsPhrase(selectedIngredient, in: ingredientText)
            }
        }
    }

    static func normalize(_ value: String) -> String {
        IngredientSuggestionEngine.normalize(value)
    }

    fileprivate static func containsPhrase(_ phrase: String, in text: String) -> Bool {
        let phraseTokens = phrase.split(separator: " ")
        let textTokens = text.split(separator: " ")

        guard !phraseTokens.isEmpty, textTokens.count >= phraseTokens.count else {
            return false
        }

        return (0...(textTokens.count - phraseTokens.count)).contains { startIndex in
            textTokens[startIndex..<(startIndex + phraseTokens.count)].elementsEqual(phraseTokens)
        }
    }
}

enum IngredientPickerCatalog {
    static let chickenID = "protein_chicken"
    static let beefID = "protein_beef"
    static let porkID = "protein_pork"
    static let lambID = "protein_lamb"
    static let fishID = "protein_fish"
    static let seafoodID = "protein_seafood"
    static let eggsID = "protein_eggs"
    static let tofuID = "protein_tofu"
    static let beansID = "protein_beans"

    static func items(from catalog: [ShoppingIngredientCatalogItem]) -> [ShoppingIngredientCatalogItem] {
        let nonProteinItems = catalog.filter { !isReplacedByCanonicalProtein($0) }
        return nonProteinItems + canonicalProteinItems(from: catalog)
    }

    static func canonicalProteinIDs(in rawIngredient: String) -> Set<String> {
        let normalizedIngredient = IngredientFilterService.normalize(rawIngredient)
        guard !normalizedIngredient.isEmpty else { return [] }

        return Set(proteinAliases.compactMap { proteinID, aliases in
            aliases.contains { IngredientFilterService.containsPhrase($0, in: normalizedIngredient) }
                ? proteinID
                : nil
        })
    }

    static func canonicalProteinIDs(for recipe: Recipe) -> Set<String> {
        // Seed chicken recipes occasionally omit the protein from their ingredient
        // list; their category remains the authoritative fallback.
        recipe.category == .chicken ? [chickenID] : []
    }

    private static func canonicalProteinItems(
        from catalog: [ShoppingIngredientCatalogItem]
    ) -> [ShoppingIngredientCatalogItem] {
        canonicalProteinDefinitions.map { definition in
            ShoppingIngredientCatalogItem(
                id: definition.id,
                displayName: definition.title,
                normalizedName: IngredientFilterService.normalize(definition.title),
                category: "Protein",
                defaultUnit: "",
                estimatedPrice: 0,
                imageName: catalog.first(where: { $0.id == definition.imageSourceID })?.imageName
            )
        }
    }

    private static func isReplacedByCanonicalProtein(_ item: ShoppingIngredientCatalogItem) -> Bool {
        item.category == "Protein" || canonicalProteinIDs(in: item.normalizedName).isEmpty == false
    }

    private static let canonicalProteinDefinitions: [(id: String, title: String, imageSourceID: String)] = [
        (chickenID, "Chicken", "ingredient_chicken_breast"),
        (beefID, "Beef", "ingredient_ground_beef"),
        (porkID, "Pork", "ingredient_pork_chops"),
        (lambID, "Lamb", "ingredient_lamb_chops"),
        (fishID, "Fish", "ingredient_white_fish_fillets"),
        (seafoodID, "Seafood", "ingredient_shrimp"),
        (eggsID, "Eggs", "ingredient_eggs"),
        (tofuID, "Tofu", "ingredient_tofu"),
        (beansID, "Beans", "ingredient_beans")
    ]

    private static let proteinAliases: [String: Set<String>] = [
        chickenID: ["chicken", "chicken breast", "chicken breasts", "chicken thigh", "chicken thighs", "chicken wing", "chicken wings", "whole chicken", "ground chicken", "roast chicken", "cooked chicken", "shredded chicken"],
        beefID: ["beef", "ground beef", "beef steak", "steak", "sirloin", "ribeye", "flank steak", "beef chuck", "roast beef"],
        porkID: ["pork", "pork chop", "pork chops", "pork shoulder", "pork loin", "pork tenderloin", "ground pork", "bacon", "ham"],
        lambID: ["lamb", "lamb chop", "lamb chops", "ground lamb", "lamb shoulder", "lamb leg"],
        fishID: ["salmon", "tuna", "cod", "tilapia", "trout", "halibut", "haddock", "white fish", "fish fillet", "fish fillets"],
        seafoodID: ["shrimp", "prawn", "prawns", "crab", "lobster", "scallop", "scallops", "mussel", "mussels", "clam", "clams", "squid", "octopus"],
        eggsID: ["egg", "eggs", "whole egg", "whole eggs", "large egg", "large eggs", "beaten egg", "beaten eggs"],
        tofuID: ["tofu", "firm tofu", "extra firm tofu", "silken tofu"],
        beansID: ["beans", "black beans", "kidney beans", "cannellini beans", "pinto beans", "navy beans", "chickpeas", "lentils", "brown lentils", "green lentils"]
    ]
}

private struct IngredientAliasResolver {
    private let aliasesByIngredientID: [String: Set<String>]
    private let chickenBreastID: String?

    init(catalog: [ShoppingIngredientCatalogItem]) {
        aliasesByIngredientID = Dictionary(uniqueKeysWithValues: catalog.map { item in
            (item.id, Self.aliases(for: item.normalizedName))
        })
        chickenBreastID = catalog.first { IngredientFilterService.normalize($0.normalizedName) == "chicken breast" }?.id
    }

    func ingredientIDs(in rawIngredient: String) -> Set<String> {
        let normalizedRawIngredient = IngredientFilterService.normalize(rawIngredient)
        guard !normalizedRawIngredient.isEmpty else {
            return []
        }

        return Set(aliasesByIngredientID.compactMap { ingredientID, aliases in
            aliases.contains { alias in
                IngredientFilterService.containsPhrase(alias, in: normalizedRawIngredient)
            } ? ingredientID : nil
        })
    }

    func metadataIngredientIDs(for recipe: Recipe) -> Set<String> {
        // Seed chicken recipes currently omit the primary protein from their
        // ingredient arrays. Category metadata is the authoritative fallback
        // for this known seed-data gap, not a general raw-text alias.
        guard recipe.category == .chicken, let chickenBreastID else {
            return []
        }

        return [chickenBreastID]
    }

    private static func aliases(for normalizedName: String) -> Set<String> {
        let name = IngredientFilterService.normalize(normalizedName)
        var aliases: Set<String> = [name]

        switch name {
        case let value where value.contains("chicken"):
            aliases.formUnion(["chicken", "chicken breast", "chicken breasts", "chicken thigh", "chicken thighs", "boneless chicken breast", "shredded chicken"])
        case let value where value.contains("garlic"):
            aliases.formUnion(["garlic", "garlic clove", "garlic cloves", "minced garlic"])
        case let value where value.contains("rice"):
            aliases.formUnion(["rice", "white rice", "brown rice", "jasmine rice", "basmati rice", "cooked rice", "arborio rice"])
        case let value where value.contains("tomato"):
            aliases.formUnion(["tomato", "tomatoes", "cherry tomato", "cherry tomatoes"])
        default:
            break
        }

        if name.hasSuffix("ies") {
            aliases.insert(String(name.dropLast(3)) + "y")
        } else if name.hasSuffix("s"), name.count > 3 {
            aliases.insert(String(name.dropLast()))
        } else if name.count > 2 {
            aliases.insert(name + "s")
        }

        return aliases.filter { !$0.isEmpty }
    }
}
