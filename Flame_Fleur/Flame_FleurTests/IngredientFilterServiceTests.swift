import Foundation
import Testing
@testable import Flame_Fleur

struct IngredientFilterServiceTests {
    @Test func noSelectedIngredientsKeepsOtherResults() {
        let recipes = [recipe(id: "one", title: "Lemon Pasta", ingredients: ["garlic"])]

        #expect(IngredientFilterService.matchingRecipes(recipes, selectedIngredients: []).map(\.id) == ["one"])
    }

    @Test func oneIngredientMatchesRecipeIngredient() {
        let recipes = [recipe(id: "one", title: "Pasta", ingredients: ["Garlic, minced"])]

        #expect(IngredientFilterService.matchingRecipes(recipes, selectedIngredients: ["garlic"]).map(\.id) == ["one"])
    }

    @Test func multipleIngredientsUseMatchAllLogic() {
        let complete = recipe(id: "complete", title: "Complete", ingredients: ["chicken", "rice", "broccoli"])
        let incomplete = recipe(id: "incomplete", title: "Incomplete", ingredients: ["chicken", "rice"])

        let result = IngredientFilterService.matchingRecipes(
            [complete, incomplete],
            selectedIngredients: ["chicken", "rice", "broccoli"]
        )

        #expect(result.map(\.id) == ["complete"])
    }

    @Test func matchingIsCaseAndWhitespaceInsensitive() {
        let recipes = [recipe(id: "one", title: "Rice", ingredients: ["  GARLIC  "])]

        #expect(IngredientFilterService.matchingRecipes(recipes, selectedIngredients: [" garlic "]).count == 1)
    }

    @Test func matchingFoldsDiacritics() {
        let recipes = [recipe(id: "one", title: "Cafe", ingredients: ["Crème fraîche"])]

        #expect(IngredientFilterService.matchingRecipes(recipes, selectedIngredients: ["creme fraiche"]).count == 1)
    }

    @Test func quantityPrefixedIngredientsMatchCanonicalName() {
        let recipes = [recipe(id: "one", title: "Rice Bowl", ingredients: ["1 cup cooked rice"])]

        #expect(IngredientFilterService.matchingRecipes(recipes, selectedIngredients: ["rice"]).count == 1)
    }

    @Test func removingAnIngredientPreservesOrIncreasesResults() {
        let recipes = [
            recipe(id: "one", title: "Chicken Rice", ingredients: ["chicken", "rice"]),
            recipe(id: "two", title: "Chicken", ingredients: ["chicken"])
        ]

        let before = IngredientFilterService.matchingRecipes(recipes, selectedIngredients: ["chicken", "rice"])
        let after = IngredientFilterService.matchingRecipes(recipes, selectedIngredients: ["chicken"])

        #expect(after.count >= before.count)
    }

    @Test func recipeSearchAndIngredientFiltersCombine() {
        let recipes = [
            recipe(id: "lemon-chicken", title: "Lemon Chicken", ingredients: ["chicken"]),
            recipe(id: "garlic-chicken", title: "Garlic Chicken", ingredients: ["chicken"]),
            recipe(id: "lemon-pasta", title: "Lemon Pasta", ingredients: ["pasta"])
        ]
        let textMatches = recipes.filter { $0.title.localizedCaseInsensitiveContains("lemon") }

        let result = IngredientFilterService.matchingRecipes(textMatches, selectedIngredients: ["chicken"])

        #expect(result.map(\.id) == ["lemon-chicken"])
    }

    @Test func clearingIngredientsRestoresRecipeSearchResults() {
        let textMatches = [
            recipe(id: "one", title: "Lemon Chicken", ingredients: ["chicken"]),
            recipe(id: "two", title: "Lemon Pasta", ingredients: ["pasta"])
        ]

        #expect(IngredientFilterService.matchingRecipes(textMatches, selectedIngredients: []).map(\.id) == ["one", "two"])
    }

