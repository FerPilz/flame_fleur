import Combine
import Foundation

final class AppSettingsStore: ObservableObject {
    static let shared = AppSettingsStore(settings: SampleAppSettings.settings)

    @Published private(set) var settings: AppSettings

    init(settings: AppSettings = SampleAppSettings.settings) {
        self.settings = settings
    }

    var dietaryPreferenceSummary: String {
        switch settings.dietaryPreferences.count {
        case 0:
            return "None"
        case 1:
            return settings.dietaryPreferences[0]
        default:
            return "\(settings.dietaryPreferences.count) selected"
        }
    }

    var defaultServingsSummary: String {
        settings.defaultServings == "1" ? "1 serving" : "\(settings.defaultServings) servings"
    }

    func setUnits(_ units: MeasurementSystem) {
        settings.units = units
    }

    func setCuisineStyle(_ cuisineStyle: String) {
        settings.cuisineStyle = cuisineStyle
    }

    func setDietaryPreferences(_ preferences: [String]) {
        settings.dietaryPreferences = preferences
    }

    func setDefaultServings(_ servings: String) {
        settings.defaultServings = servings
    }

    func setProfilePrivate(_ isPrivate: Bool) {
        settings.isProfilePrivate = isPrivate
    }

    func setActivityVisible(_ isVisible: Bool) {
        settings.isActivityVisible = isVisible
    }

    func setLocation(_ location: String) {
        settings.location = location
    }

    func setNotificationsEnabled(_ isEnabled: Bool) {
        settings.notificationsEnabled = isEnabled
    }

    func setLanguage(_ language: String) {
        settings.language = language
    }

    func applyOnboardingSelections(cuisines: [String], goals: [String]) {
        if let primaryCuisine = cuisines.first {
            settings.cuisineStyle = primaryCuisine
        }

        let mappedDietaryPreferences = Self.mappedDietaryPreferences(from: cuisines + goals)
        if !mappedDietaryPreferences.isEmpty {
            settings.dietaryPreferences = mappedDietaryPreferences
        }
    }

    private static func mappedDietaryPreferences(from values: [String]) -> [String] {
        let mappings: [(needle: String, preference: String)] = [
            ("vegetarian", "Vegetarian"),
            ("vegan", "Vegan"),
            ("low carb", "Low-carb"),
            ("low-carb", "Low-carb"),
            ("high protein", "High-protein"),
            ("high-protein", "High-protein"),
            ("family meals", "Family-friendly"),
            ("quick meals", "Quick & Easy")
        ]

        var results: [String] = []
        var seen = Set<String>()

        for value in values {
            let normalized = value.lowercased()

            for mapping in mappings where normalized.contains(mapping.needle) {
                guard seen.insert(mapping.preference).inserted else {
                    continue
                }
                results.append(mapping.preference)
            }
        }

        return results
    }
}
