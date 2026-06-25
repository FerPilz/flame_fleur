import SwiftUI

struct PlannerRecipePickerView: View {
    let context: PlannerRecipeSelectionContext
    let recipes: [Recipe]
    let onRecipeSelected: (Recipe.ID) -> Void

    @EnvironmentObject private var favoritesStore: FavoritesStore
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedFilter: PlannerRecipePickerFilter = .all
    @State private var selectedSort: PlannerRecipePickerSort = .recommended

    init(
        context: PlannerRecipeSelectionContext,
        recipes: [Recipe] = RecipeRepository.shared.allRecipes,
        onRecipeSelected: @escaping (Recipe.ID) -> Void = { _ in }
    ) {
        self.context = context
        self.recipes = recipes
        self.onRecipeSelected = onRecipeSelected
    }

    var body: some View {
        AppScreen(
            contentSpacing: AppSpacing.md,
            headerTopPadding: AppSpacing.xs,
            contentBottomPadding: AppSpacing.xxxl + AppSpacing.xxl
        ) {
            header
        } content: {
            searchField
            filterChips
            sortRow

            if visibleRecipes.isEmpty {
                emptyState
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: AppSpacing.sm),
                        GridItem(.flexible(), spacing: AppSpacing.sm)
                    ],
                    spacing: AppSpacing.sm
                ) {
                    ForEach(visibleRecipes) { recipe in
                        RecipeCard(
                            recipe: recipe,
                            isFavorite: favoritesStore.isFavorite(recipe.id),
                            action: {
                                onRecipeSelected(recipe.id)
                            },
                            favoriteAction: {
                                favoritesStore.toggleFavorite(recipe.id)
                            }
                        )
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            IconCircleButton(
                systemName: "chevron.left",
                accessibilityLabel: "Close recipe picker",
                size: AppTopActionMetrics.buttonSize,
                backgroundColor: AppColors.elevatedCardBackground,
                foregroundColor: AppColors.darkOlive,
                action: { dismiss() }
            )

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(context.headline)
                    .font(AppTypography.heroTitle)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .accessibilityAddTraits(.isHeader)

                Text(context.subtitle)
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
    }

    private var searchField: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)

