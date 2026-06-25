import SwiftUI

struct ExploreView: View {
    @Binding private var launchContext: ExploreLaunchContext?
    @EnvironmentObject private var favoritesStore: FavoritesStore
    @EnvironmentObject private var userRecipeStore: UserRecipeStore
    @EnvironmentObject private var shoppingCartStore: ShoppingCartStore

    @State private var searchText = ""
    @State private var selectedFilter: ExploreFilter = .all
    @State private var selectedSubcategoryID: String?
    @State private var selectedQuickAction: ExploreQuickAction?
    @State private var isAddRecipeOptionsPresented = false
    @State private var isAddRecipePresented = false
    @State private var isImportRecipePresented = false
    @State private var pendingAddRecipeAction: AddRecipeAction?
    @State private var navigationPath: [ExploreRoute] = []

    private let recipeRepository = RecipeRepository.shared
    private let categoryRepository = ExploreCategoryRepository.shared

    init(launchContext: Binding<ExploreLaunchContext?> = .constant(nil)) {
        self._launchContext = launchContext
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
                        AppHeaderAction(systemName: "line.3.horizontal", accessibilityLabel: "Open menu") {
                            navigationPath.append(.settings)
                        }
                    ],
                    trailingActions: [
                        AppHeaderAction(systemName: "cart", accessibilityLabel: "Shopping cart", badgeValue: shoppingCartStore.totalItemCount) {
                            navigationPath.append(.cart)
                        },
                        AppHeaderAction(systemName: "person.crop.circle", accessibilityLabel: "Open profile") {
                            navigationPath.append(.profile)
                        }
                    ]
                )
            } content: {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    searchBar
                    quickActions
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
                case .categoryGroup(let groupID):
                    ExploreCategoryOptionsView(
                        group: categoryRepository.group(id: groupID) ?? categoryRepository.allGroups[0]
                    ) { subcategory in
                        navigationPath.append(.subcategory(subcategory.id))
                    } onCartSelected: {
                        navigationPath.append(.cart)
                    } onProfileSelected: {
                        navigationPath.append(.profile)
                    } onSettingsSelected: {
                        navigationPath.append(.settings)
                    }
                case .subcategory(let subcategoryID):
                    if let subcategory = categoryRepository.subcategory(id: subcategoryID) {
                        SubcategoryRecipeListView(subcategory: subcategory) { recipeID in
                            navigationPath.append(.recipe(recipeID))
                        } onCartSelected: {
                            navigationPath.append(.cart)
                        } onProfileSelected: {
                            navigationPath.append(.profile)
                        } onSettingsSelected: {
                            navigationPath.append(.settings)
                        }
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
            }
            .onChange(of: launchContext) { _, _ in
                consumeLaunchContextIfNeeded()
            }
            .sheet(isPresented: $isAddRecipePresented, onDismiss: {
                selectedQuickAction = nil
            }) {
                AddRecipeView()
            }
            .sheet(isPresented: $isImportRecipePresented, onDismiss: {
                selectedQuickAction = nil
            }) {
                RecipeImportURLView()
            }
            .sheet(isPresented: $isAddRecipeOptionsPresented, onDismiss: {
                selectedQuickAction = nil

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
        selectedQuickAction = nil
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

    private var quickActions: some View {
        HStack(spacing: AppSpacing.xs) {
            quickActionButton(.importRecipe)
            quickActionButton(.addRecipe)
        }
    }

    private func quickActionButton(_ quickAction: ExploreQuickAction) -> some View {
        Button {
            selectedQuickAction = quickAction
            switch quickAction {
            case .addRecipe:
                isAddRecipeOptionsPresented = true
            case .importRecipe:
                isImportRecipePresented = true
            }
        } label: {
            HStack(spacing: AppSpacing.xxs) {
                Image(systemName: quickAction.systemImage)
                    .font(AppTypography.tabLabel)

                Text(quickAction.title)
                    .font(AppTypography.smallButton)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .foregroundStyle(AppColors.olive)
            .frame(maxWidth: .infinity, minHeight: 30)
            .padding(.horizontal, AppSpacing.xs)
            .background(
                Capsule(style: .continuous)
                    .fill(selectedQuickAction == quickAction ? AppColors.softOlive : AppColors.elevatedCardBackground)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(AppColors.warmBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
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
            SectionHeaderView(group.title, actionTitle: "See all", style: .explore) {
                navigationPath.append(.categoryGroup(group.id))
            }

            LazyVGrid(columns: categoryColumns, spacing: AppSpacing.xl) {
                ForEach(group.subcategories) { subcategory in
                    CategoryCircleCard(
                        title: subcategory.title,
                        imageName: subcategory.imageName,
                        isSelected: selectedSubcategoryID == subcategory.id
                    ) {
                        selectedSubcategoryID = subcategory.id
                        navigationPath.append(.subcategory(subcategory.id))
                    }
                }
            }
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

            let filteredSubcategories = searchMatchedSubcategories.filter { subcategory in
                selectedFilter.matches(subcategory)
            }
            let previewSubcategories = filteredSubcategories.isEmpty
                ? searchMatchedSubcategories
                : filteredSubcategories

            return ExploreCategoryGroup(
                id: group.id,
                title: group.title,
                subtitle: group.subtitle,
                imageName: group.imageName,
                subcategories: shouldShowPreviewOnly(searchText: trimmedSearch)
                    ? Array(previewSubcategories.prefix(3))
                    : previewSubcategories
            )
        }
    }

    private func shouldShowPreviewOnly(searchText: String) -> Bool {
        searchText.isEmpty && selectedFilter == .all
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
}

private enum ExploreQuickAction: Equatable {
    case importRecipe
    case addRecipe

    var title: String {
        switch self {
        case .importRecipe:
            return "Import Recipe"
        case .addRecipe:
            return "Add Recipe"
        }
    }

    var systemImage: String {
        switch self {
        case .importRecipe:
            return "square.and.arrow.down"
        case .addRecipe:
            return "plus"
        }
    }
}

private enum AddRecipeAction {
    case manual
    case importWebsite
}

private enum ExploreRoute: Hashable {
    case categoryGroup(String)
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
            return matches(subcategory, categories: carnivoreCategories, keywords: ["meat", "seafood", "fish", "chicken", "protein", "grill"])
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
            .breakfast,
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
}
