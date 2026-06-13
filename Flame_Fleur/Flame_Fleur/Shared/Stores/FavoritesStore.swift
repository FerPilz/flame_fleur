import Combine
import Foundation

final class FavoritesStore: ObservableObject {
    static let shared = FavoritesStore(seedRecipeIDs: Array(SampleRecipes.all.prefix(10).map(\.id)))

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
        if let index = favoriteRecipeIDs.firstIndex(of: recipeID) {
            favoriteRecipeIDs.remove(at: index)
            favoriteDates.removeValue(forKey: recipeID)
        } else {
            favoriteRecipeIDs.insert(recipeID, at: 0)
            favoriteDates[recipeID] = Date()
        }
    }
}

private extension Array where Element: Hashable {
    init(dictKeysPreservingOrder values: [Element]) {
        var seenValues = Set<Element>()
        self = values.filter { seenValues.insert($0).inserted }
    }
}
