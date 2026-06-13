import SwiftUI

struct ExploreView: View {
    @State private var searchText = ""
    @State private var selectedFilter: ExploreFilter = .all
    @State private var selectedSubcategoryID: String?
    @State private var selectedQuickAction: ExploreQuickAction?
    @State private var navigationPath: [ExploreRoute] = []

    private let recipeRepository = RecipeRepository.shared
    private let categoryRepository = ExploreCategoryRepository.shared

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
                        AppHeaderAction(systemName: "cart", accessibilityLabel: "Shopping cart", badgeValue: 1) {
                            navigationPath.append(.cart)
                        },
                        AppHeaderAction(systemName: "person.crop.circle", accessibilityLabel: "Open profile settings") {
                            navigationPath.append(.settings)
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
                    } onSettingsSelected: {
                        navigationPath.append(.settings)
                    }
                case .subcategory(let subcategoryID):
                    if let subcategory = categoryRepository.subcategory(id: subcategoryID) {
                        SubcategoryRecipeListView(subcategory: subcategory) { recipeID in
                            navigationPath.append(.recipe(recipeID))
                        } onCartSelected: {
                            navigationPath.append(.cart)
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
                case .settings:
                    SettingsView()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
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
        HStack(spacing: AppSpacing.xs) {
            ForEach(ExploreFilter.allCases) { filter in
                FilterChip(
                    filter.title,
                    isSelected: selectedFilter == filter
                ) {
                    selectedFilter = filter
                }
            }
        }
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

    private var visibleCategoryGroups: [ExploreCategoryGroup] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        return categoryRepository.allGroups.compactMap { group in
            let subcategories = group.subcategories.filter { subcategory in
                selectedFilter.matches(subcategory)
                && matchesSearch(subcategory, group: group, searchText: trimmedSearch)
            }

            guard !subcategories.isEmpty else {
                return nil
            }

            return ExploreCategoryGroup(
                id: group.id,
                title: group.title,
                subtitle: group.subtitle,
                imageName: group.imageName,
                subcategories: shouldShowPreviewOnly(searchText: trimmedSearch) ? Array(subcategories.prefix(3)) : subcategories
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

private enum ExploreRoute: Hashable {
    case categoryGroup(String)
    case subcategory(String)
    case recipe(String)
    case ingredients(String)
    case cart
    case settings
}

private enum ExploreFilter: String, CaseIterable, Identifiable {
    case all
    case protein
    case vegetarian
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
        case .quickMeals:
            return "Quick Meals"
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
}
