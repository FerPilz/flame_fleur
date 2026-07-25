import Foundation

enum CartSharingService {
    static let sharedTextFileName = "flame_fleur_cart.txt"

    static func exportTextFileURL(for text: String) throws -> URL {
        let data = Data(text.utf8)
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(sharedTextFileName)
        try data.write(to: fileURL, options: [.atomic])
        return fileURL
    }

    static func decodePayload(from url: URL) throws -> SharedCartPayload {
        let data = try Data(contentsOf: url)
        return try decodePayload(from: data)
    }

    static func decodePayload(from data: Data) throws -> SharedCartPayload {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(SharedCartPayload.self, from: data)
    }
}
