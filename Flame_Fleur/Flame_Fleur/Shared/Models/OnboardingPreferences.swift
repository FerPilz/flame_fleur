import Foundation

struct OnboardingPreferences: Codable, Equatable {
    var hasCompletedOnboarding: Bool
    var selectedCuisines: [String]
    var selectedGoals: [String]
    var completedAt: Date?

    static let empty = OnboardingPreferences(
        hasCompletedOnboarding: false,
        selectedCuisines: [],
        selectedGoals: [],
        completedAt: nil
    )
}
