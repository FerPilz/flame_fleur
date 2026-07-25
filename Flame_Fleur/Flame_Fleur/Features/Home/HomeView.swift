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
        NavigationStack(path: $navigationPath) {
            ScrollViewReader { proxy in
                ZStack {
                    AppColors.appBackground.ignoresSafeArea()

                    ScrollView(showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            featuredSection

                            ForEach(Array(visibleHomeSections.enumerated()), id: \.element.id) { index, section in
                                homeCarouselSection(for: section)
                                    .padding(.top, homeCarouselTopSpacing(for: index))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.top, AppSpacing.xxs)
                        .padding(.bottom, AppSpacing.xs + AppSpacing.xs)
                        .onPreferenceChange(HomeSectionPositionPreferenceKey.self) { positions in
                            updateSelectedSegment(from: positions)
                        }
                    }
                    .safeAreaInset(edge: .top, spacing: 0) {
                        stickyHeader(proxy: proxy)
                    }
                    .coordinateSpace(name: HomeLayoutMetrics.scrollCoordinateSpaceName)
                }
                .navigationDestination(for: HomeRoute.self) { route in
                    switch route {
                    case .recipeIntro(let recipeID):
                        if let recipe = recipeRepository.recipe(id: recipeID) {
                            RecipeIntroView(
                                recipe: recipe,
                                onBack: {
                                    if !navigationPath.isEmpty {
                                        navigationPath.removeLast()
                                    }
                                },
                                onStartCooking: {
                                    startCooking(from: recipeID)
                                }
                            )
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

    private func stickyHeader(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: AppSpacing.xxs) {
            AppHeader(
                leadingActions: [
                    AppHeaderAction(systemName: "line.3.horizontal", accessibilityLabel: "Open settings") {
                        navigationPath.append(.settings)
                    }
                ],
                trailingActions: [
                    AppHeaderAction(systemName: "cart", accessibilityLabel: "Shopping cart", badgeValue: shoppingCartStore.totalItemCount) {
                        navigationPath.append(.cart)
                    }
                ]
            )

            TopSegmentSelector(options: topSegments, selection: $selectedSegment) { option in
                scrollToSection(option.id, proxy: proxy)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, AppSpacing.xxs)
        .padding(.bottom, AppSpacing.xxs)
        .background(AppColors.appBackground)
    }

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            SectionHeaderView(HomeShowcaseSection.featured.headerTitle, actionTitle: "See all", style: .compact) {
                openExplore(.featured)
            }

            HorizontalCarousel(
                items: featuredRecipes,
                visibleItemCount: 1,
                cardHeight: HomeLayoutMetrics.featuredCardHeight,
                autoScrollInterval: 7
                    ) { recipe in
                        HeroRecipeCard(
                            recipe: recipe,
                            isFavorite: favoritesStore.isFavorite(recipe.id),
                            imageWidthScale: HomeLayoutMetrics.heroImageWidthScale,
                            cardHeight: HomeLayoutMetrics.featuredCardHeight,
                            action: {
                                navigationPath.append(.recipeIntro(recipe.id))
                            },
                            favoriteAction: {
                                favoritesStore.toggleFavorite(recipe.id)
                            }
                        )
            }
            .clipped()

            pageDots
        }
        .id(HomeShowcaseSection.featured.id)
        .background(sectionPositionReader(id: HomeShowcaseSection.featured.id))
    }

    @ViewBuilder
    private func homeCarouselSection(for section: HomeShowcaseSection) -> some View {
        let items = recipeRepository.homeCarouselRecipes(for: section)

        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 15) {
                SectionHeaderView(section.headerTitle, actionTitle: "See all", style: .compact) {
                    openExplore(section.exploreLaunchContext)
                }

                HorizontalCarousel(
                    items: items,
                    visibleItemCount: HomeLayoutMetrics.carouselVisibleItemCount,
                    cardHeight: HomeLayoutMetrics.carouselCardHeight,
                    edgePadding: 0,
                    autoScrollInterval: 7
                    ) { recipe in
                        RecipeCard(
                            recipe: recipe,
                            isFavorite: favoritesStore.isFavorite(recipe.id),
                            imageHeight: HomeLayoutMetrics.carouselImageHeight,
                            action: {
                                navigationPath.append(.recipeIntro(recipe.id))
                            },
                            favoriteAction: {
                                favoritesStore.toggleFavorite(recipe.id)
                            }
                        )
                }
            }
            .id(section.id)
            .background(sectionPositionReader(id: section.id))
        }
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
        [HomeShowcaseSection.featured.selectorOption] + visibleHomeSections.map(\.selectorOption)
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

    private func homeCarouselTopSpacing(for index: Int) -> CGFloat {
        index == 0 ? HomeLayoutMetrics.carouselSectionSpacing : HomeLayoutMetrics.tightCarouselSectionSpacing
    }

    private func sectionPositionReader(id: String) -> some View {
        GeometryReader { proxy in
            Color.clear.preference(
                key: HomeSectionPositionPreferenceKey.self,
                value: [
                    HomeSectionPosition(
                        id: id,
                        minY: proxy.frame(in: .named(HomeLayoutMetrics.scrollCoordinateSpaceName)).minY
                    )
                ]
            )
        }
    }

    private func updateSelectedSegment(from positions: [HomeSectionPosition]) {
        let visibleIDs = Set(topSegments.map(\.id))
        let sectionPositions = positions.filter { visibleIDs.contains($0.id) }
        let activationOffset = HomeLayoutMetrics.sectionActivationOffset

        let activePosition = sectionPositions
            .filter { $0.minY <= activationOffset }
            .max { $0.minY < $1.minY }
            ?? sectionPositions.min { first, second in
                abs(first.minY - activationOffset) < abs(second.minY - activationOffset)
            }

        guard let activeID = activePosition?.id, activeID != selectedSegment else { return }
        selectedSegment = activeID
    }

    private func scrollToSection(_ id: String, proxy: ScrollViewProxy) {
        guard topSegments.contains(where: { $0.id == id }) else { return }

        selectedSegment = id

        withAnimation(.easeInOut(duration: 0.24)) {
            proxy.scrollTo(id, anchor: .top)
        }
    }

    private func startCooking(from recipeID: String) {
        if !navigationPath.isEmpty, case .recipeIntro = navigationPath.last {
            navigationPath.removeLast()
        }

        navigationPath.append(.recipe(recipeID))
    }
}

private enum HomeLayoutMetrics {
    static let scrollCoordinateSpaceName = "home-scroll-coordinate-space"
    static let sectionActivationOffset: CGFloat = 18
    static let carouselSectionSpacing: CGFloat = 0
    static let tightCarouselSectionSpacing: CGFloat = 0
    static let featuredCardHeight: CGFloat = 178
    static let carouselCardHeight: CGFloat = 170
    static let carouselVisibleItemCount: CGFloat = 2.55
    static let carouselImageHeight: CGFloat = 105
    static let heroImageWidthScale: CGFloat = 1.05
}

private enum HomeRoute: Hashable {
    case recipeIntro(String)
    case recipe(String)
    case ingredients(String)
    case cart
    case profile
    case settings
}

private struct HomeSectionPosition: Equatable {
    let id: String
    let minY: CGFloat
}

private struct HomeSectionPositionPreferenceKey: PreferenceKey {
    static var defaultValue: [HomeSectionPosition] = []

    static func reduce(value: inout [HomeSectionPosition], nextValue: () -> [HomeSectionPosition]) {
        value.append(contentsOf: nextValue())
    }
}

#Preview {
    HomeView()
        .environmentObject(FavoritesStore.shared)
        .environmentObject(ShoppingCartStore.shared)
        .environmentObject(UserProfileStore.shared)
        .environmentObject(AppSettingsStore.shared)
}
