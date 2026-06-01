import SwiftUI

struct HomeView: View {
    private enum SectionID {
        static let featured = "featured"
        static let community = "community"
        static let topPicks = "topPicks"
        static let aiRecommend = "aiRecommend"
    }

    @State private var selectedSegment = SectionID.featured
    @State private var favoriteRecipeIDs: Set<Recipe.ID> = []

    private let recipeRepository = RecipeRepository.shared

    private let topSegments = [
        TopSegmentOption(id: SectionID.featured, title: "Featured", systemImage: "leaf.fill"),
        TopSegmentOption(id: SectionID.community, title: "Community", systemImage: "person.2.fill"),
        TopSegmentOption(id: SectionID.topPicks, title: "Top Picks", systemImage: "star.fill"),
        TopSegmentOption(id: SectionID.aiRecommend, title: "AI Recommend", systemImage: "sparkles")
    ]

    private var featuredRecipes: [Recipe] {
        recipeRepository.featuredRecipes
    }

    private var communityRecipes: [Recipe] {
        recipeRepository.communityRecipes
    }

    private var topPickRecipes: [Recipe] {
        recipeRepository.topPicksRecipes
    }

    private var aiRecommendRecipes: [Recipe] {
        recipeRepository.aiRecommendedRecipes
    }

    var body: some View {
        ScrollViewReader { proxy in
            AppScreen(
                contentSpacing: AppSpacing.sm,
                headerTopPadding: AppSpacing.xs,
                contentBottomPadding: AppSpacing.xxxl + AppSpacing.xxl
            ) {
                AppHeader(
                    leadingActions: [
                        AppHeaderAction(systemName: "line.3.horizontal", accessibilityLabel: "Open menu")
                    ],
                    trailingActions: [
                        AppHeaderAction(systemName: "cart", accessibilityLabel: "Shopping cart", badgeValue: 1),
                        AppHeaderAction(systemName: "person.crop.circle", accessibilityLabel: "Open profile")
                    ]
                )

                TopSegmentSelector(options: topSegments, selection: $selectedSegment) { option in
                    withAnimation(.easeInOut(duration: 0.24)) {
                        proxy.scrollTo(option.id, anchor: .top)
                    }
                }
            } content: {
                featuredSection
                    .id(SectionID.featured)

                recipeSection(title: "Community", id: SectionID.community, recipes: communityRecipes, showsCreator: true)

                recipeSection(title: "Top Picks", id: SectionID.topPicks, recipes: topPickRecipes)

                recipeSection(title: "AI Recommend", id: SectionID.aiRecommend, recipes: aiRecommendRecipes)
                    .padding(.top, AppSpacing.xs)
            }
        }
    }

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            SectionHeaderView("Featured", actionTitle: "See all", style: .compact) {}

            HorizontalCarousel(
                items: featuredRecipes,
                visibleItemCount: 1,
                cardHeight: 172
            ) { recipe in
                HeroRecipeCard(
                    recipe: recipe,
                    isFavorite: isFavorite(recipe),
                    favoriteAction: {
                        toggleFavorite(recipe)
                    }
                )
            }

            pageDots
        }
    }

    private func recipeSection(title: String, id: String, recipes: [Recipe], showsCreator: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            SectionHeaderView(title, actionTitle: "See all", style: .compact) {}

            HorizontalCarousel(items: recipes, cardHeight: 160) { recipe in
                RecipeCard(
                    recipe: recipe,
                    showsCreator: showsCreator,
                    isFavorite: isFavorite(recipe),
                    favoriteAction: {
                        toggleFavorite(recipe)
                    }
                )
            }
        }
        .id(id)
    }

    private var pageDots: some View {
        HStack(spacing: AppSpacing.xxs) {
            ForEach(featuredRecipes.indices, id: \.self) { index in
                Circle()
                    .fill(index == 0 ? AppColors.olive : AppColors.warmBorder)
                    .frame(width: 5, height: 5)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func isFavorite(_ recipe: Recipe) -> Bool {
        favoriteRecipeIDs.contains(recipe.id)
    }

    private func toggleFavorite(_ recipe: Recipe) {
        if favoriteRecipeIDs.contains(recipe.id) {
            favoriteRecipeIDs.remove(recipe.id)
        } else {
            favoriteRecipeIDs.insert(recipe.id)
        }
    }
}

#Preview {
    HomeView()
}
