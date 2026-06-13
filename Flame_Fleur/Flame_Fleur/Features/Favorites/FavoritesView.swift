import SwiftUI

struct FavoritesView: View {
    let onBack: (() -> Void)?

    @EnvironmentObject private var favoritesStore: FavoritesStore
    @Environment(\.dismiss) private var dismiss

    @State private var navigationPath: [FavoritesRoute] = []
    @State private var selectedFilter: FavoritesFilter = .all
    @State private var toastMessage: String?

    private let recipeRepository = RecipeRepository.shared

    init(onBack: (() -> Void)? = nil) {
        self.onBack = onBack
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .bottom) {
                AppScreen(
                    contentSpacing: AppSpacing.sm,
                    headerTopPadding: AppSpacing.xs,
                    contentBottomPadding: AppSpacing.xxxl + AppSpacing.xxl
                ) {
                    AppHeader(
                        leadingActions: [
                            AppHeaderAction(systemName: "chevron.left", accessibilityLabel: "Back") {
                                goBack()
                            }
                        ]
                    )
                } content: {
                    titleBlock
                    filterCarousel
                    favoritesListHeader

                    if visibleRecipes.isEmpty {
                        emptyState
                    } else {
                        VStack(spacing: AppSpacing.xs) {
                            ForEach(visibleRecipes) { recipe in
                                RecipeListRow(
                                    recipe: recipe,
                                    isFavorite: true,
                                    communityLikesText: likesText(for: recipe),
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

                if let toastMessage {
                    Text(toastMessage)
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.elevatedCardBackground)
                        .padding(.horizontal, AppSpacing.md)
                        .frame(height: 34)
                        .background(Capsule(style: .continuous).fill(AppColors.darkOlive))
                        .padding(.bottom, AppSpacing.lg)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationDestination(for: FavoritesRoute.self) { route in
                switch route {
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
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text("Favorites")
                .font(AppTypography.heroTitle)
                .foregroundStyle(AppColors.olive)
                .lineLimit(1)
                .accessibilityAddTraits(.isHeader)

            Text("Your saved dishes")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var filterCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xs) {
                ForEach(FavoritesFilter.allCases) { filter in
                    FilterChip(
                        filter.title,
                        systemImage: filter.systemImage,
                        isSelected: selectedFilter == filter,
                        selectedColor: AppColors.olive
                    ) {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.vertical, 1)
        }
        .scrollClipDisabled()
    }

    private var favoritesListHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(selectedFilter.headerTitle)
                .font(AppTypography.recipeTitle)
                .foregroundStyle(AppColors.primaryText)

            Spacer()

            Text("\(visibleRecipes.count) saved")
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.secondaryText)
        }
        .padding(.top, AppSpacing.xs)
    }

    private var emptyState: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.md
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Image(systemName: "heart")
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.olive)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(AppColors.softOlive))

                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(favoriteRecipes.isEmpty ? "No favorites here yet" : "No saved recipes match this filter.")
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColors.primaryText)

                    Text("Save recipes from Home or Explore, then refine them here by mood, speed, or style.")
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.secondaryText)
                        .lineSpacing(2)
                }

                Button {
                    showToast("Open the Explore tab to browse recipes")
                } label: {
                    Text("Explore recipes")
                        .font(AppTypography.smallButton)
                        .foregroundStyle(AppColors.olive)
                        .padding(.horizontal, AppSpacing.sm)
                        .frame(height: 32)
                        .background(Capsule(style: .continuous).fill(AppColors.softOlive))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var favoriteRecipes: [Recipe] {
        favoritesStore.favoriteRecipeIDs.compactMap { recipeRepository.recipe(id: $0) }
    }

    private var visibleRecipes: [Recipe] {
        let filteredRecipes = favoriteRecipes.filter { selectedFilter.matches($0) }

        switch selectedFilter {
        case .recentlyAdded:
            return filteredRecipes.sorted { lhs, rhs in
                let lhsDate = favoritesStore.favoriteDate(for: lhs.id) ?? .distantPast
                let rhsDate = favoritesStore.favoriteDate(for: rhs.id) ?? .distantPast
                return lhsDate > rhsDate
            }
        case .mostLiked:
            return filteredRecipes.sorted { communityLikes(for: $0) > communityLikes(for: $1) }
        default:
            return filteredRecipes
        }
    }

    private func communityLikes(for recipe: Recipe) -> Int {
        let seed = recipe.id.unicodeScalars.reduce(0) { partialResult, scalar in
            (partialResult * 31 + Int(scalar.value)) % 10_000
        }
        let sectionBoost = recipe.sectionTags.contains(.community) ? 850 : 0
        let creatorBoost = recipe.creatorName == nil ? 0 : 350

        return 180 + seed % 3_700 + sectionBoost + creatorBoost
    }

    private func likesText(for recipe: Recipe) -> String {
        let count = communityLikes(for: recipe)

        guard count >= 1_000 else {
            return "\(count)"
        }

        return String(format: "%.1fk", Double(count) / 1_000)
    }

    private func showToast(_ message: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            toastMessage = message
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            if toastMessage == message {
                withAnimation(.easeInOut(duration: 0.2)) {
                    toastMessage = nil
                }
            }
        }
    }

    private func goBack() {
        if let onBack {
            onBack()
        } else {
            dismiss()
        }
    }
}

