import Combine
import Foundation

final class FavoritesStore: ObservableObject {
    static let shared = FavoritesStore()

    @Published private(set) var favoriteRecipeIDs: [Recipe.ID]
    @Published private(set) var favoriteDates: [Recipe.ID: Date]

    init(seedRecipeIDs: [Recipe.ID] = []) {
        let uniqueIDs = Array(dictKeysPreservingOrder: seedRecipeIDs)
        let now = Date()

        self.favoriteRecipeIDs = uniqueIDs
        self.favoriteDates = Dictionary(
            uniqueKeysWithValues: uniqueIDs.enumerated().map { index, id in
                (id, now.addingTimeInterval(TimeInterval(-index * 3_600)))
            }
        )
    }

    func isFavorite(_ recipeID: Recipe.ID) -> Bool {
        favoriteRecipeIDs.contains(recipeID)
    }

    func favoriteDate(for recipeID: Recipe.ID) -> Date? {
        favoriteDates[recipeID]
    }

    func toggleFavorite(_ recipeID: Recipe.ID) {
        let usageTrackingStore = UsageTrackingStore.shared
        let recipe = RecipeRepository.shared.recipe(id: recipeID)

        if let index = favoriteRecipeIDs.firstIndex(of: recipeID) {
            favoriteRecipeIDs.remove(at: index)
            favoriteDates.removeValue(forKey: recipeID)
            usageTrackingStore.record(type: .recipeUnSaved, recipe: recipe, recipeID: recipeID)
        } else {
            favoriteRecipeIDs.insert(recipeID, at: 0)
            favoriteDates[recipeID] = Date()
            usageTrackingStore.record(type: .recipeSaved, recipe: recipe, recipeID: recipeID)
        }
    }
}

private extension Array where Element: Hashable {
    init(dictKeysPreservingOrder values: [Element]) {
        var seenValues = Set<Element>()
        self = values.filter { seenValues.insert($0).inserted }
    }
}
