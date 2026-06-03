import SwiftUI

struct SubcategoryRecipeListView: View {
    let subcategory: ExploreSubcategory

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedFilter: RecipeListFilter = .all
    @State private var selectedSort: RecipeListSort = .popular
    @State private var favoriteRecipeIDs: Set<Recipe.ID> = []

    private let recipeRepository = RecipeRepository.shared

    var body: some View {
        AppScreen(
            contentSpacing: AppSpacing.sm,
            headerTopPadding: AppSpacing.xs,
            contentBottomPadding: AppSpacing.xxxl + AppSpacing.xxl
        ) {
            AppHeader(
                leadingActions: [
                    AppHeaderAction(systemName: "chevron.left", accessibilityLabel: "Back") {
                        dismiss()
                    }
                ],
                trailingActions: [
                    AppHeaderAction(systemName: "cart", accessibilityLabel: "Shopping cart", badgeValue: 1),
                    AppHeaderAction(systemName: "person.crop.circle", accessibilityLabel: "Open profile")
                ]
            )
        } content: {
            titleBlock
            searchBar
            filterChips
            recipeListHeader

            if visibleRecipes.isEmpty {
                emptyState
            } else {
                VStack(spacing: AppSpacing.xs) {
                    ForEach(visibleRecipes) { recipe in
                        RecipeListRow(
                            recipe: recipe,
                            isFavorite: favoriteRecipeIDs.contains(recipe.id),
                            onFavoriteTap: {
                                toggleFavorite(recipe)
                            },
                            onTap: {}
                        )
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text(subcategory.title)
                .font(AppTypography.heroTitle)
                .foregroundStyle(AppColors.olive)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .accessibilityAddTraits(.isHeader)

            Text("\(baseRecipes.count) curated recipes")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var searchBar: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.tertiaryText)

            TextField(
                "",
                text: $searchText,
                prompt: Text("Search \(subcategory.title.lowercased()) recipes")
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
                ForEach(RecipeListFilter.allCases) { filter in
                    FilterChip(
                        filter.title,
                        systemImage: filter.systemImage,
                        isSelected: selectedFilter == filter
                    ) {
                        selectedFilter = filter
                    }
                }
            }
        }
    }

    private var recipeListHeader: some View {
        HStack(alignment: .center) {
            Text("All Recipes")
                .font(AppTypography.recipeTitle)
                .foregroundStyle(AppColors.primaryText)

            Spacer(minLength: AppSpacing.sm)

            Menu {
                ForEach(RecipeListSort.allCases) { sort in
                    Button(sort.title) {
                        selectedSort = sort
                    }
                }
            } label: {
                HStack(spacing: AppSpacing.xxs) {
                    Text("Sort: \(selectedSort.title)")
                    Image(systemName: "chevron.down")
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
        SurfaceCard(cornerRadius: AppRadius.large, contentPadding: AppSpacing.sm) {
            Text("No recipes match this search yet.")
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.secondaryText)
        }
    }

    private var baseRecipes: [Recipe] {
        recipeRepository.recipes(forSubcategory: subcategory)
    }

    private var visibleRecipes: [Recipe] {
        let searchedRecipes = recipeRepository.recipes(for: subcategory, searchText: searchText)
        let filteredRecipes = searchedRecipes.filter { selectedFilter.matches($0, subcategory: subcategory) }

        switch selectedSort {
        case .popular:
            return filteredRecipes
        case .fastest:
            return filteredRecipes.sorted { $0.cookingTimeMinutes < $1.cookingTimeMinutes }
        case .lowestCalories:
            return filteredRecipes.sorted { $0.calories < $1.calories }
        }
    }

    private func toggleFavorite(_ recipe: Recipe) {
        if favoriteRecipeIDs.contains(recipe.id) {
            favoriteRecipeIDs.remove(recipe.id)
        } else {
            favoriteRecipeIDs.insert(recipe.id)
        }
    }
}

private enum RecipeListFilter: String, CaseIterable, Identifiable {
    case all
    case under30
    case easy
    case highProtein
    case lowCarb

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .under30:
            return "Under 30 min"
        case .easy:
            return "Easy"
        case .highProtein:
            return "High Protein"
        case .lowCarb:
            return "Low Carb"
        }
    }

    var systemImage: String? {
        switch self {
        case .all:
            return nil
        case .under30:
            return "clock"
        case .easy:
            return "sparkles"
        case .highProtein:
            return "fork.knife"
        case .lowCarb:
            return "leaf"
        }
    }

    func matches(_ recipe: Recipe, subcategory: ExploreSubcategory) -> Bool {
        switch self {
        case .all:
            return true
        case .under30:
            return recipe.cookingTimeMinutes <= 30
        case .easy:
            return recipe.difficulty == .easy
        case .highProtein:
            return recipe.tags.contains("highProtein")
                || recipe.categoryGroupID == "high-protein"
                || subcategory.parentGroupID == "high-protein"
        case .lowCarb:
            return recipe.tags.contains("lowCarb")
        }
    }
}

private enum RecipeListSort: String, CaseIterable, Identifiable {
    case popular
    case fastest
    case lowestCalories

    var id: String { rawValue }

    var title: String {
        switch self {
        case .popular:
            return "Popular"
        case .fastest:
            return "Fastest"
        case .lowestCalories:
            return "Lowest Calories"
        }
    }
}

#Preview {
    SubcategoryRecipeListView(
        subcategory: ExploreCategoryRepository.shared.subcategory(id: "meat-seafood-fish")!
    )
}