private enum FavoritesFilter: String, CaseIterable, Identifiable {
    case all
    case quickMeals
    case highProtein
    case worldCuisine
    case vegetarian
    case community
    case recentlyAdded
    case mostLiked

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .quickMeals:
            return "Quick Meals"
        case .highProtein:
            return "High Protein"
        case .worldCuisine:
            return "World Cuisine"
        case .vegetarian:
            return "Vegetarian"
        case .community:
            return "Community"
        case .recentlyAdded:
            return "Recently Added"
        case .mostLiked:
            return "Most Liked"
        }
    }

    var headerTitle: String {
        switch self {
        case .all:
            return "Saved Recipes"
        default:
            return title
        }
    }

    var systemImage: String? {
        switch self {
        case .all:
            return nil
        case .quickMeals:
            return "clock"
        case .highProtein:
            return "fork.knife"
        case .worldCuisine:
            return "globe.europe.africa"
        case .vegetarian:
            return "leaf"
        case .community:
            return "person.2"
        case .recentlyAdded:
            return "calendar"
        case .mostLiked:
            return "heart"
        }
    }

    func matches(_ recipe: Recipe) -> Bool {
        switch self {
        case .all, .recentlyAdded, .mostLiked:
            return true
        case .quickMeals:
            return recipe.cookingTimeMinutes <= 30
                || recipe.totalTimeMinutes <= 30
                || containsTag(recipe, values: ["quick", "easy"])
        case .highProtein:
            return containsTag(recipe, values: ["highprotein", "high-protein"])
                || recipe.categoryGroupID == "high-protein"
                || recipe.category == .highProtein
                || recipe.category == .proteinBowls
                || recipe.category == .leanMeals
                || recipe.category == .fitnessMeals
        case .worldCuisine:
            return recipe.categoryGroupID == "world-cuisine"
                || recipe.subcategoryID?.contains("world-cuisine") == true
                || recipe.category == .italian
                || recipe.category == .mexican
                || recipe.category == .korean
                || recipe.category == .curry
        case .vegetarian:
            return containsTag(recipe, values: ["vegetarian", "vegan"])
                || recipe.categoryGroupID == "vegetarian"
                || recipe.category == .vegetarian
                || recipe.category == .tofuTempeh
                || recipe.category == .beansLentils
                || recipe.category == .mushrooms
                || recipe.category == .salad
        case .community:
            return recipe.isCommunityRecipe
                || recipe.sectionTags.contains(.community)
                || recipe.creatorName != nil
                || containsTag(recipe, values: ["community"])
        }
    }

    private func containsTag(_ recipe: Recipe, values: Set<String>) -> Bool {
        let normalizedTags = recipe.tags.map {
            $0.lowercased().replacingOccurrences(of: " ", with: "")
        }

        return normalizedTags.contains { values.contains($0) }
    }
}

private enum FavoritesRoute: Hashable {
    case recipe(String)
    case ingredients(String)
}

#Preview {
    FavoritesView()
        .environmentObject(FavoritesStore.shared)
}
