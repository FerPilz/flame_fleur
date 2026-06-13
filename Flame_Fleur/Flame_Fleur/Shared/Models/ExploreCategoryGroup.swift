import Foundation

struct ExploreCategoryGroup: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let imageName: String?
    let subcategories: [ExploreSubcategory]

    init(
        id: String,
        title: String,
        subtitle: String,
        imageName: String? = nil,
        subcategories: [ExploreSubcategory]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
        self.subcategories = subcategories
    }
}
