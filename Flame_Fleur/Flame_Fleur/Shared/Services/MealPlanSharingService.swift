import Foundation

enum MealPlanSharingService {
    static let sharedFileName = "allspiced_meal_plan.json"

    static func exportFileURL(for payload: SharedMealPlanPayload) throws -> URL {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(payload)
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(sharedFileName)
        try data.write(to: fileURL, options: [.atomic])
        return fileURL
    }

    static func decodePayload(from url: URL) throws -> SharedMealPlanPayload {
        let data = try Data(contentsOf: url)
        return try decodePayload(from: data)
    }

    static func decodePayload(from data: Data) throws -> SharedMealPlanPayload {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(SharedMealPlanPayload.self, from: data)
    }
}
