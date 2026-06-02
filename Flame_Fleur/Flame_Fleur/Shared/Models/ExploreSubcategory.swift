import Foundation

struct ExploreSubcategory: Identifiable, Hashable {
    let id: String
    let title: String
    let parentGroupID: String
    let imageName: String?
    let category: RecipeCategory?
}