    @Test func duplicateIngredientSelectionIsImpossible() {
        var selection: Set<String> = []
        selection.insert(IngredientFilterService.normalize(" Garlic "))
        selection.insert(IngredientFilterService.normalize("garlic"))

        #expect(selection.count == 1)
    }

    @Test func noMatchSelectionReturnsNoRecipes() {
        let recipes = [recipe(id: "one", title: "Pasta", ingredients: ["pasta"])]

        #expect(IngredientFilterService.matchingRecipes(recipes, selectedIngredients: ["ham"]).isEmpty)
    }

    @Test func matchingUsesWholeIngredientTokens() {
        let recipes = [recipe(id: "one", title: "Soup", ingredients: ["shamrock greens"])]

        #expect(IngredientFilterService.matchingRecipes(recipes, selectedIngredients: ["ham"]).isEmpty)
    }

    @Test func matchingSortsByFewestAdditionalIngredients() {
        let longer = recipe(id: "longer", title: "Loaded Pasta", ingredients: ["garlic", "pasta", "tomato"])
        let shorter = recipe(id: "shorter", title: "Garlic Pasta", ingredients: ["garlic", "pasta"])

        let result = IngredientFilterService.matchingRecipes(
            [longer, shorter],
            selectedIngredients: ["garlic"]
        )

        #expect(result.map(\.id) == ["shorter", "longer"])
    }

