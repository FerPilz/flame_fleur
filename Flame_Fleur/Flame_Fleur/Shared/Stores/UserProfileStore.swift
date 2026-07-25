import Combine
import Foundation

final class UserProfileStore: ObservableObject {
    static let shared = UserProfileStore(profile: SampleUserProfile.profile)

    @Published private(set) var profile: UserProfile

    init(profile: UserProfile = SampleUserProfile.profile) {
        self.profile = profile
    }

    func togglePreference(id: ProfilePreference.ID) {
        guard let index = profile.preferences.firstIndex(where: { $0.id == id }) else { return }
        profile.preferences[index].isSelected.toggle()
    }

    func toggleFavoriteCuisine(id: FavoriteCuisine.ID) {
        guard let index = profile.favoriteCuisines.firstIndex(where: { $0.id == id }) else { return }
        profile.favoriteCuisines[index].isSelected.toggle()
    }

    func applyOnboardingSelections(cuisines: [String], goals: [String]) {
        if let primaryCuisine = cuisines.first {
            profile.cuisineStyle = primaryCuisine
        }

        if !cuisines.isEmpty {
            let selectedCuisineIDs = Set(cuisines.map(Self.normalizedID))
            profile.favoriteCuisines = profile.favoriteCuisines.map { cuisine in
                var updatedCuisine = cuisine
                updatedCuisine.isSelected = selectedCuisineIDs.contains(Self.normalizedID(cuisine.title))
                    || selectedCuisineIDs.contains(Self.normalizedID(cuisine.id))
                return updatedCuisine
            }
        }

        if !goals.isEmpty {
            profile.preferences = Self.goalPreferences(selectedGoals: goals)
        }
    }

    private static func normalizedID(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: "&", with: "and")
            .replacingOccurrences(of: " ", with: "-")
    }

    private static func goalPreferences(selectedGoals: [String]) -> [ProfilePreference] {
        let selectedIDs = Set(selectedGoals.map(normalizedID))

        let options: [(id: String, title: String, systemImage: String)] = [
            ("quick-meals", "Quick meals", "timer"),
            ("high-protein", "High protein", "bolt.heart.fill"),
            ("budget-friendly", "Budget friendly", "wallet.pass.fill"),
            ("healthy-balance", "Healthy balance", "leaf.fill"),
            ("family-meals", "Family meals", "person.3.fill"),
            ("vegetarian", "Vegetarian", "leaf.circle.fill"),
            ("low-carb", "Low carb", "chart.pie.fill"),
            ("meal-prep", "Meal prep", "takeoutbag.and.cup.and.straw.fill")
        ]

        return options.map { option in
            ProfilePreference(
                id: option.id,
                title: option.title,
                systemImage: option.systemImage,
                isSelected: selectedIDs.contains(option.id)
            )
        }
    }
}
