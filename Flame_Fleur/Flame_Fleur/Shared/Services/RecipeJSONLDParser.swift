import Foundation

struct RecipeJSONLDParser {
    func parse(html: String, sourceURL: URL) -> RecipeImportResult {
        let scripts = jsonLDScripts(in: html)
        var bestCandidate: Candidate?

        for script in scripts {
            guard let data = script.data(using: .utf8) else {
                continue
            }

            guard let jsonObject = try? JSONSerialization.jsonObject(with: data) else {
                continue
            }

            if let candidate = bestRecipeCandidate(in: jsonObject),
               candidate.score > (bestCandidate?.score ?? -1) {
                bestCandidate = candidate
            }
        }

        if let bestCandidate {
            return buildResult(from: bestCandidate.object, sourceURL: sourceURL)
        }

        return .failure(.noRecipeFound)
    }

    private func buildResult(from recipe: [String: Any], sourceURL: URL) -> RecipeImportResult {
        var warnings: [RecipeImportWarning] = []

        let rawTitle = stringValue(recipe["name"]).trimmingCharacters(in: .whitespacesAndNewlines)
        let title = rawTitle.isEmpty ? "Imported Recipe" : rawTitle
        if rawTitle.isEmpty {
            warnings.append(.missingTitle)
        }

        let rawIngredients = stringArray(recipe["recipeIngredient"])
        let ingredients = rawIngredients.map { ImportedIngredientDraft(rawText: $0, name: cleanedIngredientName($0)) }
        if ingredients.isEmpty {
            warnings.append(.missingIngredients)
        }

        let instructions = instructionLines(from: recipe["recipeInstructions"])
        if instructions.isEmpty {
            warnings.append(.missingInstructions)
        }

        let imageURL = imageURL(from: recipe["image"], sourceURL: sourceURL)
        if imageURL == nil {
            warnings.append(.missingImage)
        }

        let servings = yieldValue(from: recipe["recipeYield"])
        let prepTimeMinutes = durationMinutes(from: recipe["prepTime"])
        let cookTimeMinutes = durationMinutes(from: recipe["cookTime"])
        let totalTimeMinutes = durationMinutes(from: recipe["totalTime"])

        let draft = ImportedRecipeDraft(
            title: title,
            sourceURL: sourceURL,
            sourceHost: sourceURL.host,
            imageURL: imageURL,
            servings: servings,
            prepTimeMinutes: prepTimeMinutes,
            cookTimeMinutes: cookTimeMinutes,
            totalTimeMinutes: totalTimeMinutes,
            ingredients: ingredients,
            instructions: instructions,
            notes: stringValue(recipe["description"]),
            parserSource: .jsonLD
        )

        if warnings.isEmpty {
            return .success(draft)
        }

        return .partial(draft, warnings: warnings)
    }

    private func jsonLDScripts(in html: String) -> [String] {
        let pattern = #"<script\b([^>]*)>(.*?)</script>"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) else {
            return []
        }

