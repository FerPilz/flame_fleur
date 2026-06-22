import Foundation

struct RecipeIngredient: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let quantity: Double
    let unit: String
    let category: String
    let notes: String?
    let displayQuantity: String

    init(
        id: String? = nil,
        name: String,
        quantity: Double,
        unit: String,
        category: String,
        notes: String? = nil,
        displayQuantity: String = ""
    ) {
        self.id = id ?? RecipeIngredient.stableID(
            name: name,
            quantity: quantity,
            unit: unit,
            category: category,
            displayQuantity: displayQuantity
        )
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.category = category
        self.notes = notes
        self.displayQuantity = displayQuantity.isEmpty
            ? RecipeIngredient.defaultDisplayQuantity(quantity: quantity, unit: unit)
            : displayQuantity
    }

    init(legacyName: String) {
        self.init(
            name: legacyName,
            quantity: 1,
            unit: "",
            category: "",
            notes: nil,
            displayQuantity: ""
        )
    }

    var normalizedName: String {
        RecipeIngredient.normalize(name)
    }

    var displayLine: String {
        displayQuantity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? name
            : "\(displayQuantity) \(name)"
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case quantity
        case unit
        case category
        case notes
        case displayQuantity
    }

    init(from decoder: Decoder) throws {
        if let singleValue = try? decoder.singleValueContainer(),
           let legacyName = try? singleValue.decode(String.self) {
            self.init(legacyName: legacyName)
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let quantity = try container.decodeIfPresent(Double.self, forKey: .quantity) ?? 1
        let unit = try container.decodeIfPresent(String.self, forKey: .unit) ?? ""
        let category = try container.decodeIfPresent(String.self, forKey: .category) ?? ""
        let notes = try container.decodeIfPresent(String.self, forKey: .notes)
        let displayQuantity = try container.decodeIfPresent(String.self, forKey: .displayQuantity) ?? ""

        self.init(
            id: try container.decodeIfPresent(String.self, forKey: .id),
            name: name,
            quantity: quantity,
            unit: unit,
            category: category,
            notes: notes,
            displayQuantity: displayQuantity
        )
    }

    private static func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
    }

    private static func stableID(name: String, quantity: Double, unit: String, category: String, displayQuantity: String) -> String {
        let token = [
            normalize(name),
            normalize(unit),
            normalize(category),
            normalize(displayQuantity.isEmpty ? defaultDisplayQuantity(quantity: quantity, unit: unit) : displayQuantity)
        ]
        .filter { !$0.isEmpty }
        .joined(separator: "_")
        .replacingOccurrences(of: #"[^\w]+"#, with: "_", options: .regularExpression)
        .replacingOccurrences(of: #"_+"#, with: "_", options: .regularExpression)
        .trimmingCharacters(in: CharacterSet(charactersIn: "_"))

        return token.isEmpty ? UUID().uuidString.lowercased() : "ingredient_\(token)"
    }

    private static func defaultDisplayQuantity(quantity: Double, unit: String) -> String {
        let formattedQuantity = formatQuantity(quantity)
        let trimmedUnit = unit.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUnit.isEmpty else {
            return formattedQuantity
        }
        return "\(formattedQuantity) \(trimmedUnit)"
    }

    private static func formatQuantity(_ quantity: Double) -> String {
        let rounded = quantity.rounded()
        if abs(quantity - rounded) < 0.001 {
            return String(Int(rounded))
        }

        let commonFractions: [(value: Double, text: String)] = [
            (0.25, "1/4"),
            (0.333, "1/3"),
            (0.5, "1/2"),
            (0.666, "2/3"),
            (0.75, "3/4")
        ]

        let whole = Int(quantity)
        let fractional = quantity - Double(whole)

        if let matched = commonFractions.first(where: { abs(fractional - $0.value) < 0.035 }) {
            if whole > 0 {
                return "\(whole) \(matched.text)"
            }
            return matched.text
        }

        return String(format: "%.2f", quantity).replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression).replacingOccurrences(of: #"\.$"#, with: "", options: .regularExpression)
    }
}
