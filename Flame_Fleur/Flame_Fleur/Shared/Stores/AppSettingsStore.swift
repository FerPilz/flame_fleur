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
}
