import Foundation

struct ProfileAchievement: Identifiable, Hashable, Codable {
    let id: String
    var title: String
    var value: String
    var subtitle: String
    var systemImage: String

    init(
        id: String,
        title: String,
        value: String,
        subtitle: String,
        systemImage: String
    ) {
        self.id = id
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.systemImage = systemImage
    }
}
