import Foundation

struct FavoriteCuisine: Identifiable, Hashable, Codable {
    let id: String
    var title: String
    var imageName: String?
    var isSelected: Bool

    init(
        id: String,
        title: String,
        imageName: String? = nil,
        isSelected: Bool = false
    ) {
        self.id = id
        self.title = title
        self.imageName = imageName
        self.isSelected = isSelected
    }
}
