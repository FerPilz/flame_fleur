import Foundation

struct AppSettings: Codable, Equatable {
    var units: MeasurementSystem
    var cuisineStyle: String
    var dietaryPreferences: [String]
    var defaultServings: String
    var isProfilePrivate: Bool
    var isActivityVisible: Bool
    var location: String
    var notificationsEnabled: Bool
    var language: String
}
