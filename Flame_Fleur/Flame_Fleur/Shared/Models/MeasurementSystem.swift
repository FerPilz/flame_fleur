import Foundation

enum MeasurementSystem: String, CaseIterable, Codable, Identifiable {
    case metric
    case imperial

    var id: String { rawValue }

    var title: String {
        switch self {
        case .metric:
            return "Metric"
        case .imperial:
            return "Imperial"
        }
    }

    var detail: String {
        switch self {
        case .metric:
            return "kg, \u{00B0}C"
        case .imperial:
            return "lb, \u{00B0}F"
        }
    }

    var displayValue: String {
        "\(title) (\(detail))"
    }
}
