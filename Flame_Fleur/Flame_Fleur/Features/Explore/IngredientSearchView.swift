import SwiftUI

struct IngredientSearchView: View {
    let availableIngredients: [ShoppingIngredientCatalogItem]
    @Binding var draftSelection: [String]
    @Binding var ingredientSearchText: String
    let recipeSearchText: String
    let matchingRecipes: [Recipe]
    let onRecipeSelected: (Recipe.ID) -> Void

    @EnvironmentObject private var favoritesStore: FavoritesStore
    @State private var expandedCategoryIDs: Set<String> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            selectedIngredientChipRail

            GeometryReader { proxy in
                let ingredientPanelHeight = calculatedIngredientPanelHeight(for: proxy.size.height)

                VStack(spacing: 0) {
                    ingredientBrowser
                        .frame(height: ingredientPanelHeight)

                    Divider()
                        .overlay(AppColors.warmBorder)

                    matchingRecipesPanel
                        .frame(minHeight: 145, maxHeight: .infinity, alignment: .top)
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private var selectedIngredientChipRail: some View {
        ZStack(alignment: .leading) {
            if !selectedIngredients.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    ForEach(selectedIngredients) { ingredient in
                        IngredientChip(title: ingredient.displayName) {
                            remove(ingredient.id)
                        }
                    }
                }
                .padding(.vertical, 1)
            }
            .accessibilityLabel("Selected ingredients")
            }
        }
        .frame(height: 34)
        .padding(.top, 6)
    }

    private var ingredientBrowser: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 10) {
                if categorySections.isEmpty {
                    Text("No ingredients found.")
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.secondaryText)
                        .padding(.top, AppSpacing.xs)
                        .accessibilityLabel("No ingredients found")
                } else {
                    ForEach(categorySections) { section in
                        ingredientSection(section)
                    }
                }
            }
            .padding(.vertical, 5)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func ingredientSection(_ section: IngredientCategorySection) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .center) {
                Text(section.category.title)
                    .font(AppTypography.exploreSectionTitle)
                    .foregroundStyle(AppColors.deepBasil)
                    .accessibilityAddTraits(.isHeader)

                Spacer(minLength: AppSpacing.sm)

                if !isSearchingCatalog {
                    Button(isExpanded(section) ? "Show less" : "See all") {
                        toggleExpansion(for: section)
                    }
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.deepBasil)
                    .accessibilityLabel(isExpanded(section) ? "Collapse \(section.category.title)" : "Expand \(section.category.title)")
                }
            }

            if isExpanded(section) {
                LazyVGrid(columns: gridColumns, spacing: AppSpacing.xs) {
                    ForEach(section.ingredients) { ingredient in
                        ingredientCard(ingredient, layout: .grid)
                    }
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 7) {
                        ForEach(section.ingredients.prefix(5)) { ingredient in
                            ingredientCard(ingredient, layout: .compact)
                                .frame(width: IngredientSearchLayoutMetrics.compactCardWidth)
                        }
                    }
                    .padding(.trailing, AppSpacing.xs)
                }
            }
        }
    }

    private func ingredientCard(
        _ ingredient: ShoppingIngredientCatalogItem,
        layout: IngredientOptionCell.Layout
    ) -> some View {
        IngredientOptionCell(
            ingredient: ingredient,
            isSelected: draftSelection.contains(ingredient.id),
            layout: layout
        ) {
            toggle(ingredient.id)
        }
    }

    private var matchingRecipesPanel: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Matching Recipes")
                        .font(AppTypography.exploreSectionTitle)
                        .foregroundStyle(AppColors.primaryText)
                        .accessibilityAddTraits(.isHeader)

                    Spacer()

                    Text("\(matchingRecipes.count)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.secondaryText)
                        .accessibilityLabel("\(matchingRecipes.count) matching recipes")
                }

                if draftSelection.isEmpty {
                    Text("Select ingredients to find recipes you can make.")
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.secondaryText)
                        .padding(.top, AppSpacing.xs)
                } else if matchingRecipes.isEmpty {
                    noMatchingRecipesState
                } else {
                    Text(matchingRecipesSupportingText)
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)

                    ForEach(matchingRecipes.prefix(3)) { recipe in
                        RecipeListRow(
                            recipe: recipe,
                            isFavorite: favoritesStore.isFavorite(recipe.id),
                            layout: .compact,
                            onFavoriteTap: {
                                favoritesStore.toggleFavorite(recipe.id)
                            },
                            onTap: {
                                onRecipeSelected(recipe.id)
                            }
                        )
                        .accessibilityHint("Matches all selected ingredients")
                    }
                }
            }
            .padding(.top, AppSpacing.xs)
            .padding(.bottom, 6)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var noMatchingRecipesState: some View {
        Text("Try another ingredient or remove a filter.")
            .font(AppTypography.callout)
            .foregroundStyle(AppColors.secondaryText)
            .padding(.top, AppSpacing.xs)
    }

    private var selectedIngredients: [ShoppingIngredientCatalogItem] {
        let itemsByID = Dictionary(uniqueKeysWithValues: availableIngredients.map { ($0.id, $0) })
        return draftSelection.compactMap { itemsByID[$0] }
    }

    private var categorySections: [IngredientCategorySection] {
        IngredientPresentationCategory.allCases.compactMap { category in
            let ingredients = availableIngredients.filter {
                IngredientPresentationCategory.category(for: $0) == category && matchesIngredientSearch($0)
            }

            guard !ingredients.isEmpty else {
                return nil
            }

            return IngredientCategorySection(category: category, ingredients: ingredients)
        }
    }

    private var isSearchingCatalog: Bool {
        !IngredientFilterService.normalize(ingredientSearchText).isEmpty
    }

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: AppSpacing.xs), count: 2)
    }

    private var matchingRecipesSupportingText: String {
        let trimmedRecipeSearch = recipeSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedRecipeSearch.isEmpty {
            return "Matches “\(trimmedRecipeSearch)” and all \(draftSelection.count) selected \(draftSelection.count == 1 ? "ingredient" : "ingredients")"
        }

        return "Recipes contain all \(draftSelection.count) selected \(draftSelection.count == 1 ? "ingredient" : "ingredients")"
    }

    private func calculatedIngredientPanelHeight(for availableHeight: CGFloat) -> CGFloat {
        let minimumResultsHeight: CGFloat = 145
        let maximumBrowserHeight = max(0, availableHeight - minimumResultsHeight - 1)
        let preferredBrowserHeight = min(max(availableHeight * 0.54, 250), 275)
        let minimumBrowserHeight = min(215, maximumBrowserHeight)

        return max(minimumBrowserHeight, min(preferredBrowserHeight, maximumBrowserHeight))
    }

    private func matchesIngredientSearch(_ ingredient: ShoppingIngredientCatalogItem) -> Bool {
        let query = IngredientFilterService.normalize(ingredientSearchText)
        guard !query.isEmpty else {
            return true
        }

        return IngredientFilterService.normalize(ingredient.displayName).contains(query)
            || IngredientFilterService.normalize(ingredient.normalizedName).contains(query)
    }

    private func isExpanded(_ section: IngredientCategorySection) -> Bool {
        isSearchingCatalog || expandedCategoryIDs.contains(section.id)
    }

    private func toggleExpansion(for section: IngredientCategorySection) {
        if expandedCategoryIDs.contains(section.id) {
            expandedCategoryIDs.remove(section.id)
        } else {
            expandedCategoryIDs.insert(section.id)
        }
    }

    private func toggle(_ ingredientID: String) {
        if draftSelection.contains(ingredientID) {
            remove(ingredientID)
        } else {
            draftSelection.append(ingredientID)
        }
    }

    private func remove(_ ingredientID: String) {
        draftSelection.removeAll { $0 == ingredientID }
    }
}

private struct IngredientCategorySection: Identifiable {
    let category: IngredientPresentationCategory
    let ingredients: [ShoppingIngredientCatalogItem]

    var id: String { category.rawValue }
}

private enum IngredientPresentationCategory: String, CaseIterable, Identifiable {
    case vegetablesAndFruits
    case proteins
    case pantry

    var id: String { rawValue }

    var title: String {
        switch self {
        case .vegetablesAndFruits:
            return "Vegetables & Fruits"
        case .proteins:
            return "Proteins"
        case .pantry:
            return "Pantry"
        }
    }

    static func category(for ingredient: ShoppingIngredientCatalogItem) -> IngredientPresentationCategory {
        let name = IngredientFilterService.normalize(ingredient.displayName)

        if ingredient.category == "Protein" || proteinKeywords.contains(where: { name.contains($0) }) {
            return .proteins
        }

        if ingredient.category == "Produce" {
            return .vegetablesAndFruits
        }

        return .pantry
    }

    private static let proteinKeywords = ["bean", "lentil", "chickpea", "tofu", "tempeh", "egg"]
}

private enum IngredientSearchLayoutMetrics {
    static let compactCardWidth: CGFloat = 116
}