            TextField(
                "",
                text: $searchText,
                prompt: Text("Search recipes")
                    .foregroundStyle(AppColors.tertiaryText)
            )
            .font(AppTypography.callout)
            .foregroundStyle(AppColors.primaryText)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        }
        .padding(.horizontal, AppSpacing.sm)
        .frame(height: 36)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                .fill(AppColors.elevatedCardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                .stroke(AppColors.warmBorder, lineWidth: 1)
        )
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xs) {
                ForEach(PlannerRecipePickerFilter.allCases) { filter in
                    FilterChip(
                        filter.title,
                        systemImage: filter.systemImage,
                        isSelected: selectedFilter == filter,
                        selectedColor: filter.selectedColor
                    ) {
                        selectedFilter = filter
                    }
                }
            }
        }
        .scrollClipDisabled()
    }

    private var sortRow: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Recipes")
                .font(AppTypography.recipeTitle)
                .foregroundStyle(AppColors.primaryText)

            Spacer(minLength: AppSpacing.sm)

            Menu {
                ForEach(PlannerRecipePickerSort.allCases) { sort in
                    Button(sort.title) {
                        selectedSort = sort
                    }
                }
            } label: {
                HStack(spacing: AppSpacing.xxs) {
                    Text(selectedSort.title)
                    Image(systemName: "chevron.down")
                        .font(.caption2.weight(.semibold))
                }
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.secondaryText)
                .padding(.horizontal, AppSpacing.xs)
                .frame(height: 28)
                .background(
                    Capsule(style: .continuous)
                        .fill(AppColors.elevatedCardBackground)
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(AppColors.warmBorder, lineWidth: 1)
                )
            }
        }
        .padding(.top, AppSpacing.xs)
    }

    private var emptyState: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.md
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Image(systemName: "sparkles")
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.olive)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(AppColors.softOlive))

                Text("No recipes match these filters.")
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColors.primaryText)

                Text("Try a different filter or sort to find a better fit for \(context.mealType.title.lowercased()).")
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineSpacing(2)
            }
        }
    }

    private var visibleRecipes: [Recipe] {
        let searchedRecipes = searchText.isEmpty
            ? recipes
            : recipes.filter { matchesSearch($0) }

        let filteredRecipes = searchedRecipes.filter { selectedFilter.matches($0) }

        switch selectedSort {
        case .recommended:
            return filteredRecipes.sorted { lhs, rhs in
                recommendedScore(for: lhs) < recommendedScore(for: rhs)
            }
        case .quickest:
            return filteredRecipes.sorted {
                if $0.totalTimeMinutes == $1.totalTimeMinutes {
                    return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
                return $0.totalTimeMinutes < $1.totalTimeMinutes
            }
        case .highestProtein:
            return filteredRecipes.sorted {
                let lhs = $0.nutritionPerServing.proteinGrams
                let rhs = $1.nutritionPerServing.proteinGrams
                if lhs == rhs {
                    return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
                return lhs > rhs
            }
        case .lowestCalories:
            return filteredRecipes.sorted {
                let lhs = $0.nutritionPerServing.calories
                let rhs = $1.nutritionPerServing.calories
                if lhs == rhs {
                    return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
                return lhs < rhs
            }
        case .budgetFriendly:
            return filteredRecipes.sorted { lhs, rhs in
                let lhsScore = budgetScore(for: lhs)
                let rhsScore = budgetScore(for: rhs)
                if lhsScore == rhsScore {
                    return lhs.totalTimeMinutes < rhs.totalTimeMinutes
                }
                return lhsScore < rhsScore
            }
        case .mostPopular:
            return filteredRecipes
        case .newest:
            return filteredRecipes.sorted {
                let lhsDate = $0.updatedAt ?? $0.createdAt ?? .distantPast
                let rhsDate = $1.updatedAt ?? $1.createdAt ?? .distantPast
                if lhsDate == rhsDate {
                    return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
                return lhsDate > rhsDate
            }
        }
    }

    private func matchesSearch(_ recipe: Recipe) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return true
        }

        return recipe.title.localizedCaseInsensitiveContains(query)
            || recipe.subtitle.localizedCaseInsensitiveContains(query)
            || recipe.description.localizedCaseInsensitiveContains(query)
            || recipe.tags.contains { $0.localizedCaseInsensitiveContains(query) }
            || recipe.ingredients.contains { $0.localizedCaseInsensitiveContains(query) }
            || recipe.structuredIngredients.contains { ingredient in
                ingredient.name.localizedCaseInsensitiveContains(query)
                || ingredient.rawText?.localizedCaseInsensitiveContains(query) == true
            }
    }

    private func recommendedScore(for recipe: Recipe) -> Int {
        let mealAffinity = mealAffinityScore(for: recipe)
        let proteinBonus = recipe.nutritionPerServing.proteinGrams >= 28 ? -30 : 0
        let quickBonus = isQuick(recipe) ? -16 : 0
        let familyBonus = isFamilyFriendly(recipe) ? -8 : 0
        let budgetBonus = budgetScore(for: recipe) <= 1 ? -10 : 0
        let calorieBonus = recipe.nutritionPerServing.calories <= 500 ? -6 : 0

        return mealAffinity * 1_000 + proteinBonus + quickBonus + familyBonus + budgetBonus + calorieBonus
    }

    private func mealAffinityScore(for recipe: Recipe) -> Int {
        switch context.mealType {
        case .breakfast:
            if isBreakfast(recipe) { return 0 }
            if isSnack(recipe) || isQuick(recipe) { return 1 }
            return 2
        case .lunch:
            if isLunch(recipe) || isMealPrep(recipe) { return 0 }
            if isQuick(recipe) || isBudgetFriendly(recipe) { return 1 }
            return 2
        case .dinner:
            if isDinner(recipe) { return 0 }
            if isFamilyFriendly(recipe) || isHighProtein(recipe) { return 1 }
            return 2
        case .snack:
            if isSnack(recipe) { return 0 }
            if isQuick(recipe) || isBudgetFriendly(recipe) { return 1 }
            return 2
        }
    }

    private func budgetScore(for recipe: Recipe) -> Int {
        if containsTag(recipe, values: ["budget", "pantry", "affordable", "everyday", "simple", "weekly"]) {
            return 0
        }

        if isBudgetFriendly(recipe) {
            return 1
        }

        return 2
    }

    private func isBudgetFriendly(_ recipe: Recipe) -> Bool {
        recipe.category == .pantry
            || recipe.category == .soup
            || recipe.category == .salad
            || recipe.category == .toast
            || recipe.category == .breakfast
            || recipe.category == .grainBowl
            || recipe.category == .vegetarian
            || recipe.category == .beansLentils
            || recipe.totalTimeMinutes <= 30
    }

    private func isQuick(_ recipe: Recipe) -> Bool {
        containsTag(recipe, values: ["quick", "easy", "fast"])
            || recipe.totalTimeMinutes <= 30
    }

    private func isBreakfast(_ recipe: Recipe) -> Bool {
        containsTag(recipe, values: ["breakfast", "brunch", "morning"])
            || recipe.category == .breakfast
            || recipe.subcategoryTitle?.localizedCaseInsensitiveContains("breakfast") == true
            || recipe.title.localizedCaseInsensitiveContains("oat")
            || recipe.title.localizedCaseInsensitiveContains("toast")
    }

    private func isLunch(_ recipe: Recipe) -> Bool {
        containsTag(recipe, values: ["lunch", "mealprep", "meal-prep", "prep"])
            || recipe.category == .grainBowl
            || recipe.category == .salad
            || recipe.title.localizedCaseInsensitiveContains("bowl")
            || recipe.title.localizedCaseInsensitiveContains("salad")
            || recipe.title.localizedCaseInsensitiveContains("wrap")
    }

    private func isDinner(_ recipe: Recipe) -> Bool {
        containsTag(recipe, values: ["dinner", "weeknight", "familyfriendly", "hearty"])
            || recipe.category == .pasta
            || recipe.category == .curry
            || recipe.category == .chicken
            || recipe.category == .fish
            || recipe.category == .seafood
            || recipe.title.localizedCaseInsensitiveContains("curry")
            || recipe.title.localizedCaseInsensitiveContains("roast")
            || recipe.title.localizedCaseInsensitiveContains("skillet")
    }

    private func isSnack(_ recipe: Recipe) -> Bool {
        containsTag(recipe, values: ["snack", "bite", "dip", "spread", "smoothie"])
            || recipe.categoryGroupID == "snacks"
            || recipe.category == .toast
            || recipe.title.localizedCaseInsensitiveContains("bite")
            || recipe.title.localizedCaseInsensitiveContains("dip")
    }

    private func isMealPrep(_ recipe: Recipe) -> Bool {
        containsTag(recipe, values: ["mealprep", "meal-prep", "prep", "batch"])
            || recipe.title.localizedCaseInsensitiveContains("prep")
            || recipe.title.localizedCaseInsensitiveContains("bowl")
    }

    private func isFamilyFriendly(_ recipe: Recipe) -> Bool {
        containsTag(recipe, values: ["familyfriendly", "family-friendly", "kidfriendly"])
            || recipe.title.localizedCaseInsensitiveContains("family")
            || recipe.title.localizedCaseInsensitiveContains("crowd")
    }

    private func isHighProtein(_ recipe: Recipe) -> Bool {
        containsTag(recipe, values: ["highprotein", "high-protein", "protein"])
            || recipe.categoryGroupID == "high-protein"
            || recipe.category == .highProtein
            || recipe.category == .proteinBowls
            || recipe.category == .leanMeals
            || recipe.category == .fitnessMeals
    }

    private func containsTag(_ recipe: Recipe, values: Set<String>) -> Bool {
        let normalizedTags = recipe.tags.map {
            $0.lowercased().replacingOccurrences(of: " ", with: "")
        }

        return normalizedTags.contains { values.contains($0) }
    }
}

struct PlannerRecipeSelectionContext: Hashable {
    enum Mode: String, Hashable {
        case add
        case replace
    }

    let date: Date
    let dayLabel: String
    let mealType: MealSlot
    let slotID: String
    let mode: Mode

    var headline: String {
        mode == .add ? "Choose Recipe" : "Replace Recipe"
    }

    var subtitle: String {
        "For \(dayLabel) \(mealType.title)"
    }

    var actionTitle: String {
        switch mode {
        case .add:
            return "Add to \(dayLabel) \(mealType.title)"
        case .replace:
            return "Replace in \(dayLabel) \(mealType.title)"
        }
    }
}

private enum PlannerRecipePickerFilter: String, CaseIterable, Identifiable {
    case all
    case highProtein
    case vegetarian
    case carnivore
    case budget
    case quickMeals
    case lowCalorie
    case familyFriendly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .highProtein:
            return "High Protein"
        case .vegetarian:
            return "Vegetarian"
        case .carnivore:
            return "Carnivore"
        case .budget:
            return "Budget"
        case .quickMeals:
            return "Quick Meals"
        case .lowCalorie:
            return "Low Calorie"
        case .familyFriendly:
            return "Family Friendly"
        }
    }

    var systemImage: String? {
        switch self {
        case .all:
            return nil
        case .highProtein:
            return "bolt.fill"
        case .vegetarian:
            return "leaf.fill"
        case .carnivore:
            return "flame.fill"
        case .budget:
            return "banknote.fill"
        case .quickMeals:
            return "clock.fill"
        case .lowCalorie:
            return "leaf.circle.fill"
        case .familyFriendly:
            return "person.3.fill"
        }
    }

    var selectedColor: Color {
        switch self {
        case .all, .quickMeals:
            return AppColors.burntOrange
        case .highProtein, .familyFriendly:
            return AppColors.premiumGold
        case .vegetarian, .budget:
            return AppColors.olive
        case .carnivore, .lowCalorie:
            return AppColors.darkOlive
        }
    }

    func matches(_ recipe: Recipe) -> Bool {
        switch self {
        case .all:
            return true
        case .highProtein:
            return containsTag(recipe, values: ["highprotein", "high-protein", "protein"])
                || recipe.categoryGroupID == "high-protein"
                || recipe.category == .highProtein
                || recipe.category == .proteinBowls
                || recipe.category == .leanMeals
                || recipe.category == .fitnessMeals
        case .vegetarian:
            return containsTag(recipe, values: ["vegetarian", "vegan", "plantbased", "plant-based"])
                || recipe.categoryGroupID == "vegetarian"
                || recipe.category == .vegetarian
                || recipe.category == .tofuTempeh
                || recipe.category == .beansLentils
                || recipe.category == .mushrooms
        case .carnivore:
            return containsTag(recipe, values: ["carnivore", "meat", "seafood", "fish", "chicken", "protein"])
                || recipe.categoryGroupID == "meat-seafood"
                || recipe.category == .fish
                || recipe.category == .meat
                || recipe.category == .seafood
                || recipe.category == .chicken
                || recipe.category == .grilledChicken
                || recipe.category == .chickenBowls
                || recipe.category == .chickenPasta
        case .budget:
            return containsTag(recipe, values: ["budget", "pantry", "affordable", "everyday", "simple", "weekly"])
                || recipe.category == .pantry
                || recipe.category == .soup
                || recipe.category == .salad
                || recipe.category == .toast
                || recipe.category == .breakfast
                || recipe.category == .grainBowl
                || recipe.category == .vegetarian
                || recipe.category == .beansLentils
        case .quickMeals:
            return containsTag(recipe, values: ["quick", "fast", "easy"])
                || recipe.totalTimeMinutes <= 30
        case .lowCalorie:
            return recipe.nutritionPerServing.calories <= 500
                || containsTag(recipe, values: ["light", "fresh", "salad"])
        case .familyFriendly:
            return containsTag(recipe, values: ["familyfriendly", "family-friendly", "kidfriendly"])
                || recipe.title.localizedCaseInsensitiveContains("family")
                || recipe.title.localizedCaseInsensitiveContains("crowd")
        }
    }

    private func containsTag(_ recipe: Recipe, values: Set<String>) -> Bool {
        let normalizedTags = recipe.tags.map {
            $0.lowercased().replacingOccurrences(of: " ", with: "")
        }

        return normalizedTags.contains { values.contains($0) }
    }
}

private enum PlannerRecipePickerSort: String, CaseIterable, Identifiable {
    case recommended
    case quickest
    case highestProtein
    case lowestCalories
    case budgetFriendly
    case mostPopular
    case newest

    var id: String { rawValue }

    var title: String {
        switch self {
        case .recommended:
            return "Recommended"
        case .quickest:
            return "Quickest"
        case .highestProtein:
            return "Highest Protein"
        case .lowestCalories:
            return "Lowest Calories"
        case .budgetFriendly:
            return "Budget Friendly"
        case .mostPopular:
            return "Most Popular"
        case .newest:
            return "Newest"
        }
    }
}

#Preview {
    PlannerRecipePickerView(
        context: PlannerRecipeSelectionContext(
            date: Date(),
            dayLabel: "Monday",
            mealType: .lunch,
            slotID: MealSlot.lunch.id,
            mode: .add
        )
    )
    .environmentObject(FavoritesStore.shared)
}
