import Foundation

struct RecipeRepository {
    static let shared = RecipeRepository()

    let allRecipes: [Recipe]

    init(allRecipes: [Recipe] = SampleRecipes.all) {
        self.allRecipes = allRecipes
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
}
