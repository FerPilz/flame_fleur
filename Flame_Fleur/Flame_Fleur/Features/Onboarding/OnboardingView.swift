import SwiftUI

enum OnboardingCompletionDestination {
    case home
    case planner
}

struct OnboardingCuisineOption: Identifiable, Hashable {
    let id: String
    let title: String
    let imageName: String?
}

struct OnboardingGoalOption: Identifiable, Hashable {
    let id: String
    let title: String
    let systemImage: String
}

struct OnboardingView: View {
    let initialCuisines: [String]
    let initialGoals: [String]
    let onUpdateCuisines: ([String]) -> Void
    let onUpdateGoals: ([String]) -> Void
    let onComplete: (OnboardingCompletionDestination, [String], [String]) -> Void
    let onSkip: ([String], [String]) -> Void

    @State private var currentStep = 1
    @State private var selectedCuisineIDs: Set<String>
    @State private var selectedGoalIDs: Set<String>

    private let recipeRepository = RecipeRepository.shared

    init(
        initialCuisines: [String] = [],
        initialGoals: [String] = [],
        onUpdateCuisines: @escaping ([String]) -> Void,
        onUpdateGoals: @escaping ([String]) -> Void,
        onComplete: @escaping (OnboardingCompletionDestination, [String], [String]) -> Void,
        onSkip: @escaping ([String], [String]) -> Void
    ) {
        self.initialCuisines = initialCuisines
        self.initialGoals = initialGoals
        self.onUpdateCuisines = onUpdateCuisines
        self.onUpdateGoals = onUpdateGoals
        self.onComplete = onComplete
        self.onSkip = onSkip
        _selectedCuisineIDs = State(initialValue: Set(initialCuisines.map(Self.normalizedID)))
        _selectedGoalIDs = State(initialValue: Set(initialGoals.map(Self.normalizedID)))
    }

    var body: some View {
        switch currentStep {
        case 1:
            OnboardingWelcomeView(
                onGetStarted: { currentStep = 2 },
                onSkip: handleSkip
            )

        case 2:
            OnboardingCuisinePreferencesView(
                options: cuisineOptions,
                selectedCuisineIDs: selectedCuisineIDs,
                onToggleCuisine: toggleCuisine,
                onContinue: continueFromCuisineStep,
                onSkipForNow: { currentStep = 3 },
                onSkip: handleSkip
            )

        case 3:
            OnboardingGoalPreferencesView(
                options: goalOptions,
                selectedGoalIDs: selectedGoalIDs,
                onToggleGoal: toggleGoal,
                onContinue: continueFromGoalStep,
                onSkipForNow: { currentStep = 4 },
                onSkip: handleSkip
            )

        default:
            OnboardingReadyView(
                heroRecipeImageName: readyRecipeImageName,
                ingredientImageNames: ["ingredient_broccoli", "ingredient_tomatoes", "ingredient_quinoa"],
                onStartExploring: { completeOnboarding(destination: .home) },
                onPlanFirstMeal: { completeOnboarding(destination: .planner) },
                onSkip: handleSkip
            )
        }
    }

    private var selectedCuisineTitles: [String] {
        cuisineOptions
            .filter { selectedCuisineIDs.contains($0.id) }
            .map(\.title)
    }

    private var selectedGoalTitles: [String] {
        goalOptions
            .filter { selectedGoalIDs.contains($0.id) }
            .map(\.title)
    }

    private var readyRecipeImageName: String? {
        firstRecipeImageName(for: ["lemon herb chicken bowl", "chicken bowl", "grain bowl", "bowl"], fallback: "ff_subcat_chicken_chicken_bowls")
    }

