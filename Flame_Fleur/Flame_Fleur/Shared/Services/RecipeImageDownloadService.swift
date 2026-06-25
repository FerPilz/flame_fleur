import Foundation

struct RecipeImageDownloadService {
    static let shared = RecipeImageDownloadService()

    private let urlSession: URLSession
    private let imageStore: RecipeImageStore

    init(
        urlSession: URLSession = .shared,
        imageStore: RecipeImageStore = .shared
    ) {
        self.urlSession = urlSession
        self.imageStore = imageStore
    }

    func downloadAndStoreImage(from urlString: String?) async -> String? {
        guard let urlString = urlString?.trimmingCharacters(in: .whitespacesAndNewlines),
              let url = URL(string: urlString) else {
            return nil
        }

        return await downloadAndStoreImage(from: url)
    }

    func downloadAndStoreImage(from url: URL?) async -> String? {
        guard let url else {
            return nil
        }

        do {
            let (data, response) = try await urlSession.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode),
                  !data.isEmpty else {
                return nil
            }

            if let mimeType = httpResponse.mimeType?.lowercased(),
               !mimeType.hasPrefix("image/") {
                return nil
            }

            return imageStore.saveImageData(data)
        } catch {
            return nil
        }
    }
}
