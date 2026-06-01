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

    func recipes(for sectionTag: RecipeSectionTag) -> [Recipe] {
        allRecipes.filter { $0.sectionTags.contains(sectionTag) }
    }
}
