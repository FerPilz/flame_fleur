import Foundation

struct UserProfile: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var location: String
    var tagline: String
    var profileImageName: String?
    var cuisineStyle: String
    var favoriteMealsCount: Int
    var memberSince: Date
    var preferences: [ProfilePreference]
    var favoriteCuisines: [FavoriteCuisine]
    var achievements: [ProfileAchievement]

    init(
        id: UUID = UUID(),
        name: String,
        location: String,
        tagline: String,
        profileImageName: String? = nil,
        cuisineStyle: String,
        favoriteMealsCount: Int,
        memberSince: Date,
        preferences: [ProfilePreference],
        favoriteCuisines: [FavoriteCuisine],
        achievements: [ProfileAchievement]
    ) {
        self.id = id
        self.name = name
        self.location = location
        self.tagline = tagline
        self.profileImageName = profileImageName
        self.cuisineStyle = cuisineStyle
        self.favoriteMealsCount = favoriteMealsCount
        self.memberSince = memberSince
        self.preferences = preferences
        self.favoriteCuisines = favoriteCuisines
        self.achievements = achievements
    }
}
