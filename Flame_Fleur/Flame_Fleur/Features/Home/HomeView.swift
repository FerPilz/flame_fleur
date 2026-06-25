import SwiftUI

struct HomeView: View {
    let openExplore: (ExploreLaunchContext) -> Void

    @EnvironmentObject private var favoritesStore: FavoritesStore
    @EnvironmentObject private var shoppingCartStore: ShoppingCartStore

    @State private var navigationPath: [HomeRoute] = []
    @State private var selectedSegment = HomeShowcaseSection.featured.id

    private let recipeRepository = RecipeRepository.shared

    init(openExplore: @escaping (ExploreLaunchContext) -> Void = { _ in }) {
        self.openExplore = openExplore
    }

    var body: some View {
        ScrollViewReader { proxy in
            NavigationStack(path: $navigationPath) {
                AppScreen(
                    contentSpacing: 0,
                    headerTopPadding: AppSpacing.xxs,
                    contentTopPadding: AppSpacing.xs,
                    contentBottomPadding: AppSpacing.xxxl + AppSpacing.xxl,
                    backgroundColor: AppColors.porcelainCream
                ) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        AppHeader(
                            title: "ALLSPICED",
                            titleFont: .custom("Copperplate-Bold", size: 25),
                            leadingActions: [
                                AppHeaderAction(systemName: "line.3.horizontal", accessibilityLabel: "Open settings") {
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

                        TopSegmentSelector(options: topSegments, selection: $selectedSegment) { option in
                            withAnimation(.easeInOut(duration: 0.24)) {
                                proxy.scrollTo(option.id, anchor: .top)
                            }
                        }
                    }
                } content: {
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        featuredSection
                            .id(HomeShowcaseSection.featured.id)

                        ForEach(visibleHomeSections) { section in
                            homeCarouselSection(for: section)
                                .id(section.id)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .navigationDestination(for: HomeRoute.self) { route in
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
                    case .cart:
                        ShoppingCartView {
                            if !navigationPath.isEmpty {
                                navigationPath.removeLast()
                            }
                        }
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
                .toolbar(.hidden, for: .navigationBar)
            }
        }
    }

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            SectionHeaderView(HomeShowcaseSection.featured.headerTitle, actionTitle: "See all", style: .compact) {
                openExplore(.featured)
            }

            HorizontalCarousel(
                items: featuredRecipes,
                visibleItemCount: 1,
                cardHeight: 172
            ) { recipe in
                HeroRecipeCard(
                    recipe: recipe,
                    isFavorite: favoritesStore.isFavorite(recipe.id),
                    action: {
                        navigationPath.append(.recipe(recipe.id))
                    },
                    favoriteAction: {
                        favoritesStore.toggleFavorite(recipe.id)
                    }
                )
            }
            .clipped()

            pageDots
        }
    }

    private func homeCarouselSection(for section: HomeShowcaseSection) -> some View {
        let items = recipeRepository.homeCarouselRecipes(for: section)

        guard !items.isEmpty else {
            return AnyView(EmptyView())
        }

        return AnyView(
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                SectionHeaderView(section.headerTitle, actionTitle: "See all", style: .compact) {
                    openExplore(section.exploreLaunchContext)
                }

                HorizontalCarousel(
                    items: items,
                    visibleItemCount: 3,
                    cardHeight: 166
                ) { recipe in
                    RecipeCard(
                        recipe: recipe,
                        isFavorite: favoritesStore.isFavorite(recipe.id),
                        action: {
                            navigationPath.append(.recipe(recipe.id))
                        },
                        favoriteAction: {
                            favoritesStore.toggleFavorite(recipe.id)
                        }
                    )
                }
            }
        )
    }

    private var featuredRecipes: [Recipe] {
        recipeRepository.featuredRecipes
    }

    private var visibleHomeSections: [HomeShowcaseSection] {
        HomeShowcaseSection.carouselSections.filter { section in
            !recipeRepository.homeCarouselRecipes(for: section).isEmpty
        }
    }

    private var topSegments: [TopSegmentOption] {
        ([HomeShowcaseSection.featured] + visibleHomeSections).map(\.selectorOption)
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
}

private enum HomeRoute: Hashable {
    case recipe(String)
    case ingredients(String)
    case cart
    case profile
    case settings
}

#Preview {
    HomeView()
        .environmentObject(FavoritesStore.shared)
        .environmentObject(ShoppingCartStore.shared)
        .environmentObject(UserProfileStore.shared)
        .environmentObject(AppSettingsStore.shared)
}
