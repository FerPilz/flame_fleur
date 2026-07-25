import Foundation

enum ExploreCategoryBubbleDisplayMode: Hashable {
    case subcategories
    case recipePreviews(sourceSubcategoryID: String)
}

struct ExploreCategoryGroup: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let imageName: String?
    let bubbleDisplayMode: ExploreCategoryBubbleDisplayMode
    let subcategories: [ExploreSubcategory]

    init(
        id: String,
        title: String,
        subtitle: String,
        imageName: String? = nil,
        bubbleDisplayMode: ExploreCategoryBubbleDisplayMode = .subcategories,
        subcategories: [ExploreSubcategory]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
        self.bubbleDisplayMode = bubbleDisplayMode
        self.subcategories = subcategories
    }
}
