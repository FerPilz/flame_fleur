import Foundation

struct RecipeImportService {
    private let session: URLSession
    private let parser: RecipeJSONLDParser

    init(session: URLSession = .shared, parser: RecipeJSONLDParser = RecipeJSONLDParser()) {
        self.session = session
        self.parser = parser
    }

    func fetchHTML(from urlString: String) async throws -> String {
        let trimmedURLString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedURLString.isEmpty else {
            throw RecipeImportError.invalidURL
        }

        guard let url = URL(string: trimmedURLString),
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme) else {
            throw RecipeImportError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CookFlow/1.0 Mobile/15E148 Safari/604.1",
            forHTTPHeaderField: "User-Agent"
        )
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw RecipeImportError.networkFailure
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw RecipeImportError.networkFailure
        }

        guard !data.isEmpty else {
            throw RecipeImportError.emptyResponse
        }

        if let mimeType = httpResponse.mimeType?.lowercased(),
           !mimeType.contains("html"),
           !mimeType.contains("xml"),
           !mimeType.contains("text") {
            throw RecipeImportError.unsupportedPage
        }

        guard let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
            throw RecipeImportError.emptyResponse
        }

        return html
    }

    func importRecipe(from urlString: String) async -> RecipeImportResult {
        do {
            let trimmedURLString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let url = URL(string: trimmedURLString),
                  let scheme = url.scheme?.lowercased(),
                  ["http", "https"].contains(scheme) else {
                return .failure(.invalidURL)
            }

            let html = try await fetchHTML(from: trimmedURLString)

            let result = parser.parse(html: html, sourceURL: url)

            return result
        } catch let importError as RecipeImportError {
            return .failure(importError)
        } catch {
            return .failure(.unknown)
        }
    }
}
