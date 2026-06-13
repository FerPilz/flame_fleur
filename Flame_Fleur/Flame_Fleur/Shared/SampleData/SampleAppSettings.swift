import Foundation

enum SampleAppSettings {
    static let settings = AppSettings(
        units: .metric,
        cuisineStyle: "Mediterranean",
        dietaryPreferences: ["Vegetarian"],
        defaultServings: "2",
        isProfilePrivate: true,
        isActivityVisible: true,
        location: "Zurich, Switzerland",
        notificationsEnabled: true,
        language: "English"
    )
}
