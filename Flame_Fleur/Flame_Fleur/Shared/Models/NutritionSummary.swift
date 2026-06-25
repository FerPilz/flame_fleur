import Foundation

struct NutritionSummary: Hashable, Codable, AdditiveArithmetic {
    var calories: Double
    var proteinGrams: Double
    var carbohydrateGrams: Double
    var fatGrams: Double
    var fiberGrams: Double
    var sugarGrams: Double
    var sodiumMilligrams: Double

    init(
        calories: Double = 0,
        proteinGrams: Double = 0,
        carbohydrateGrams: Double = 0,
        fatGrams: Double = 0,
        fiberGrams: Double = 0,
        sugarGrams: Double = 0,
        sodiumMilligrams: Double = 0
    ) {
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbohydrateGrams = carbohydrateGrams
        self.fatGrams = fatGrams
        self.fiberGrams = fiberGrams
        self.sugarGrams = sugarGrams
        self.sodiumMilligrams = sodiumMilligrams
    }

    static let zero = NutritionSummary()

    static func + (lhs: NutritionSummary, rhs: NutritionSummary) -> NutritionSummary {
        NutritionSummary(
            calories: lhs.calories + rhs.calories,
            proteinGrams: lhs.proteinGrams + rhs.proteinGrams,
            carbohydrateGrams: lhs.carbohydrateGrams + rhs.carbohydrateGrams,
            fatGrams: lhs.fatGrams + rhs.fatGrams,
            fiberGrams: lhs.fiberGrams + rhs.fiberGrams,
            sugarGrams: lhs.sugarGrams + rhs.sugarGrams,
            sodiumMilligrams: lhs.sodiumMilligrams + rhs.sodiumMilligrams
        )
    }

    static func - (lhs: NutritionSummary, rhs: NutritionSummary) -> NutritionSummary {
        NutritionSummary(
            calories: lhs.calories - rhs.calories,
            proteinGrams: lhs.proteinGrams - rhs.proteinGrams,
            carbohydrateGrams: lhs.carbohydrateGrams - rhs.carbohydrateGrams,
            fatGrams: lhs.fatGrams - rhs.fatGrams,
            fiberGrams: lhs.fiberGrams - rhs.fiberGrams,
            sugarGrams: lhs.sugarGrams - rhs.sugarGrams,
            sodiumMilligrams: lhs.sodiumMilligrams - rhs.sodiumMilligrams
        )
    }

    func scaled(by factor: Double) -> NutritionSummary {
        NutritionSummary(
            calories: calories * factor,
            proteinGrams: proteinGrams * factor,
            carbohydrateGrams: carbohydrateGrams * factor,
            fatGrams: fatGrams * factor,
            fiberGrams: fiberGrams * factor,
            sugarGrams: sugarGrams * factor,
            sodiumMilligrams: sodiumMilligrams * factor
        )
    }

    var caloriesText: String {
        Self.wholeNumberText(calories)
    }

    var proteinText: String {
        Self.gramsText(proteinGrams)
    }

    var carbohydrateText: String {
        Self.gramsText(carbohydrateGrams)
    }

    var fatText: String {
        Self.gramsText(fatGrams)
    }

    var fiberText: String {
        Self.gramsText(fiberGrams)
    }

    var sugarText: String {
        Self.gramsText(sugarGrams)
    }

    var sodiumText: String {
        Self.milligramsText(sodiumMilligrams)
    }

    static func clampedPercentage(_ value: Double) -> Double {
        min(max(value, 0), 100)
    }

    static func percentageText(_ value: Double) -> String {
        "\(Int(clampedPercentage(value).rounded()))%"
    }

    static func wholeNumberText(_ value: Double) -> String {
        String(Int(value.rounded()))
    }

    static func gramsText(_ value: Double) -> String {
        "\(wholeNumberText(value))g"
    }

    static func milligramsText(_ value: Double) -> String {
        "\(wholeNumberText(value))mg"
    }
}
