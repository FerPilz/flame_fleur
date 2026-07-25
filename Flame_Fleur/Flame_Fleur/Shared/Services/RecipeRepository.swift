import Foundation

struct RecipeRepository {
    static let shared = RecipeRepository()

    private let seededRecipes: [Recipe]

    init(allRecipes: [Recipe] = RecipeSeedLoader.loadRecipes(fallbackRecipes: SampleRecipes.previewFallbackRecipes)) {
        self.seededRecipes = allRecipes
    }

    var allRecipes: [Recipe] {
        mergedRecipes(seededRecipes, UserRecipeStore.shared.myRecipes)
    }

    var myRecipes: [Recipe] {
        UserRecipeStore.shared.myRecipes
    }

    var featuredRecipes: [Recipe] {
        recipes(for: RecipeSectionTag.featured)
    }

    var communityRecipes: [Recipe] {
        recipes(for: RecipeSectionTag.community)
    }

    var topPicksRecipes: [Recipe] {
        recipes(for: RecipeSectionTag.topPicks)
    }

    var aiRecommendedRecipes: [Recipe] {
        recipes(for: RecipeSectionTag.aiRecommended)
    }

    func recipe(id: String) -> Recipe? {
        allRecipes.first { $0.id == id }
    }

    func recipes(for category: RecipeCategory) -> [Recipe] {
        allRecipes.filter { $0.category == category }
    }

    func recipes(forSubcategoryID subcategoryID: String) -> [Recipe] {
        allRecipes.filter { $0.subcategoryID == subcategoryID }
    }

    func recipes(forSubcategory subcategory: ExploreSubcategory) -> [Recipe] {
        recipes(forSubcategoryID: subcategory.id)
    }

    func recipes(forCategoryGroupID categoryGroupID: String) -> [Recipe] {
        allRecipes.filter { $0.categoryGroupID == categoryGroupID }
    }

    func recipes(for sectionTag: RecipeSectionTag) -> [Recipe] {
        allRecipes.filter { $0.sectionTags.contains(sectionTag) }
    }

    func homeCarouselRecipes(for section: HomeShowcaseSection) -> [Recipe] {
        switch section {
        case .featured:
            return uniqueLimited(featuredRecipes, limit: 6)
        case .beef:
            return uniqueLimited(beefRecipes(), limit: 6)
        case .vegetarian:
            return uniqueLimited(vegetarianHomeRecipes(), limit: 6)
        case .chickenSalad:
            return uniqueLimited(chickenSaladRecipes(), limit: 6)
        case .tuna:
            return uniqueLimited(tunaRecipes(), limit: 6)
        case .plantBasedBowls:
            return uniqueLimited(plantBasedBowlsRecipes(), limit: 6)
        case .piesAndTarts:
            return uniqueLimited(piesAndTartsRecipes(), limit: 6)
        case .mexican:
            return uniqueLimited(recipes(forSubcategoryID: "world-cuisine-mexican"), limit: 6)
        case .korean:
            return uniqueLimited(recipes(forSubcategoryID: "world-cuisine-korean"), limit: 6)
        case .breakfastBakes:
            return uniqueLimited(recipes(forSubcategoryID: "bakery-breakfast-bakes"), limit: 6)
        case .cookies:
            return uniqueLimited(recipes(forSubcategoryID: "bakery-cookies"), limit: 6)
        case .highProtein:
            return uniqueLimited(
                recipes(forSubcategoryID: "high-protein-high-protein-breakfast") + recipes(forCategoryGroupID: "high-protein"),
                limit: 6
            )
        }
    }

