import Foundation

struct PlannerNutritionTargets: Hashable {
    let calorieTarget: Double
    let proteinTargetGrams: Double
    let carbohydrateTargetGrams: Double
    let fatTargetGrams: Double

    /// Temporary defaults until user-specific nutrition goals are available.
    static let placeholder = PlannerNutritionTargets(
        calorieTarget: 2_000,
        proteinTargetGrams: 120,
        carbohydrateTargetGrams: 250,
        fatTargetGrams: 70
    )
}
