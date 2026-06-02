import Foundation

struct ExploreCategoryGroup: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let subcategories: [ExploreSubcategory]
}