        let range = NSRange(html.startIndex..., in: html)
        return regex.matches(in: html, options: [], range: range).compactMap { match in
            guard match.numberOfRanges > 2,
                  let attributesRange = Range(match.range(at: 1), in: html),
                  let scriptRange = Range(match.range(at: 2), in: html) else {
                return nil
            }

            let attributes = String(html[attributesRange])
            guard containsJSONLDType(in: attributes) else {
                return nil
            }

            let content = html[scriptRange]
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let unescapedContent = htmlUnescaped(String(content))
            return unescapedContent.isEmpty ? nil : unescapedContent
        }
    }

    private func containsJSONLDType(in attributes: String) -> Bool {
        let pattern = #"type\s*=\s*(?:"application/ld\+json"|'application/ld\+json'|application/ld\+json)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return false
        }

        let range = NSRange(attributes.startIndex..., in: attributes)
        return regex.firstMatch(in: attributes, options: [], range: range) != nil
    }

    private func bestRecipeCandidate(in json: Any) -> Candidate? {
        if let dictionary = json as? [String: Any] {
            var bestCandidate: Candidate?

            if let score = recipeCandidateScore(dictionary) {
                bestCandidate = Candidate(object: dictionary, score: score)
            }

            if let graph = dictionary["@graph"], let graphCandidate = bestRecipeCandidate(in: graph) {
                bestCandidate = bestCandidate == nil || graphCandidate.score > bestCandidate!.score ? graphCandidate : bestCandidate
            }

            for value in dictionary.values {
                if let nestedCandidate = bestRecipeCandidate(in: value) {
                    bestCandidate = bestCandidate == nil || nestedCandidate.score > bestCandidate!.score ? nestedCandidate : bestCandidate
                }
            }

            return bestCandidate
        } else if let array = json as? [Any] {
            var bestCandidate: Candidate?
            for value in array {
                if let nestedCandidate = bestRecipeCandidate(in: value) {
                    bestCandidate = bestCandidate == nil || nestedCandidate.score > bestCandidate!.score ? nestedCandidate : bestCandidate
                }
            }
            return bestCandidate
        }

        return nil
    }

    private func recipeCandidateScore(_ dictionary: [String: Any]) -> Int? {
        let isRecipe = isRecipeType(dictionary["@type"])
        let hasIngredients = !stringArray(dictionary["recipeIngredient"]).isEmpty
        let hasInstructions = !instructionLines(from: dictionary["recipeInstructions"]).isEmpty
        let hasName = nonEmptyString(stringValue(dictionary["name"])) != nil || nonEmptyString(stringValue(dictionary["headline"])) != nil

        var score = 0
        if isRecipe { score += 100 }
        if hasIngredients { score += 40 }
        if hasInstructions { score += 40 }
        if hasName { score += 10 }

        // Support partial candidates that still have enough editable content to preview.
        if score == 0 {
            return nil
        }

        if !isRecipe, !hasIngredients, !hasInstructions {
            return nil
        }

        return score
    }

    private func isRecipeType(_ value: Any?) -> Bool {
        switch value {
        case let string as String:
            return normalizedType(string) == "recipe"
        case let strings as [String]:
            return strings.contains { normalizedType($0) == "recipe" }
        case let array as [Any]:
            return array.contains { element in
                if let string = element as? String {
                    return normalizedType(string) == "recipe"
                }
                return false
            }
        default:
            return false
        }
    }

    private func instructionLines(from value: Any?) -> [String] {
        switch value {
        case let strings as [String]:
            return strings.compactMap(cleanedInstruction)
        case let string as String:
            return [cleanedInstruction(string)].compactMap { $0 }
        case let dictionaries as [[String: Any]]:
            return dictionaries.flatMap { instructionLines(from: $0) }
        case let array as [Any]:
            return array.flatMap { instructionLines(from: $0) }
        case let dictionary as [String: Any]:
            if let cleaned = cleanedInstruction(stringValue(dictionary["text"])) {
                return [cleaned]
            }
            if let itemListElement = dictionary["itemListElement"] {
                return instructionLines(from: itemListElement)
            }
            if let cleaned = cleanedInstruction(stringValue(dictionary["name"])) {
                return [cleaned]
            }
            return dictionary.values.flatMap { instructionLines(from: $0) }
        default:
            return []
        }
    }

    private func stringArray(_ value: Any?) -> [String] {
        switch value {
        case let strings as [String]:
            return strings.compactMap { nonEmptyString($0) }
        case let string as String:
            return [nonEmptyString(string)].compactMap { $0 }
        case let dictionaries as [[String: Any]]:
            return dictionaries.compactMap { dictionary in
                if let text = nonEmptyString(stringValue(dictionary["text"])) {
                    return text
                }
                if let name = nonEmptyString(stringValue(dictionary["name"])) {
                    return name
                }
                return nil
            }
        case let array as [Any]:
            return array.flatMap { stringArray($0) }
        default:
            return []
        }
    }

    private func imageURL(from value: Any?, sourceURL: URL) -> URL? {
        switch value {
        case let string as String:
            return URL(string: string, relativeTo: sourceURL)?.absoluteURL
        case let strings as [String]:
            return strings.lazy.compactMap { URL(string: $0, relativeTo: sourceURL)?.absoluteURL }.first
        case let dictionary as [String: Any]:
            if let url = URL(string: stringValue(dictionary["url"]), relativeTo: sourceURL)?.absoluteURL {
                return url
            }
            if let url = URL(string: stringValue(dictionary["@id"]), relativeTo: sourceURL)?.absoluteURL {
                return url
            }
            return dictionary.values.compactMap { imageURL(from: $0, sourceURL: sourceURL) }.first
        case let array as [Any]:
            return array.compactMap { imageURL(from: $0, sourceURL: sourceURL) }.first
        default:
            return nil
        }
    }

    private func yieldValue(from value: Any?) -> Int? {
        let string = stringValue(value).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !string.isEmpty else {
            return nil
        }

        if let regex = try? NSRegularExpression(pattern: #"(\d+)"#, options: []) {
            let range = NSRange(string.startIndex..., in: string)
            if let match = regex.firstMatch(in: string, options: [], range: range),
               let matchedRange = Range(match.range(at: 1), in: string) {
                return Int(String(string[matchedRange]))
            }
        }

        return nil
    }

    private func durationMinutes(from value: Any?) -> Int? {
        let string = stringValue(value).trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard string.hasPrefix("PT") else {
            return nil
        }

        let hoursPattern = #"(?:(\d+(?:\.\d+)?)H)?"#
        let minutesPattern = #"(?:(\d+(?:\.\d+)?)M)?"#
        let secondsPattern = #"(?:(\d+(?:\.\d+)?)S)?"#
        let pattern = "^PT\(hoursPattern)\(minutesPattern)\(secondsPattern)$"

        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }

        let range = NSRange(string.startIndex..., in: string)
        guard let match = regex.firstMatch(in: string, options: [], range: range) else {
            return nil
        }

        let hours = doubleValue(in: match, at: 1, in: string) ?? 0
        let minutes = doubleValue(in: match, at: 2, in: string) ?? 0
        let seconds = doubleValue(in: match, at: 3, in: string) ?? 0
        let total = (hours * 60) + minutes + (seconds / 60)
        return Int(total.rounded(.up))
    }

    private func doubleValue(in match: NSTextCheckingResult, at index: Int, in string: String) -> Double? {
        guard match.numberOfRanges > index,
              let range = Range(match.range(at: index), in: string) else {
            return nil
        }
        return Double(String(string[range]))
    }

    private func cleanedIngredientName(_ rawText: String) -> String {
        let trimmed = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
    }

    private func cleanedInstruction(_ rawText: String) -> String? {
        let trimmed = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        let collapsed = trimmed.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
        return collapsed.isEmpty ? nil : collapsed
    }

    private func stringValue(_ value: Any?) -> String {
        switch value {
        case let string as String:
            return string
        case let number as NSNumber:
            return number.stringValue
        case let strings as [String]:
            return strings.first ?? ""
        case let array as [Any]:
            for element in array {
                let candidate = stringValue(element).trimmingCharacters(in: .whitespacesAndNewlines)
                if !candidate.isEmpty {
                    return candidate
                }
            }
            return ""
        case let dictionary as [String: Any]:
            if let text = dictionary["text"] {
                return stringValue(text)
            }
            if let name = dictionary["name"] {
                return stringValue(name)
            }
            if let url = dictionary["url"] {
                return stringValue(url)
            }
            return ""
        default:
            return ""
        }
    }

    private func normalizedType(_ value: String) -> String {
        let trimmed = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        guard !trimmed.isEmpty else {
            return ""
        }

        if let lastComponent = trimmed
            .split(whereSeparator: { $0 == "/" || $0 == "#" || $0 == ":" })
            .last {
            return String(lastComponent)
        }

        return trimmed
    }

    private func htmlUnescaped(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#34;", with: "\"")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&#x2F;", with: "/")
            .replacingOccurrences(of: "&#47;", with: "/")
    }

    private func nonEmptyString(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private struct Candidate {
        let object: [String: Any]
        let score: Int
    }
}