    func explorerLaunchRecipes(for context: ExploreLaunchContext) -> [Recipe] {
        switch context {
        case .featured:
            return uniqueLimited(featuredRecipes, limit: 6)
        case .community:
            return uniqueLimited(communityRecipes, limit: 6)
        case .worldCuisine:
            return uniqueLimited(recipes(forCategoryGroupID: "world-cuisine"), limit: 6)
        case .topPicks:
            return uniqueLimited(topPickCarouselRecipes(), limit: 6)
        case .aiRecommended:
            return uniqueLimited(aiRecommendedRecipes, limit: 6)
        case .highProtein:
            return uniqueLimited(recipes(forCategoryGroupID: "high-protein"), limit: 6)
        case .snacks:
            return uniqueLimited(recipes(forCategoryGroupID: "snacks"), limit: 6)
        case .breakfast:
            return uniqueLimited(recipes(forCategoryGroupID: "breakfast"), limit: 6)
        case .eggBased:
            return uniqueLimited(recipes(forSubcategoryID: "breakfast-egg-based"), limit: 6)
        case .salmon:
            return uniqueLimited(salmonRecipes(), limit: 6)
        }
    }

    func ingredients(for recipeID: String) -> [String] {
        recipe(id: recipeID)?.ingredientLines ?? recipe(id: recipeID)?.ingredients ?? []
    }

    func structuredIngredients(for recipeID: String) -> [RecipeIngredient] {
        recipe(id: recipeID)?.structuredIngredients ?? []
    }

    func instructions(for recipeID: String) -> [String] {
        recipe(id: recipeID)?.instructions ?? []
    }