    @Test func indexedCatalogAliasesResolveChickenGarlicAndRice() {
        let chicken = catalogItem(id: "ingredient_chicken_breast", name: "Chicken Breast")
        let garlic = catalogItem(id: "ingredient_garlic", name: "Garlic")
        let rice = catalogItem(id: "ingredient_rice", name: "Rice")
        let recipe = recipe(
            id: "chicken-rice",
            title: "Chicken Rice",
            ingredients: ["Boneless skinless chicken breast", "2 cloves garlic, minced", "1 cup cooked jasmine rice"]
        )
        let index = IngredientFilterService.RecipeIngredientIndex(
            recipes: [recipe],
            catalog: [chicken, garlic, rice]
        )

        #expect(index.ingredientIDs(for: recipe.id).isSuperset(of: Set([chicken.id, garlic.id, rice.id, IngredientPickerCatalog.chickenID])))
        #expect(
            IngredientFilterService.matchingRecipes(
                [recipe],
                selectedIngredientIDs: [chicken.id, garlic.id, rice.id],
                index: index
            ).map(\.id) == [recipe.id]
        )
    }

    @Test func indexedMatchAllRequiresEverySelectedCatalogID() {
        let chicken = catalogItem(id: "ingredient_chicken_breast", name: "Chicken Breast")
        let rice = catalogItem(id: "ingredient_rice", name: "Rice")
        let chickenOnly = recipe(id: "chicken", title: "Chicken", ingredients: ["chicken breast"])
        let index = IngredientFilterService.RecipeIngredientIndex(recipes: [chickenOnly], catalog: [chicken, rice])

        #expect(
            IngredientFilterService.matchingRecipes(
                [chickenOnly],
                selectedIngredientIDs: [chicken.id, rice.id],
                index: index
            ).isEmpty
        )
    }

    @Test func indexedMatchingHasNoLiveResultsWithoutSelections() {
        let garlic = catalogItem(id: "ingredient_garlic", name: "Garlic")
        let recipe = recipe(id: "garlic", title: "Garlic Pasta", ingredients: ["garlic"])
        let index = IngredientFilterService.RecipeIngredientIndex(recipes: [recipe], catalog: [garlic])

        #expect(
            IngredientFilterService.matchingRecipes(
                [recipe],
                selectedIngredientIDs: [],
                index: index
            ).isEmpty
        )
    }

    @Test func indexRebuildsFromEmptyToPopulatedRecipes() {
        let chicken = catalogItem(id: "ingredient_chicken_breast", name: "Chicken Breast")
        let emptyIndex = IngredientFilterService.RecipeIngredientIndex(recipes: [], catalog: [chicken])
        let recipe = recipe(id: "chicken", title: "Chicken", ingredients: ["boneless skinless chicken breasts"])
        let populatedIndex = IngredientFilterService.RecipeIngredientIndex(recipes: [recipe], catalog: [chicken])

        #expect(emptyIndex.ingredientIDsByRecipeID.isEmpty)
        #expect(populatedIndex.ingredientIDs(for: recipe.id) == Set([chicken.id]))
    }

    @Test func matchExplanationReportsMissingCanonicalIDs() {
        let chicken = catalogItem(id: "ingredient_chicken_breast", name: "Chicken Breast")
        let garlic = catalogItem(id: "ingredient_garlic", name: "Garlic")
        let recipe = recipe(id: "chicken", title: "Chicken", ingredients: ["chicken breast"])
        let index = IngredientFilterService.RecipeIngredientIndex(recipes: [recipe], catalog: [chicken, garlic])

        let explanation = IngredientFilterService.explainMatch(
            recipe: recipe,
            selectedIngredientIDs: [chicken.id, garlic.id],
            index: index
        )

        #expect(explanation.resolvedCanonicalIDs == Set([chicken.id]))
        #expect(explanation.missingCanonicalIDs == Set([garlic.id]))
        #expect(!explanation.matches)
    }

    @Test func zeroCoverageIngredientIsHidden() {
        let garlic = catalogItem(id: "garlic", name: "Garlic")
        let unavailable = catalogItem(id: "unavailable", name: "Unicorn Pepper")
        let recipe = recipe(id: "garlic-recipe", title: "Garlic Pasta", ingredients: ["garlic"])
        let facet = ingredientFacet(recipes: [recipe], catalog: [garlic, unavailable])

        #expect(facet.availableIngredientIDs(catalog: [garlic, unavailable], selectedIDs: []).contains(garlic.id))
        #expect(!facet.availableIngredientIDs(catalog: [garlic, unavailable], selectedIDs: []).contains(unavailable.id))
    }

    @Test func garlicAppearsWhenRecipesContainGarlic() {
        let garlic = catalogItem(id: "garlic", name: "Garlic")
        let recipe = recipe(id: "garlic-recipe", title: "Garlic Pasta", ingredients: ["garlic"])
        let facet = ingredientFacet(recipes: [recipe], catalog: [garlic])

        #expect(facet.availableIngredientIDs(catalog: [garlic], selectedIDs: []) == Set([garlic.id]))
    }

    @Test func incompatibleIngredientIsHiddenAfterSelectingGarlic() {
        let garlic = catalogItem(id: "garlic", name: "Garlic")
        let lemon = catalogItem(id: "lemon", name: "Lemon")
        let recipes = [
            recipe(id: "garlic-recipe", title: "Garlic Pasta", ingredients: ["garlic"]),
            recipe(id: "lemon-recipe", title: "Lemon Pasta", ingredients: ["lemon"])
        ]
        let facet = ingredientFacet(recipes: recipes, catalog: [garlic, lemon])

        #expect(!facet.availableIngredientIDs(catalog: [garlic, lemon], selectedIDs: [garlic.id]).contains(lemon.id))
    }

    @Test func compatibleIngredientRemainsVisibleAfterSelectingGarlic() {
        let garlic = catalogItem(id: "garlic", name: "Garlic")
        let lemon = catalogItem(id: "lemon", name: "Lemon")
        let recipe = recipe(id: "garlic-lemon", title: "Garlic Lemon Pasta", ingredients: ["garlic", "lemon"])
        let facet = ingredientFacet(recipes: [recipe], catalog: [garlic, lemon])

        #expect(facet.availableIngredientIDs(catalog: [garlic, lemon], selectedIDs: [garlic.id]).contains(lemon.id))
        #expect(facet.projectedMatchCount(adding: lemon.id, to: [garlic.id]) == 1)
    }

    @Test func selectedIngredientsRemainAvailableEvenWhenTheirCombinationHasNoResults() {
        let garlic = catalogItem(id: "garlic", name: "Garlic")
        let lemon = catalogItem(id: "lemon", name: "Lemon")
        let recipes = [
            recipe(id: "garlic-recipe", title: "Garlic Pasta", ingredients: ["garlic"]),
            recipe(id: "lemon-recipe", title: "Lemon Pasta", ingredients: ["lemon"])
        ]
        let facet = ingredientFacet(recipes: recipes, catalog: [garlic, lemon])

        #expect(facet.availableIngredientIDs(catalog: [garlic, lemon], selectedIDs: [garlic.id, lemon.id]) == Set([garlic.id, lemon.id]))
    }

    @Test func indexedMatchAllUsesSetIntersection() {
        let garlic = catalogItem(id: "garlic", name: "Garlic")
        let lemon = catalogItem(id: "lemon", name: "Lemon")
        let recipes = [
            recipe(id: "both", title: "Both", ingredients: ["garlic", "lemon"]),
            recipe(id: "garlic", title: "Garlic", ingredients: ["garlic"]),
            recipe(id: "lemon", title: "Lemon", ingredients: ["lemon"])
        ]
        let facet = ingredientFacet(recipes: recipes, catalog: [garlic, lemon])

        #expect(facet.matchingRecipeIDs(for: [garlic.id, lemon.id]) == Set(["both"]))
    }

    @Test func ingredientSearchOnlySearchesEligibleIngredients() {
        let garlic = catalogItem(id: "garlic", name: "Garlic")
        let unavailable = catalogItem(id: "garlic-salt", name: "Garlic Salt")
        let recipe = recipe(id: "garlic-recipe", title: "Garlic Pasta", ingredients: ["garlic"])
        let facet = ingredientFacet(recipes: [recipe], catalog: [garlic, unavailable])
        let eligible = [garlic, unavailable].filter {
            facet.availableIngredientIDs(catalog: [garlic, unavailable], selectedIDs: []).contains($0.id)
        }

        #expect(eligible.filter { $0.displayName.localizedCaseInsensitiveContains("garlic") }.map(\.id) == [garlic.id])
    }

    @Test func categoriesWithNoEligibleIngredientsHaveNoPickerItems() {
        let garlic = catalogItem(id: "garlic", name: "Garlic")
        let tofu = ShoppingIngredientCatalogItem(id: "tofu", displayName: "Tofu", normalizedName: "tofu", category: "Protein", defaultUnit: "", estimatedPrice: 0, imageName: nil)
        let recipe = recipe(id: "garlic-recipe", title: "Garlic Pasta", ingredients: ["garlic"])
        let facet = ingredientFacet(recipes: [recipe], catalog: [garlic, tofu])
        let eligibleIDs = facet.availableIngredientIDs(catalog: [garlic, tofu], selectedIDs: [])

        #expect(!eligibleIDs.contains(tofu.id))
    }

    @Test func addingUserRecipeMakesPreviouslyUnavailableIngredientEligible() {
        let garlic = catalogItem(id: "garlic", name: "Garlic")
        let tofu = catalogItem(id: "tofu", name: "Tofu")
        let seedRecipe = recipe(id: "garlic-recipe", title: "Garlic Pasta", ingredients: ["garlic"])
        let userRecipe = recipe(id: "tofu-recipe", title: "Tofu Bowl", ingredients: ["tofu"])

        let before = ingredientFacet(recipes: [seedRecipe], catalog: [garlic, tofu])
        let after = ingredientFacet(recipes: [seedRecipe, userRecipe], catalog: [garlic, tofu])

        #expect(!before.availableIngredientIDs(catalog: [garlic, tofu], selectedIDs: []).contains(tofu.id))
        #expect(after.availableIngredientIDs(catalog: [garlic, tofu], selectedIDs: []).contains(tofu.id))
    }

    @Test func liveCountAndShowResultsUseTheSameMatchingRecipes() {
        let garlic = catalogItem(id: "garlic", name: "Garlic")
        let recipe = recipe(id: "garlic-recipe", title: "Garlic Pasta", ingredients: ["garlic"])
        let index = IngredientFilterService.RecipeIngredientIndex(recipes: [recipe], catalog: [garlic])
        let matching = IngredientFilterService.matchingRecipes([recipe], selectedIngredientIDs: [garlic.id], index: index)
        let facet = IngredientFilterService.IngredientFacet(recipes: [recipe], index: index)

        #expect(Set(matching.map(\.id)) == facet.matchingRecipeIDs(for: [garlic.id]))
    }

    @Test func chickenBreastAndThighsIndexAsCanonicalChicken() {
        let recipes = [
            recipe(id: "breast", title: "Breast", ingredients: ["boneless skinless chicken breasts"]),
            recipe(id: "thigh", title: "Thigh", ingredients: ["chicken thighs"])
        ]
        let index = IngredientFilterService.RecipeIngredientIndex(recipes: recipes, catalog: [])

        #expect(index.recipeIDsByIngredientID[IngredientPickerCatalog.chickenID] == Set(["breast", "thigh"]))
    }

    @Test func beefAndLambVariantsIndexAsTheirCanonicalProteins() {
        let recipes = [
            recipe(id: "beef", title: "Beef", ingredients: ["1 lb ground beef"]),
            recipe(id: "lamb", title: "Lamb", ingredients: ["lamb chops"])
        ]
        let index = IngredientFilterService.RecipeIngredientIndex(recipes: recipes, catalog: [])

        #expect(index.ingredientIDs(for: "beef").contains(IngredientPickerCatalog.beefID))
        #expect(index.ingredientIDs(for: "lamb").contains(IngredientPickerCatalog.lambID))
    }

    @Test func salmonIndexesAsCanonicalFish() {
        let recipe = recipe(id: "salmon", title: "Salmon", ingredients: ["salmon fillet"])
        let index = IngredientFilterService.RecipeIngredientIndex(recipes: [recipe], catalog: [])

        #expect(index.ingredientIDs(for: recipe.id).contains(IngredientPickerCatalog.fishID))
    }

    @Test func canonicalChickenIsShownInsteadOfDetailedChickenCatalogItems() {
        let chickenBreast = catalogItem(id: "ingredient_chicken_breast", name: "Chicken Breast")
        let chickenThighs = catalogItem(id: "ingredient_chicken_thighs", name: "Chicken Thighs")
        let items = IngredientPickerCatalog.items(from: [chickenBreast, chickenThighs])

        #expect(items.contains(where: { $0.id == IngredientPickerCatalog.chickenID && $0.displayName == "Chicken" }))
        #expect(!items.contains(where: { $0.id == chickenBreast.id || $0.id == chickenThighs.id }))
    }

    @Test func canonicalChickenCoverageAndMatchAllUseCombinedVariants() {
        let garlic = catalogItem(id: "garlic", name: "Garlic")
        let chicken = ShoppingIngredientCatalogItem(id: IngredientPickerCatalog.chickenID, displayName: "Chicken", normalizedName: "chicken", category: "Protein", defaultUnit: "", estimatedPrice: 0, imageName: nil)
        let recipes = [
            recipe(id: "breast-garlic", title: "Chicken", ingredients: ["chicken breast", "garlic"]),
            recipe(id: "thigh", title: "Chicken", ingredients: ["chicken thighs"])
        ]
        let index = IngredientFilterService.RecipeIngredientIndex(recipes: recipes, catalog: [garlic])
        let facet = IngredientFilterService.IngredientFacet(recipes: recipes, index: index)

        #expect(index.recipeIDsByIngredientID[IngredientPickerCatalog.chickenID] == Set(["breast-garlic", "thigh"]))
        #expect(facet.availableIngredientIDs(catalog: [chicken, garlic], selectedIDs: []).contains(chicken.id))
        #expect(facet.matchingRecipeIDs(for: [chicken.id, garlic.id]) == Set(["breast-garlic"]))
    }

    @Test func proteinFacetStillHidesCombinationsWithoutMatches() {
        let chicken = ShoppingIngredientCatalogItem(id: IngredientPickerCatalog.chickenID, displayName: "Chicken", normalizedName: "chicken", category: "Protein", defaultUnit: "", estimatedPrice: 0, imageName: nil)
        let lamb = ShoppingIngredientCatalogItem(id: IngredientPickerCatalog.lambID, displayName: "Lamb", normalizedName: "lamb", category: "Protein", defaultUnit: "", estimatedPrice: 0, imageName: nil)
        let recipes = [
            recipe(id: "chicken", title: "Chicken", ingredients: ["chicken breast"]),
            recipe(id: "lamb", title: "Lamb", ingredients: ["lamb chops"])
        ]
        let index = IngredientFilterService.RecipeIngredientIndex(recipes: recipes, catalog: [])
        let facet = IngredientFilterService.IngredientFacet(recipes: recipes, index: index)

        #expect(!facet.availableIngredientIDs(catalog: [chicken, lamb], selectedIDs: [chicken.id]).contains(lamb.id))
    }

    @Test func loadedSeedProvidesCoverageForEveryCanonicalProtein() {
        let recipes = RecipeRepository().allRecipes
        let index = IngredientFilterService.RecipeIngredientIndex(recipes: recipes)

        for proteinID in [
            IngredientPickerCatalog.chickenID,
            IngredientPickerCatalog.beefID,
            IngredientPickerCatalog.porkID,
            IngredientPickerCatalog.lambID,
            IngredientPickerCatalog.fishID,
            IngredientPickerCatalog.seafoodID,
            IngredientPickerCatalog.eggsID,
            IngredientPickerCatalog.tofuID,
            IngredientPickerCatalog.beansID
        ] {
            #expect(!(index.recipeIDsByIngredientID[proteinID] ?? []).isEmpty)
        }
    }

    @Test func explorerUsesExactlyTheSixApprovedFiltersAndAssets() {
        #expect(ExploreFilter.allCases.map(\.rawValue) == ["protein", "vegetarian", "budget", "quickMeals", "chicken", "favorites"])
        #expect(ExploreFilter.protein.assetName == "icon_high_protein")
        #expect(ExploreFilter.vegetarian.assetName == "icon_vegetarian")
        #expect(ExploreFilter.budget.assetName == "icon_budget")
        #expect(ExploreFilter.quickMeals.assetName == "icon_quick_meals")
        #expect(ExploreFilter.chicken.assetName == "icon_chicken_salad")
        #expect(ExploreFilter.favorites.assetName == "icon_featured")
    }

    @Test func explorerChickenAndFavoritesFiltersUseTheirCorrectPredicates() {
        let chicken = recipe(id: "chicken", title: "Chicken", ingredients: ["chicken thighs"], category: .chicken)
        let favorite = recipe(id: "favorite", title: "Favorite", ingredients: ["pasta"])

        #expect(ExploreFilter.chicken.matches(chicken, favoriteRecipeIDs: []))
        #expect(ExploreFilter.favorites.matches(favorite, favoriteRecipeIDs: Set([favorite.id])))
        #expect(!ExploreFilter.favorites.matches(chicken, favoriteRecipeIDs: []))
    }

    private func ingredientFacet(
        recipes: [Recipe],
        catalog: [ShoppingIngredientCatalogItem]
    ) -> IngredientFilterService.IngredientFacet {
        let index = IngredientFilterService.RecipeIngredientIndex(recipes: recipes, catalog: catalog)
        return IngredientFilterService.IngredientFacet(recipes: recipes, index: index)
    }

    private func recipe(
        id: String,
        title: String,
        ingredients: [String],
        category: RecipeCategory = .vegetarian
    ) -> Recipe {
        Recipe(
            id: id,
            title: title,
            subtitle: title,
            category: category,
            sectionTags: [],
            cookingTimeMinutes: 20,
            calories: 400,
            servings: 2,
            difficulty: .easy,
            ingredients: ingredients
        )
    }

    private func catalogItem(id: String, name: String) -> ShoppingIngredientCatalogItem {
        ShoppingIngredientCatalogItem(
            id: id,
            displayName: name,
            normalizedName: IngredientFilterService.normalize(name),
            category: "Pantry",
            defaultUnit: "",
            estimatedPrice: 0,
            imageName: nil
        )
    }
}
