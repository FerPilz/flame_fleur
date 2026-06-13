import Foundation

struct ProfilePreference: Identifiable, Hashable, Codable {
    let id: String
    var title: String
    var systemImage: String
    var isSelected: Bool

    init(
        id: String,
        title: String,
        systemImage: String,
        isSelected: Bool = true
    ) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.isSelected = isSelected
    }
}
