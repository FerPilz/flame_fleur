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
}
