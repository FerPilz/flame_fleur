import Foundation

enum SampleUserProfile {
    static let profile = UserProfile(
        name: "Julia Martinez",
        location: "Zurich, Switzerland",
        tagline: "",
        profileImageName: "salad",
        cuisineStyle: "Mediterranean",
        favoriteMealsCount: 32,
        memberSince: memberSinceDate,
        preferences: [
            ProfilePreference(id: "vegetarian", title: "Vegetarian", systemImage: "leaf.fill"),
            ProfilePreference(id: "quick-easy", title: "Quick & Easy", systemImage: "clock.fill"),
            ProfilePreference(id: "healthy", title: "Healthy", systemImage: "heart.fill"),
            ProfilePreference(id: "family-friendly", title: "Family Friendly", systemImage: "person.3.fill")
        ],
        favoriteCuisines: [
            FavoriteCuisine(id: "mediterranean", title: "Mediterranean", imageName: "ff_subcat_world_cuisine_greek", isSelected: true),
            FavoriteCuisine(id: "asian", title: "Asian", imageName: "ff_subcat_world_cuisine_chinese"),
            FavoriteCuisine(id: "mexican", title: "Mexican", imageName: "world_mexican_charred_corn_tacos"),
            FavoriteCuisine(id: "italian", title: "Italian", imageName: "ff_subcat_world_cuisine_italian", isSelected: true),
            FavoriteCuisine(id: "japanese", title: "Japanese", imageName: "ff_subcat_world_cuisine_japanese"),
            FavoriteCuisine(id: "indian", title: "Indian", imageName: "ff_subcat_world_cuisine_indian"),
            FavoriteCuisine(id: "french", title: "French", imageName: "ff_subcat_world_cuisine_french")
        ],
        achievements: [
            ProfileAchievement(
                id: "streak",
                title: "21 Days in a row",
                value: "21",
                subtitle: "Days in a row",
                systemImage: "flame.fill"
            ),
            ProfileAchievement(
                id: "planned",
                title: "87 Recipes planned",
                value: "87",
                subtitle: "Recipes planned",
                systemImage: "calendar.badge.checkmark"
            ),
            ProfileAchievement(
                id: "swaps",
                title: "12 Healthy swaps",
                value: "12",
                subtitle: "Healthy swaps",
                systemImage: "leaf.fill"
            )
        ]
    )

    private static var memberSinceDate: Date {
        var components = DateComponents()
        components.year = 2024
        components.month = 5
        components.day = 1

        return Calendar.current.date(from: components) ?? Date()
    }
}
