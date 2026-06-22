import SwiftUI

struct RecipeIngredientsView: View {
    let recipeID: String
    let onBack: (() -> Void)?

    @EnvironmentObject private var favoritesStore: FavoritesStore
    @EnvironmentObject private var cartStore: ShoppingCartStore
    @Environment(\.dismiss) private var dismiss
    @State private var servings: Int
    @State private var selectedIngredientIndexes: Set<Int>
    @State private var addSelectedMessage: String?

    private let recipeRepository = RecipeRepository.shared

    init(recipeID: String, onBack: (() -> Void)? = nil) {
        self.recipeID = recipeID
        self.onBack = onBack

        let recipe = RecipeRepository.shared.recipe(id: recipeID)
        _servings = State(initialValue: max(recipe?.servings ?? 1, 1))
        _selectedIngredientIndexes = State(initialValue: Set(recipe?.structuredIngredients.indices ?? 0..<0))
    }

    var body: some View {
        Group {
            if let recipe = recipeRepository.recipe(id: recipeID) {
                recipeContent(recipe)
            } else {
                missingRecipeView
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }

    private func recipeContent(_ recipe: Recipe) -> some View {
        GeometryReader { proxy in
            let heroHeight = resolvedHeroHeight(for: proxy.size.height)

            ZStack(alignment: .top) {
                AppColors.appBackground
                    .ignoresSafeArea()

                RecipeHeroHeader(
                    recipe: recipe,
                    isFavorite: favoritesStore.isFavorite(recipe.id),
                    shareText: shareText(for: recipe),
                    showsBackButton: false,
                    onCartTap: nil,
                    cartBadgeValue: nil,
                    onBack: { goBack() },
                    onFavoriteTap: { favoritesStore.toggleFavorite(recipe.id) }
                )
                .frame(height: heroHeight)
                .ignoresSafeArea(edges: .top)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Color.clear
                            .frame(height: heroHeight - RecipeIngredientsLayout.panelOverlap)

                        contentPanel(recipe)
                    }
                }

                heroBackButton(topInset: proxy.safeAreaInsets.top)
            }
            .safeAreaInset(edge: .bottom) {
                bottomActionBar(recipe)
            }
        }
    }

