import Combine
import Foundation

final class OnboardingPreferencesStore: ObservableObject {
    static let shared = OnboardingPreferencesStore()

    @Published private(set) var preferences: OnboardingPreferences

    private let fileManager: FileManager
    private let fileURL: URL

    init(
        fileManager: FileManager = .default,
        fileURL: URL? = nil
    ) {
        self.fileManager = fileManager
        self.fileURL = fileURL ?? Self.defaultFileURL(fileManager: fileManager)
        self.preferences = Self.loadPreferences(from: self.fileURL)
    }

    var hasCompletedOnboarding: Bool {
        preferences.hasCompletedOnboarding
    }

    func setSelectedCuisines(_ cuisines: [String]) {
        preferences.selectedCuisines = Self.normalizedSelection(cuisines)
        persist()
    }

    func setSelectedGoals(_ goals: [String]) {
        preferences.selectedGoals = Self.normalizedSelection(goals)
        persist()
    }

    func completeOnboarding() {
        preferences.hasCompletedOnboarding = true
        preferences.completedAt = Date()
        persist()
    }

    func skipOnboarding() {
        completeOnboarding()
    }

    func resetOnboarding() {
        preferences = .empty
        persist()
    }

    private func persist() {
        do {
            try fileManager.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601

            let data = try encoder.encode(preferences)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            #if DEBUG
            print("OnboardingPreferencesStore: failed to persist preferences: \(error)")
            #endif
        }
    }

    private static func loadPreferences(from fileURL: URL) -> OnboardingPreferences {
        guard let data = try? Data(contentsOf: fileURL) else {
            return .empty
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(OnboardingPreferences.self, from: data)
        } catch {
            #if DEBUG
            print("OnboardingPreferencesStore: failed to load preferences: \(error)")
            #endif
            return .empty
        }
    }

    private static func defaultFileURL(fileManager: FileManager) -> URL {
        let baseDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory

        return baseDirectory
            .appendingPathComponent("Flame_Fleur", isDirectory: true)
            .appendingPathComponent("onboarding_preferences.json", isDirectory: false)
    }

    private static func normalizedSelection(_ values: [String]) -> [String] {
        var seen = Set<String>()
        var normalized: [String] = []

        for value in values.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }).filter({ !$0.isEmpty }) {
            let key = value.lowercased()
            guard seen.insert(key).inserted else {
                continue
            }
            normalized.append(value)
        }

        return normalized
    }
}
