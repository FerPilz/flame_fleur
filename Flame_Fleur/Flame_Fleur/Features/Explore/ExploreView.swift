import SwiftUI

struct ExploreView: View {
    @Binding private var launchContext: ExploreLaunchContext?
    @EnvironmentObject private var favoritesStore: FavoritesStore
    @EnvironmentObject private var userRecipeStore: UserRecipeStore
    @EnvironmentObject private var shoppingCartStore: ShoppingCartStore
    @EnvironmentObject private var mealPlannerStore: MealPlannerStore

    @State private var searchText = ""
    @State private var selectedFilter: ExploreFilter = .all
    @State private var selectedSubcategoryID: String?
    @State private var isAddRecipeOptionsPresented = false
    @State private var isAddRecipePresented = false
    @State private var isImportRecipePresented = false
    @State private var pendingAddRecipeAction: AddRecipeAction?
    @State private var navigationPath: [ExploreRoute] = []

    @Binding private var plannerSelectionContext: PlannerRecipeSelectionContext?
    let onPlannerRecipeSelectionCancelled: () -> Void
    let onPlannerRecipeSelectionCompleted: () -> Void

    private let recipeRepository = RecipeRepository.shared
    private let categoryRepository = ExploreCategoryRepository.shared

    init(
        launchContext: Binding<ExploreLaunchContext?> = .constant(nil),
        plannerSelectionContext: Binding<PlannerRecipeSelectionContext?> = .constant(nil),
        onPlannerRecipeSelectionCancelled: @escaping () -> Void = {},
        onPlannerRecipeSelectionCompleted: @escaping () -> Void = {}
    ) {
        self._launchContext = launchContext
        self._plannerSelectionContext = plannerSelectionContext
        self.onPlannerRecipeSelectionCancelled = onPlannerRecipeSelectionCancelled
        self.onPlannerRecipeSelectionCompleted = onPlannerRecipeSelectionCompleted
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            AppScreen(
                contentSpacing: AppSpacing.md,
                headerTopPadding: AppSpacing.xs,
                contentBottomPadding: AppSpacing.xxxl + AppSpacing.xxl
            ) {
                AppHeader(
                    leadingActions: [
                        leadingHeaderAction
                    ],
                    trailingActions: [
                        AppHeaderAction(systemName: "cart", accessibilityLabel: "Shopping cart", badgeValue: shoppingCartStore.totalItemCount) {
                            navigationPath.append(.cart)
                        }
                    ]
                )
            } content: {
                titleBlock
                plannerSelectionBanner

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    searchBar
                    filterChips
                }

                if visibleCategoryGroups.isEmpty {
                    emptySearchState
                }

                ForEach(visibleCategoryGroups) { group in
                    categorySection(group)
                }

                myRecipesSection
            }
            .navigationDestination(for: ExploreRoute.self) { route in
                switch route {
                case .subcategory(let subcategoryID):
                    if let subcategory = categoryRepository.subcategory(id: subcategoryID) {
                        subcategoryRecipeList(subcategory)
                    } else {
                        EmptyView()
                    }
                case .recipe(let recipeID):
                    if recipeRepository.recipe(id: recipeID) != nil {
                        RecipeDetailView(
                            recipeID: recipeID,
                            onBack: {
                                if !navigationPath.isEmpty {
                                    navigationPath.removeLast()
                                }
                            },
                            onViewIngredients: {
                                navigationPath.append(.ingredients(recipeID))
                            },
                            plannerSelectionContext: plannerSelectionContext,
                            onAddToPlanner: plannerSelectionContext == nil ? nil : { recipe in
                                addRecipeToPlanner(recipe)
                            }
                        )
                    } else {
                        EmptyView()
                    }
                case .ingredients(let recipeID):
                    if recipeRepository.recipe(id: recipeID) != nil {
                        RecipeIngredientsView(
                            recipeID: recipeID,
                            onBack: {
                                if !navigationPath.isEmpty {
                                    navigationPath.removeLast()
                                }
                            }
                        )
                    } else {
                        EmptyView()
                    }
                case .cart:
                    ShoppingCartView(
                        onClose: {
                            if !navigationPath.isEmpty {
                                navigationPath.removeLast()
                            }
                        }
                    )
                case .profile:
                    ProfileView(onBack: {
                        if !navigationPath.isEmpty {
                            navigationPath.removeLast()
                        }
                    })
                case .settings:
                    SettingsView()
                }
            }
            .onAppear {
                consumeLaunchContextIfNeeded()
                applyPlannerSelectionContext(plannerSelectionContext)
            }
            .onChange(of: launchContext) { _, _ in
                consumeLaunchContextIfNeeded()
            }
            .onChange(of: plannerSelectionContext) { _, context in
                applyPlannerSelectionContext(context)
            }
            .sheet(isPresented: $isAddRecipePresented) {
                AddRecipeView()
            }
            .sheet(isPresented: $isImportRecipePresented) {
                RecipeImportURLView()
            }
            .sheet(isPresented: $isAddRecipeOptionsPresented, onDismiss: {
                switch pendingAddRecipeAction {
                case .manual:
                    isAddRecipePresented = true
                case .importWebsite:
                    isImportRecipePresented = true
                case .none:
                    break
                }

                pendingAddRecipeAction = nil
            }) {
                AddRecipeOptionsSheet(
                    onAddManually: {
                        pendingAddRecipeAction = .manual
                    },
                    onImportFromWebsite: {
                        pendingAddRecipeAction = .importWebsite
                    }
                )
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func consumeLaunchContextIfNeeded() {
        guard let launchContext else {
            return
        }

        applyLaunchContext(launchContext)
        self.launchContext = nil
    }

    private func applyLaunchContext(_ context: ExploreLaunchContext) {
        selectedSubcategoryID = nil
        navigationPath.removeAll()

        switch context {
        case .featured, .community, .topPicks, .aiRecommended, .worldCuisine, .snacks, .breakfast:
            selectedFilter = .all
            searchText = ""
        case .highProtein:
            selectedFilter = .highProtein
            searchText = ""
        case .eggBased:
            selectedFilter = .all
            searchText = ""
            selectedSubcategoryID = "breakfast-egg-based"
        case .salmon:
            selectedFilter = .carnivore
            searchText = "salmon"
        }
    }

    private var leadingHeaderAction: AppHeaderAction {
        if plannerSelectionContext != nil {
            AppHeaderAction(systemName: "xmark", accessibilityLabel: "Cancel planner recipe selection") {
                cancelPlannerRecipeSelection()
            }
        } else {
            AppHeaderAction(systemName: "line.3.horizontal", accessibilityLabel: "Open menu") {
                navigationPath.append(.settings)
            }
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .center, spacing: AppSpacing.xxs) {
            Text("The Cookbook")
                .font(AppTypography.screenTitle)
                .foregroundStyle(AppColors.olive)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .accessibilityAddTraits(.isHeader)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    private var plannerSelectionBanner: some View {
        if let plannerSelectionContext {
            SurfaceCard(
                backgroundColor: AppColors.softOlive,
                borderColor: AppColors.basilGreen.opacity(0.42),
                cornerRadius: AppRadius.large,
                contentPadding: AppSpacing.sm
            ) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "calendar.badge.plus")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.deepBasil)
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(AppColors.elevatedCardBackground.opacity(0.72)))

                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text(plannerSelectionContext.subtitle)
                            .font(AppTypography.bodyEmphasis)
                            .foregroundStyle(AppColors.darkOlive)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)

                        Text("Choose a recipe, then confirm from the recipe detail.")
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.secondaryText)
                            .lineLimit(2)
                    }
                }
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.tertiaryText)

            TextField(
                "",
                text: $searchText,
                prompt: Text("Search by recipe title or ingredients")
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
                ForEach(ExploreFilter.allCases) { filter in
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
    }

    private var myRecipesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeaderView(
                "My Recipes",
                subtitle: myRecipesSectionSubtitle,
                style: .explore
            )

            if userRecipeStore.myRecipes.isEmpty {
                myRecipesEmptyState
            } else if visibleMyRecipes.isEmpty {
                SurfaceCard(cornerRadius: AppRadius.large, contentPadding: AppSpacing.sm) {
                    Text("No saved recipes match this search.")
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.secondaryText)
                }
            } else {
                VStack(spacing: AppSpacing.xs) {
                    ForEach(visibleMyRecipes) { recipe in
                        RecipeListRow(
                            recipe: recipe,
                            isFavorite: favoritesStore.isFavorite(recipe.id),
                            onFavoriteTap: {
                                favoritesStore.toggleFavorite(recipe.id)
                            },
                            onTap: {
                                navigationPath.append(.recipe(recipe.id))
                            }
                        )
                    }
                }
            }
        }
    }

    private var myRecipesEmptyState: some View {
        LazyVGrid(columns: categoryColumns, spacing: AppSpacing.sm) {
            ForEach(0..<3, id: \.self) { _ in
                addRecipeCircleButton
            }
        }
    }

    private var addRecipeCircleButton: some View {
        Button {
            isAddRecipeOptionsPresented = true
        } label: {
            VStack(spacing: AppSpacing.xxs) {
                ZStack {
                    Circle()
                        .fill(AppColors.elevatedCardBackground)
                        .frame(width: 95, height: 95)
                        .overlay(
                            Circle()
                                .stroke(AppColors.warmBorder, lineWidth: 1)
                        )

                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(AppColors.olive)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Add recipe"))
    }

    private func categorySection(_ group: ExploreCategoryGroup) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xl) {
            SectionHeaderView(group.title, style: .explore)

            LazyVGrid(columns: categoryColumns, spacing: AppSpacing.xl) {
                ForEach(bubbleItems(for: group)) { bubble in
                    CategoryCircleCard(
                        title: bubble.title,
                        imageName: bubble.imageName,
                        diameter: ExploreLayoutMetrics.categoryCircleDiameter,
                        titleFont: AppTypography.exploreCategoryCircleLabel,
                        isSelected: bubble.isSelectable && bubble.selectionID == selectedSubcategoryID
                    ) {
                        handleBubbleTap(bubble)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func subcategoryRecipeList(_ subcategory: ExploreSubcategory) -> some View {
        SubcategoryRecipeListView(subcategory: subcategory) { recipeID in
            navigationPath.append(.recipe(recipeID))
        } onCartSelected: {
            navigationPath.append(.cart)
        } onProfileSelected: {
            navigationPath.append(.profile)
        } onSettingsSelected: {
            navigationPath.append(.settings)
        }
    }

    private var emptySearchState: some View {
        SurfaceCard(cornerRadius: AppRadius.large, contentPadding: AppSpacing.sm) {
            Text("No categories match this search yet.")
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.secondaryText)
        }
    }

    private var categoryColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: AppSpacing.sm), count: 3)
    }

    private var myRecipesSectionSubtitle: String {
        let count = userRecipeStore.myRecipes.count
        return count == 1 ? "1 saved recipe" : "\(count) saved recipes"
    }

    private var visibleMyRecipes: [Recipe] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let recipes = userRecipeStore.myRecipes

        guard !trimmedSearch.isEmpty else {
            return recipes
        }

        return recipes.filter { recipe in
            recipe.title.localizedCaseInsensitiveContains(trimmedSearch)
            || recipe.subtitle.localizedCaseInsensitiveContains(trimmedSearch)
            || recipe.sourceHost?.localizedCaseInsensitiveContains(trimmedSearch) == true
            || recipe.ingredientLines.contains { $0.localizedCaseInsensitiveContains(trimmedSearch) }
        }
    }

    private var visibleCategoryGroups: [ExploreCategoryGroup] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        return categoryRepository.allGroups.compactMap { group in
            let searchMatchedSubcategories = group.subcategories.filter { subcategory in
                matchesSearch(subcategory, group: group, searchText: trimmedSearch)
            }

            guard !searchMatchedSubcategories.isEmpty else {
                return nil
            }

            let visibleSubcategories: [ExploreSubcategory]
            if selectedFilter == .all {
                visibleSubcategories = searchMatchedSubcategories
            } else {
                visibleSubcategories = searchMatchedSubcategories.filter { subcategory in
                    selectedFilter.matches(subcategory)
                }
            }

            guard !visibleSubcategories.isEmpty else {
                return nil
            }

            return ExploreCategoryGroup(
                id: group.id,
                title: group.title,
                subtitle: group.subtitle,
                imageName: group.imageName,
                bubbleDisplayMode: group.bubbleDisplayMode,
                subcategories: visibleSubcategories
            )
        }
    }

    private func matchesSearch(_ subcategory: ExploreSubcategory, group: ExploreCategoryGroup, searchText: String) -> Bool {
        guard !searchText.isEmpty else {
            return true
        }

        if group.title.localizedCaseInsensitiveContains(searchText)
            || group.subtitle.localizedCaseInsensitiveContains(searchText)
            || subcategory.title.localizedCaseInsensitiveContains(searchText)
            || subcategory.category?.title.localizedCaseInsensitiveContains(searchText) == true {
            return true
        }

        guard let category = subcategory.category else {
            return false
        }

        return recipeRepository.recipes(for: category).contains { recipe in
            recipe.title.localizedCaseInsensitiveContains(searchText)
            || recipe.subtitle.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func bubbleItems(for group: ExploreCategoryGroup) -> [ExploreBubbleItem] {
        group.subcategories.map { subcategory in
            ExploreBubbleItem(
                id: subcategory.id,
                title: subcategory.title,
                imageName: subcategory.imageName,
                selectionID: subcategory.id,
                isSelectable: true,
                destination: .subcategory(subcategory)
            )
        }
    }

    private func handleBubbleTap(_ bubble: ExploreBubbleItem) {
        switch bubble.destination {
        case .subcategory(let subcategory):
            selectedSubcategoryID = subcategory.id
            navigationPath.append(.subcategory(subcategory.id))
        }
    }

    private func applyPlannerSelectionContext(_ context: PlannerRecipeSelectionContext?) {
        guard context != nil else {
            return
        }

        selectedSubcategoryID = nil
        selectedFilter = .all
        searchText = ""
        navigationPath.removeAll()
    }

    private func addRecipeToPlanner(_ recipe: Recipe) {
        guard let plannerSelectionContext else {
            return
        }

        let didAdd = mealPlannerStore.addRecipeToPlannerSlot(
            recipeID: recipe.id,
            date: plannerSelectionContext.date,
            mealType: plannerSelectionContext.mealType,
            slotID: plannerSelectionContext.slotID,
            mode: plannerSelectionContext.mode
        )

        guard didAdd else {
            return
        }

        self.plannerSelectionContext = nil
        navigationPath.removeAll()
        onPlannerRecipeSelectionCompleted()
    }

    private func cancelPlannerRecipeSelection() {
        plannerSelectionContext = nil
        navigationPath.removeAll()
        onPlannerRecipeSelectionCancelled()
    }
}

private struct ExploreBubbleItem: Identifiable {
    let id: String
    let title: String
    let imageName: String?
    let selectionID: String?
    let isSelectable: Bool
    let destination: ExploreBubbleDestination
}

private enum ExploreBubbleDestination {
    case subcategory(ExploreSubcategory)
}

private enum AddRecipeAction {
    case manual
    case importWebsite
}

private enum ExploreLayoutMetrics {
    static let categoryCircleDiameter: CGFloat = 112.2
}

private enum ExploreRoute: Hashable {
    case subcategory(String)
    case recipe(String)
    case ingredients(String)
    case cart
    case profile
    case settings
}

private enum ExploreFilter: String, CaseIterable, Identifiable {
    case all
    case protein
    case vegetarian
    case highProtein
    case budget
    case carnivore
    case quickMeals

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .protein:
            return "Protein"
        case .vegetarian:
            return "Vegetarian"
        case .highProtein:
            return "High Protein"
        case .budget:
            return "Budget"
        case .carnivore:
            return "Carnivore"
        case .quickMeals:
            return "Quick Meals"
        }
    }

    var systemImage: String? {
        switch self {
        case .all:
            return nil
        case .protein:
            return "fork.knife"
        case .vegetarian:
            return "leaf"
        case .highProtein:
            return "bolt.fill"
        case .budget:
            return "dollarsign.circle"
        case .carnivore:
            return "flame"
        case .quickMeals:
            return "clock"
        }
    }

    var selectedColor: Color {
        switch self {
        case .all, .protein, .quickMeals:
            return AppColors.burntOrange
        case .vegetarian, .budget:
            return AppColors.olive
        case .highProtein:
            return AppColors.premiumGold
        case .carnivore:
            return AppColors.darkOlive
        }
    }

    func matches(_ subcategory: ExploreSubcategory) -> Bool {
        switch self {
        case .all:
            return true
        case .protein:
            return matches(subcategory, categories: proteinCategories, keywords: ["protein", "chicken", "fish", "seafood", "lean", "egg", "yogurt"])
        case .vegetarian:
            return matches(subcategory, categories: vegetarianCategories, keywords: ["tofu", "tempeh", "beans", "lentils", "mushroom", "vegetable", "plant"])
        case .highProtein:
            return matches(subcategory, categories: highProteinCategories, keywords: ["protein", "yogurt", "egg", "lean", "fitness", "seafood"])
        case .budget:
            return matches(subcategory, categories: budgetCategories, keywords: ["budget", "pantry", "quick", "simple", "everyday", "weekly"])
        case .carnivore:
            return matches(subcategory, categories: carnivoreCategories, keywords: ["meat", "seafood", "fish", "chicken", "grill"])
        case .quickMeals:
            return matches(subcategory, categories: quickMealCategories, keywords: ["bowl", "taco", "salad", "skewer", "protein"])
        }
    }

    private func matches(_ subcategory: ExploreSubcategory, categories: Set<RecipeCategory>, keywords: [String]) -> Bool {
        if let category = subcategory.category, categories.contains(category) {
            return true
        }

        return keywords.contains { subcategory.title.localizedCaseInsensitiveContains($0) }
    }

    private var proteinCategories: Set<RecipeCategory> {
        [
            .fish,
            .meat,
            .seafood,
            .chicken,
            .grilledChicken,
            .chickenBowls,
            .chickenPasta,
            .highProtein,
            .proteinBowls,
            .leanMeals,
            .fitnessMeals,
            .beansLentils
        ]
    }

    private var vegetarianCategories: Set<RecipeCategory> {
        [
            .tofuTempeh,
            .beansLentils,
            .mushrooms,
            .vegetarian,
            .salad,
            .grainBowl
        ]
    }

    private var highProteinCategories: Set<RecipeCategory> {
        [
            .highProtein,
            .proteinBowls,
            .leanMeals,
            .fitnessMeals,
            .fish,
            .seafood,
            .chicken,
            .grilledChicken
        ]
    }

    private var budgetCategories: Set<RecipeCategory> {
        [
            .pantry,
            .soup,
            .salad,
            .toast,
            .breakfast,
            .grainBowl,
            .vegetarian,
            .beansLentils
        ]
    }

    private var carnivoreCategories: Set<RecipeCategory> {
        [
            .meat,
            .seafood,
            .fish,
            .chicken,
            .grilledChicken,
            .chickenBowls,
            .chickenPasta
        ]
    }

    private var quickMealCategories: Set<RecipeCategory> {
        [
            .fish,
            .seafood,
            .tofuTempeh,
            .beansLentils,
            .chicken,
            .grilledChicken,
            .chickenBowls,
            .chickenPasta,
            .highProtein,
            .proteinBowls,
            .leanMeals,
            .fitnessMeals
        ]
    }
}

#Preview {
    ExploreView()
        .environmentObject(FavoritesStore.shared)
        .environmentObject(UserRecipeStore.shared)
        .environmentObject(ShoppingCartStore.shared)
        .environmentObject(MealPlannerStore.shared)
}
