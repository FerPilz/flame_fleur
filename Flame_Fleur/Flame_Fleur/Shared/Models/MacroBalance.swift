import Foundation

struct MacroBalance: Hashable {
    let calories: Double
    let proteinGrams: Int
    let carbsGrams: Int
    let fatGrams: Int
    let calorieTarget: Double
    let proteinTargetGrams: Double
    let carbsTargetGrams: Double
    let fatTargetGrams: Double

    init(summary: NutritionSummary, targets: PlannerNutritionTargets = .placeholder) {
        self.calories = summary.calories
        self.proteinGrams = Int(summary.proteinGrams.rounded())
        self.carbsGrams = Int(summary.carbohydrateGrams.rounded())
        self.fatGrams = Int(summary.fatGrams.rounded())
        self.calorieTarget = targets.calorieTarget
        self.proteinTargetGrams = targets.proteinTargetGrams
        self.carbsTargetGrams = targets.carbohydrateTargetGrams
        self.fatTargetGrams = targets.fatTargetGrams
    }

    var totalGrams: Int {
        proteinGrams + carbsGrams + fatGrams
    }

    var caloriesText: String {
        NutritionSummary.wholeNumberText(calories)
    }

    var calorieTargetText: String {
        NutritionSummary.wholeNumberText(calorieTarget)
    }

    var proteinText: String {
        NutritionSummary.gramsText(Double(proteinGrams))
    }

    var proteinTargetText: String {
        NutritionSummary.gramsText(proteinTargetGrams)
    }

    var carbsText: String {
        NutritionSummary.gramsText(Double(carbsGrams))
    }

    var carbsTargetText: String {
        NutritionSummary.gramsText(carbsTargetGrams)
    }

    var fatText: String {
        NutritionSummary.gramsText(Double(fatGrams))
    }

    var fatTargetText: String {
        NutritionSummary.gramsText(fatTargetGrams)
    }

    var calorieProgress: Double {
        progress(for: calories, target: calorieTarget)
    }

    var proteinProgress: Double {
        progress(for: Double(proteinGrams), target: proteinTargetGrams)
    }

    var carbsProgress: Double {
        progress(for: Double(carbsGrams), target: carbsTargetGrams)
    }

    var fatProgress: Double {
        progress(for: Double(fatGrams), target: fatTargetGrams)
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

    private func progress(for value: Double, target: Double) -> Double {
        guard target > 0 else { return 0 }
        return min(max(value / target, 0), 1)
    }

    func status(for value: Double, target: Double) -> MacroTrendState {
        guard target > 0 else { return .low }

        let ratio = value / target

        switch ratio {
        case ..<0.70:
            return .low
        case 0.70..<1.0:
            return .onTrack
        case 1.0..<1.15:
            return .warning
        default:
            return .overTarget
        }
    }
}

enum MacroTrendState: String, Hashable, Codable {
    case low
    case onTrack
    case warning
    case overTarget
}
