import Combine
import Foundation

final class UsageTrackingStore: ObservableObject {
    static let shared = UsageTrackingStore()

    @Published private(set) var events: [UsageEvent]

    private let fileManager: FileManager
    private let fileURL: URL
    private let recipeViewThrottleInterval: TimeInterval
    private let maxStoredEvents: Int

    init(
        fileManager: FileManager = .default,
        fileURL: URL? = nil,
        recipeViewThrottleInterval: TimeInterval = 10 * 60,
        maxStoredEvents: Int = 2_000
    ) {
        self.fileManager = fileManager
        self.fileURL = fileURL ?? Self.defaultFileURL(fileManager: fileManager)
        self.recipeViewThrottleInterval = recipeViewThrottleInterval
        self.maxStoredEvents = maxStoredEvents
        self.events = Self.loadEvents(from: self.fileURL)
    }

    var recentEvents: [UsageEvent] {
        events.sorted { $0.date > $1.date }
    }

    func recentEvents(limit: Int) -> [UsageEvent] {
        Array(recentEvents.prefix(max(limit, 0)))
    }

    func record(_ event: UsageEvent) {
        events.append(event)

        if events.count > maxStoredEvents {
            events.removeFirst(events.count - maxStoredEvents)
        }

        persist()
    }

    func record(
        type: UsageEventType,
        recipe: Recipe? = nil,
        recipeID: String? = nil,
        recipeTitle: String? = nil,
        cuisine: String? = nil,
        category: String? = nil,
        mealType: String? = nil,
        ingredientNames: [String]? = nil,
        calories: Double? = nil,
        proteinGrams: Double? = nil,
        carbGrams: Double? = nil,
        fatGrams: Double? = nil,
        date: Date = Date()
    ) {
        let resolvedNutrition = recipe.map { RecipeInsightResolver.nutritionSummary(for: $0) }
        let normalizedIngredients = ingredientNames ?? recipe.map {
            RecipeInsightResolver.normalizedIngredientNames(for: $0)
        } ?? []

        record(
            UsageEvent(
                type: type,
                date: date,
                recipeID: recipe?.id ?? recipeID,
                recipeTitle: recipe?.title ?? recipeTitle,
                cuisine: recipe.flatMap { RecipeInsightResolver.cuisineName(for: $0) } ?? cuisine,
                category: recipe?.category.title ?? category,
                mealType: mealType,
                ingredientNames: normalizedIngredients,
                calories: calories ?? resolvedNutrition?.calories,
                proteinGrams: proteinGrams ?? resolvedNutrition?.proteinGrams,
                carbGrams: carbGrams ?? resolvedNutrition?.carbohydrateGrams,
                fatGrams: fatGrams ?? resolvedNutrition?.fatGrams
            )
        )
    }

    @discardableResult
    func recordRecipeViewIfNeeded(
        for recipe: Recipe,
        now: Date = Date()
    ) -> Bool {
        let lastViewedAt = events
            .lazy
            .reversed()
            .first { event in
                event.type == .recipeViewed && event.recipeID == recipe.id
            }?
            .date

        if let lastViewedAt,
           now.timeIntervalSince(lastViewedAt) < recipeViewThrottleInterval {
            return false
        }

        record(type: .recipeViewed, recipe: recipe, date: now)
        return true
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

            let data = try encoder.encode(events)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            #if DEBUG
            print("UsageTrackingStore: failed to persist usage events: \(error)")
            #endif
        }
    }

    private static func loadEvents(from fileURL: URL) -> [UsageEvent] {
        guard let data = try? Data(contentsOf: fileURL) else {
            return []
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([UsageEvent].self, from: data)
        } catch {
            #if DEBUG
            print("UsageTrackingStore: failed to load usage events: \(error)")
            #endif
            return []
        }
    }

    private static func defaultFileURL(fileManager: FileManager) -> URL {
        let baseDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory

        return baseDirectory
            .appendingPathComponent("Flame_Fleur", isDirectory: true)
            .appendingPathComponent("usage_events.json", isDirectory: false)
    }
}
