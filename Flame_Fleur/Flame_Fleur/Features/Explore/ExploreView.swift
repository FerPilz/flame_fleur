import SwiftUI

struct ExploreView: View {
    @State private var searchText = ""
    @State private var selectedFilter: ExploreFilter = .all
    @State private var selectedCategory: RecipeCategory?
    @State private var selectedQuickAction: ExploreQuickAction?

    private let recipeRepository = RecipeRepository.shared

    var body: some View {
        AppScreen(
            contentSpacing: AppSpacing.md,
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
        } content: {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                searchBar
                quickActions
                filterChips
            }

            if visibleCategorySections.isEmpty {
                emptySearchState
            }

            ForEach(visibleCategorySections) { section in
                categorySection(section)
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

    private func categorySection(_ section: ExploreCategorySection) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xl) {
            SectionHeaderView(section.title, actionTitle: "See all", style: .compact) {}

            LazyVGrid(columns: categoryColumns, spacing: AppSpacing.xxl) {
                ForEach(section.items) { item in
                    CategoryCircleCard(
                        title: item.title,
                        imageName: item.imageName,
                        isSelected: selectedCategory == item.category
                    ) {
                        selectedCategory = selectedCategory == item.category ? nil : item.category
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

    private var visibleCategorySections: [ExploreCategorySection] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        return categorySections.compactMap { section in
            let items = section.items.filter { item in
                selectedFilter.matches(item.category)
                && matchesSearch(item, sectionTitle: section.title, searchText: trimmedSearch)
            }

            guard !items.isEmpty else {
                return nil
            }

            return ExploreCategorySection(title: section.title, items: items)
        }
    }

    private var categorySections: [ExploreCategorySection] {
        [
            ExploreCategorySection(
                title: "World Cuisine",
                items: [
                    ExploreCategoryItem(category: .italian, imageName: "pasta"),
                    ExploreCategoryItem(category: .mexican, imageName: "citrus"),
                    ExploreCategoryItem(category: .korean, imageName: "bowl")
                ]
            ),
            ExploreCategorySection(
                title: "Meat & Seafood",
                items: [
                    ExploreCategoryItem(category: .fish, imageName: "salmon"),
                    ExploreCategoryItem(category: .meat, imageName: "bowl"),
                    ExploreCategoryItem(category: .seafood, imageName: "salmon")
                ]
            ),
            ExploreCategorySection(
                title: "Vegetarian",
                items: [
                    ExploreCategoryItem(category: .tofuTempeh, imageName: "salad"),
                    ExploreCategoryItem(category: .beansLentils, imageName: "bowl"),
                    ExploreCategoryItem(category: .mushrooms, imageName: "salad")
                ]
            ),
            ExploreCategorySection(
                title: "Chicken",
                items: [
                    ExploreCategoryItem(category: .chicken, imageName: "salmon"),
                    ExploreCategoryItem(category: .chickenBowls, imageName: "bowl"),
                    ExploreCategoryItem(category: .chickenPasta, imageName: "pasta")
                ]
            ),
            ExploreCategorySection(
                title: "Bakery",
                items: [
                    ExploreCategoryItem(category: .bakery, imageName: "dessert"),
                    ExploreCategoryItem(category: .cakes, imageName: "dessert"),
                    ExploreCategoryItem(category: .pastries, imageName: "dessert")
                ]
            ),
            ExploreCategorySection(
                title: "High Protein",
                items: [
                    ExploreCategoryItem(category: .highProtein, imageName: "salad"),
                    ExploreCategoryItem(category: .leanMeals, imageName: "bowl"),
                    ExploreCategoryItem(category: .fitnessMeals, imageName: "salad")
                ]
            )
        ]
    }

    private func matchesSearch(_ item: ExploreCategoryItem, sectionTitle: String, searchText: String) -> Bool {
        guard !searchText.isEmpty else {
            return true
        }

        if sectionTitle.localizedCaseInsensitiveContains(searchText)
            || item.title.localizedCaseInsensitiveContains(searchText)
            || item.category.title.localizedCaseInsensitiveContains(searchText) {
            return true
        }

        return recipeRepository.recipes(for: item.category).contains { recipe in
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

    func matches(_ category: RecipeCategory) -> Bool {
        switch self {
        case .all:
            return true
        case .protein:
            return [
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
                .fitnessMeals
            ].contains(category)
        case .vegetarian:
            return [
                .tofuTempeh,
                .beansLentils,
                .mushrooms,
                .vegetarian,
                .salad,
                .grainBowl
            ].contains(category)
        case .quickMeals:
            return [
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
            ].contains(category)
        }
    }
}

private struct ExploreCategorySection: Identifiable {
    let id: String
    let title: String
    let items: [ExploreCategoryItem]

    init(title: String, items: [ExploreCategoryItem]) {
        self.id = title
        self.title = title
        self.items = items
    }
}

private struct ExploreCategoryItem: Identifiable {
    let id: String
    let category: RecipeCategory
    let title: String
    let imageName: String?

    init(category: RecipeCategory, imageName: String?) {
        self.id = category.id
        self.category = category
        self.title = category.title
        self.imageName = imageName
    }
}

#Preview {
    ExploreView()
}