    func recipes(matching searchText: String) -> [Recipe] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return allRecipes
        }

        return allRecipes.filter { recipe in
            recipe.title.localizedCaseInsensitiveContains(query)
            || recipe.subtitle.localizedCaseInsensitiveContains(query)
            || recipe.subcategoryTitle?.localizedCaseInsensitiveContains(query) == true
            || recipe.tags.contains { $0.localizedCaseInsensitiveContains(query) }
            || recipe.ingredients.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    func recipes(for subcategory: ExploreSubcategory, searchText: String) -> [Recipe] {
        let subcategoryRecipes = recipes(forSubcategory: subcategory)
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return subcategoryRecipes
        }

        return subcategoryRecipes.filter { recipe in
            recipe.title.localizedCaseInsensitiveContains(query)
            || recipe.subtitle.localizedCaseInsensitiveContains(query)
            || recipe.tags.contains { $0.localizedCaseInsensitiveContains(query) }
            || recipe.ingredients.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    private func topPickCarouselRecipes() -> [Recipe] {
        var excludedIDs = Set<String>()
        var picks: [Recipe] = []

        func append(_ recipe: Recipe?) {
            guard let recipe, excludedIDs.insert(recipe.id).inserted else {
                return
            }

            picks.append(recipe)
        }

        append(firstRecipe(matching: isVegetarian))
        append(firstRecipe(matching: isMeatOrSeafood, excluding: Array(excludedIDs)))
        append(firstRecipe(matching: isHighProtein, excluding: Array(excludedIDs)))

        for recipe in topPicksRecipes + featuredRecipes + aiRecommendedRecipes + allRecipes {
            guard excludedIDs.insert(recipe.id).inserted else {
                continue
            }

            picks.append(recipe)
            if picks.count >= 6 {
                break
            }
        }

        return picks
    }

    private func beefRecipes() -> [Recipe] {
        allRecipes.filter { recipe in
            searchableText(for: recipe).contains("beef")
                || recipe.subcategoryTitle?.localizedCaseInsensitiveContains("beef") == true
                || searchableText(for: recipe).contains("steak")
        }
    }

    private func vegetarianHomeRecipes() -> [Recipe] {
        allRecipes.filter { recipe in
            isVegetarian(recipe)
                || searchableText(for: recipe).contains("vegetarian")
                || searchableText(for: recipe).contains("plant based")
                || searchableText(for: recipe).contains("plant-based")
        }
    }

    private func chickenSaladRecipes() -> [Recipe] {
        allRecipes.filter { recipe in
            let text = searchableText(for: recipe)
            return text.contains("chicken") && text.contains("salad")
        }
    }

    private func tunaRecipes() -> [Recipe] {
        allRecipes.filter { recipe in
            searchableText(for: recipe).contains("tuna")
        }
    }

    private func plantBasedBowlsRecipes() -> [Recipe] {
        allRecipes.filter { recipe in
            let text = searchableText(for: recipe)
            return text.contains("bowl")
                && (isVegetarian(recipe) || text.contains("plant"))
        }
    }

    private func piesAndTartsRecipes() -> [Recipe] {
        allRecipes.filter { recipe in
            let text = searchableText(for: recipe)
            return text.contains("pie") || text.contains("tart")
        }
    }

    private func searchableText(for recipe: Recipe) -> String {
        [
            recipe.title,
            recipe.subtitle,
            recipe.description,
            recipe.subcategoryTitle ?? "",
            recipe.sourceHost ?? "",
            recipe.ingredients.joined(separator: " ")
        ]
        .joined(separator: " ")
        .lowercased()
    }

    private func salmonRecipes() -> [Recipe] {
        allRecipes.filter { recipe in
            let searchableText = [
                recipe.title,
                recipe.subtitle,
                recipe.description,
                recipe.subcategoryTitle ?? "",
                recipe.sourceHost ?? ""
            ]
            .joined(separator: " ")
            .lowercased()

            if searchableText.contains("salmon") {
                return true
            }

            if recipe.tags.contains(where: { $0.localizedCaseInsensitiveContains("salmon") }) {
                return true
            }

            return recipe.ingredients.contains(where: { $0.localizedCaseInsensitiveContains("salmon") })
        }
    }

    private func firstRecipe(matching predicate: (Recipe) -> Bool, excluding excludedIDs: [String] = []) -> Recipe? {
        let excluded = Set(excludedIDs)
        return allRecipes.first { recipe in
            !excluded.contains(recipe.id) && predicate(recipe)
        }
    }

    private func isVegetarian(_ recipe: Recipe) -> Bool {
        containsTag(recipe, values: ["vegetarian", "vegan"])
            || recipe.categoryGroupID == "vegetarian"
            || recipe.category == .vegetarian
            || recipe.category == .tofuTempeh
            || recipe.category == .beansLentils
            || recipe.category == .mushrooms
    }

    private func isMeatOrSeafood(_ recipe: Recipe) -> Bool {
        recipe.categoryGroupID == "meat-seafood"
            || recipe.category == .fish
            || recipe.category == .meat
            || recipe.category == .seafood
            || recipe.category == .chicken
            || recipe.category == .grilledChicken
            || recipe.category == .chickenBowls
            || recipe.category == .chickenPasta
    }

    private func isHighProtein(_ recipe: Recipe) -> Bool {
        containsTag(recipe, values: ["highprotein", "high-protein"])
            || recipe.categoryGroupID == "high-protein"
            || recipe.category == .highProtein
            || recipe.category == .proteinBowls
            || recipe.category == .leanMeals
            || recipe.category == .fitnessMeals
    }

    private func containsTag(_ recipe: Recipe, values: Set<String>) -> Bool {
        let normalizedTags = recipe.tags.map {
            $0.lowercased().replacingOccurrences(of: " ", with: "")
        }

        return normalizedTags.contains { values.contains($0) }
    }

    private func uniqueLimited(_ recipes: [Recipe], limit: Int) -> [Recipe] {
        var seenIDs = Set<String>()
        var results: [Recipe] = []

        for recipe in recipes {
            guard seenIDs.insert(recipe.id).inserted else {
                continue
            }

            results.append(recipe)

            if results.count == limit {
                break
            }
        }

        return results
    }

    private func mergedRecipes(_ baseRecipes: [Recipe], _ appendedRecipes: [Recipe]) -> [Recipe] {
        var seenIDs = Set<String>()
        return (baseRecipes + appendedRecipes).filter { seenIDs.insert($0.id).inserted }
    }
}