    private var cuisineOptions: [OnboardingCuisineOption] {
        [
            OnboardingCuisineOption(
                id: "italian",
                title: "Italian",
                imageName: firstRecipeImageName(for: ["italian pasta", "pasta", "italian"], fallback: "ff_subcat_world_cuisine_italian")
            ),
            OnboardingCuisineOption(
                id: "mexican",
                title: "Mexican",
                imageName: firstRecipeImageName(for: ["mexican taco", "taco", "mexican"], fallback: "world_mexican_charred_corn_tacos")
            ),
            OnboardingCuisineOption(
                id: "mediterranean",
                title: "Mediterranean",
                imageName: firstRecipeImageName(for: ["mediterranean", "greek", "falafel", "hummus"], fallback: "ff_subcat_world_cuisine_greek")
            ),
            OnboardingCuisineOption(
                id: "asian",
                title: "Asian",
                imageName: firstRecipeImageName(for: ["korean bowl", "noodle", "thai", "asian"], fallback: "world_korean_sesame_beef_bulgogi")
            ),
            OnboardingCuisineOption(
                id: "american",
                title: "American",
                imageName: firstRecipeImageName(for: ["burger", "sandwich", "comfort", "chicken"], fallback: "ff_subcat_chicken_grilled_chicken")
            ),
            OnboardingCuisineOption(
                id: "german",
                title: "German",
                imageName: firstRecipeImageName(for: ["bratwurst", "german"], fallback: "world_german_herbed_bratwurst_plate")
            ),
            OnboardingCuisineOption(
                id: "indian",
                title: "Indian",
                imageName: firstRecipeImageName(for: ["indian curry", "curry", "indian"], fallback: "ff_subcat_world_cuisine_indian")
            ),
            OnboardingCuisineOption(
                id: "vegetarian",
                title: "Vegetarian",
                imageName: firstRecipeImageName(for: ["vegetarian bowl", "plant based bowl", "salad", "vegetarian"], fallback: "ff_subcat_vegetarian_plant_based_bowls")
            ),
            OnboardingCuisineOption(
                id: "vegan",
                title: "Vegan",
                imageName: firstRecipeImageName(for: ["vegan", "plant based", "vegetarian"], fallback: "ff_subcat_vegetarian_plant_based_bowls")
            ),
            OnboardingCuisineOption(
                id: "seafood",
                title: "Seafood",
                imageName: firstRecipeImageName(for: ["seafood", "salmon", "fish"], fallback: "ff_subcat_seafood_fish_fillets")
            ),
            OnboardingCuisineOption(
                id: "paleo",
                title: "Paleo",
                imageName: firstRecipeImageName(for: ["paleo", "chicken", "protein"], fallback: "ff_subcat_chicken_grilled_chicken")
            ),
            OnboardingCuisineOption(
                id: "greek",
                title: "Greek",
                imageName: firstRecipeImageName(for: ["greek", "mediterranean", "falafel"], fallback: "ff_subcat_world_cuisine_greek")
            ),
            OnboardingCuisineOption(
                id: "low-carb",
                title: "Low Carb",
                imageName: firstRecipeImageName(for: ["low carb", "chicken bowl", "salad"], fallback: "ff_subcat_chicken_chicken_bowls")
            ),
            OnboardingCuisineOption(
                id: "high-protein",
                title: "High Protein",
                imageName: firstRecipeImageName(for: ["high protein", "chicken", "salmon"], fallback: "ff_subcat_chicken_grilled_chicken")
            )
        ]
    }

    private var goalOptions: [OnboardingGoalOption] {
        [
            OnboardingGoalOption(id: "quick-meals", title: "Quick meals", systemImage: "timer"),
            OnboardingGoalOption(id: "high-protein", title: "High protein", systemImage: "bolt.heart.fill"),
            OnboardingGoalOption(id: "budget-friendly", title: "Budget friendly", systemImage: "wallet.pass.fill"),
            OnboardingGoalOption(id: "healthy-balance", title: "Healthy balance", systemImage: "leaf.fill"),
            OnboardingGoalOption(id: "family-meals", title: "Family meals", systemImage: "person.3.fill"),
            OnboardingGoalOption(id: "vegetarian", title: "Vegetarian", systemImage: "leaf.circle.fill"),
            OnboardingGoalOption(id: "low-carb", title: "Low carb", systemImage: "chart.pie.fill"),
            OnboardingGoalOption(id: "meal-prep", title: "Meal prep", systemImage: "takeoutbag.and.cup.and.straw.fill")
        ]
    }

    private func continueFromCuisineStep() {
        onUpdateCuisines(selectedCuisineTitles)
        currentStep = 3
    }

    private func continueFromGoalStep() {
        onUpdateGoals(selectedGoalTitles)
        currentStep = 4
    }

    private func toggleCuisine(_ id: String) {
        if selectedCuisineIDs.contains(id) {
            selectedCuisineIDs.remove(id)
        } else {
            selectedCuisineIDs.insert(id)
        }
    }

    private func toggleGoal(_ id: String) {
        if selectedGoalIDs.contains(id) {
            selectedGoalIDs.remove(id)
        } else {
            selectedGoalIDs.insert(id)
        }
    }

    private func completeOnboarding(destination: OnboardingCompletionDestination) {
        onUpdateCuisines(selectedCuisineTitles)
        onUpdateGoals(selectedGoalTitles)
        onComplete(destination, selectedCuisineTitles, selectedGoalTitles)
    }

    private func handleSkip() {
        onUpdateCuisines(selectedCuisineTitles)
        onUpdateGoals(selectedGoalTitles)
        onSkip(selectedCuisineTitles, selectedGoalTitles)
    }

    private func firstRecipeImageName(for queries: [String], fallback: String) -> String? {
        for query in queries {
            if let imageName = recipeRepository.recipes(matching: query).compactMap(\.imageName).first {
                return imageName
            }
        }

        return fallback
    }

    private static func normalizedID(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: "&", with: "and")
            .replacingOccurrences(of: " ", with: "-")
    }
}

#Preview {
    OnboardingView(
        onUpdateCuisines: { _ in },
        onUpdateGoals: { _ in },
        onComplete: { _, _, _ in },
        onSkip: { _, _ in }
    )
}
