import Foundation

struct MacroBalance: Hashable {
    let proteinGrams: Int
    let carbsGrams: Int
    let fatGrams: Int

    var totalGrams: Int {
        proteinGrams + carbsGrams + fatGrams
    }

    var proteinPercentage: Double {
        percentage(for: proteinGrams)
    }

    var carbsPercentage: Double {
        percentage(for: carbsGrams)
    }

    var fatPercentage: Double {
        percentage(for: fatGrams)
    }

    private func percentage(for grams: Int) -> Double {
        guard totalGrams > 0 else { return 0 }
        return Double(grams) / Double(totalGrams)
    }
}
