//
//  Flame_FleurTests.swift
//  Flame_FleurTests
//
//  Created by Fernando Pilz on 5/30/26.
//

import Testing
@testable import Flame_Fleur

struct Flame_FleurTests {

    @Test func legacySeedRemainsThePrimaryBundledSource() {
        #expect(RecipeSeedLoader.primarySeedResourceName == "recipes.seed")
    }

    @Test func legacyBreakfastBakeKeepsItsRecipeLevelImageName() {
        let recipes = RecipeRepository.shared.allRecipes
        let recipe = recipes.first { $0.id == "recipe-seed-bakery-breakfast-bakes-3" }

        #expect(recipe?.title == "Cinnamon French Toast Bake")
        #expect(recipe?.imageName == "bakery_breakfast_bakes_cinnamon_french_toast_bake")
        #expect(recipe?.imageName != "dessert")
    }

    @Test func legacyItalianRecipeKeepsItsAssetCatalogImageName() {
        let recipe = RecipeRepository.shared.allRecipes.first {
            $0.id == "recipe-seed-world-cuisine-italian-1"
        }

        #expect(recipe?.imageName == "ff_recipe_recipe_seed_world_cuisine_italian_1")
    }

    @Test func legacySeedRecipesHaveCompleteImageNamesAndCookflowStillLoads() {
        let recipes = RecipeRepository.shared.allRecipes
        let legacyRecipes = recipes.filter { $0.id.hasPrefix("recipe-seed-") }

        #expect(legacyRecipes.count == 342)
        #expect(legacyRecipes.allSatisfy { !$0.imageName.isEmpty })
        #expect(recipes.contains { $0.id.hasPrefix("cookflow-") })
    }

}