    private func heroBackButton(topInset: CGFloat) -> some View {
        VStack {
            HStack {
                IconCircleButton(
                    systemName: "chevron.left",
                    accessibilityLabel: "Back",
                    size: AppTopActionMetrics.buttonSize,
                    backgroundColor: AppColors.elevatedCardBackground.opacity(0.94),
                    foregroundColor: AppColors.olive,
                    action: goBack
                )

                Spacer(minLength: 0)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, max(topInset + AppSpacing.sm, AppTopActionMetrics.minimumTopOffset))
    }

    private func goBack() {
        if let onBack {
            onBack()
        } else {
            dismiss()
        }
    }

    private func contentPanel(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            titleBlock(recipe)
            RecipeInfoCarousel(recipe: recipe)
            servingsControl
            checklistHeader(recipe)
            checklist(recipe)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.md)
        .padding(.bottom, AppSpacing.xxxl + AppSpacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.hero, style: .continuous)
                .fill(AppColors.appBackground)
                .shadow(color: AppShadow.cardColor, radius: AppShadow.cardRadius, x: 0, y: -AppShadow.cardYOffset)
        )
    }

    private func titleBlock(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(recipe.title)
                .font(AppTypography.heroTitle)
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(2)
                .lineSpacing(2)
                .accessibilityAddTraits(.isHeader)

            Text("Ingredients")
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColors.olive)
                .lineLimit(1)
        }
    }

    private var servingsControl: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            borderColor: AppColors.warmBorder,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.sm,
            showsShadow: false
        ) {
            HStack(spacing: AppSpacing.sm) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("Servings")
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColors.primaryText)

                    Text("Adjusts this checklist locally")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                }

                Spacer(minLength: AppSpacing.sm)

                stepperButton(systemName: "minus") {
                    servings = max(1, servings - 1)
                }

                Text("\(servings)")
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColors.primaryText)
                    .frame(width: AppSpacing.xl)

                stepperButton(systemName: "plus") {
                    servings += 1
                }
            }
        }
    }

    private func checklistHeader(_ recipe: Recipe) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Button {
                toggleSelectAll(recipe)
            } label: {
                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: isAllSelected(recipe) ? "checkmark.circle.fill" : "circle")
                    Text("Select all")
                }
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.olive)
            }
            .buttonStyle(.plain)

            Spacer(minLength: AppSpacing.sm)

            Text("\(selectedIngredientIndexes.count) selected")
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.secondaryText)
        }
    }

    private func checklist(_ recipe: Recipe) -> some View {
        VStack(spacing: AppSpacing.xs) {
            ForEach(Array(recipe.structuredIngredients.enumerated()), id: \.offset) { index, ingredient in
                IngredientChecklistRow(
                    ingredient: ingredient,
                    isSelected: selectedIngredientIndexes.contains(index)
                ) {
                    toggleIngredient(at: index)
                }
            }
        }
    }

    private func bottomActionBar(_ recipe: Recipe) -> some View {
        VStack(spacing: AppSpacing.xs) {
            if let addSelectedMessage {
                Text(addSelectedMessage)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(1)
                    .transition(.opacity)
            }

            PrimaryButton("Add Selected to Cart", systemImage: "cart.badge.plus", style: .recipe, height: 50) {
                let selectedIngredients = recipe.structuredIngredients.enumerated().compactMap { index, ingredient in
                    selectedIngredientIndexes.contains(index) ? ingredient : nil
                }

                guard !selectedIngredients.isEmpty else {
                    withAnimation(.easeInOut) {
                        addSelectedMessage = "Select ingredients to add."
                    }
                    return
                }

                cartStore.addRecipeIngredients(selectedIngredients, from: recipe)

                withAnimation(.easeInOut) {
                    addSelectedMessage = "\(selectedIngredients.count) ingredients added to the cart."
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.sm)
        .padding(.bottom, AppSpacing.sm)
        .background(
            LinearGradient(
                colors: [
                    AppColors.appBackground.opacity(0.28),
                    AppColors.appBackground
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var missingRecipeView: some View {
        ZStack {
            AppColors.appBackground
                .ignoresSafeArea()

            SurfaceCard(cornerRadius: AppRadius.extraLarge, contentPadding: AppSpacing.lg) {
                VStack(alignment: .center, spacing: AppSpacing.sm) {
                    Text("Recipe unavailable")
                        .font(AppTypography.heroTitle)
                        .foregroundStyle(AppColors.primaryText)

                    Text("This ingredient list could not be found.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                        .multilineTextAlignment(.center)

                    PrimaryButton("Back", systemImage: "chevron.left", style: .olive, isFullWidth: false) {
                        goBack()
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(AppSpacing.lg)
        }
    }

    private func stepperButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(AppColors.cardBackground)
                .frame(width: AppSpacing.xxl, height: AppSpacing.xxl)
                .overlay(
                    Image(systemName: systemName)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.olive)
                )
                .overlay(
                    Circle()
                        .stroke(AppColors.warmBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func toggleIngredient(at index: Int) {
        if selectedIngredientIndexes.contains(index) {
            selectedIngredientIndexes.remove(index)
        } else {
            selectedIngredientIndexes.insert(index)
        }
    }

    private func toggleSelectAll(_ recipe: Recipe) {
        if isAllSelected(recipe) {
            selectedIngredientIndexes.removeAll()
        } else {
            selectedIngredientIndexes = Set(recipe.structuredIngredients.indices)
        }
    }

    private func isAllSelected(_ recipe: Recipe) -> Bool {
        selectedIngredientIndexes.count == recipe.structuredIngredients.count
    }

    private func resolvedHeroHeight(for screenHeight: CGFloat) -> CGFloat {
        min(
            max(screenHeight * RecipeIngredientsLayout.heroHeightRatio, RecipeIngredientsLayout.minHeroHeight),
            RecipeIngredientsLayout.maxHeroHeight
        )
    }

    private func shareText(for recipe: Recipe) -> String {
        "Check out this recipe: \(recipe.title) in Flame & Fleur. \(recipe.totalTimeText) total, \(recipe.servingsText)."
    }

}

private enum RecipeIngredientsLayout {
    static let minHeroHeight: CGFloat = 220
    static let maxHeroHeight: CGFloat = 270
    static let heroHeightRatio: CGFloat = 0.29
    static let panelOverlap: CGFloat = 72
}

#Preview {
    RecipeIngredientsView(recipeID: RecipeRepository.shared.allRecipes[0].id)
        .environmentObject(FavoritesStore.shared)
        .environmentObject(ShoppingCartStore.shared)
}
