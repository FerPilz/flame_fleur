import SwiftUI

struct RecipeDetailView: View {
    let recipeID: String
    let onBack: (() -> Void)?
    let onViewIngredients: () -> Void

    @EnvironmentObject private var favoritesStore: FavoritesStore
    @Environment(\.dismiss) private var dismiss
    @State private var isChefPilotEnabled = false
    @State private var isCartPresented = false
    @State private var expandedStepID: Int?

    private let recipeRepository = RecipeRepository.shared

    init(
        recipeID: String,
        onViewIngredients: @escaping () -> Void = {}
    ) {
        self.init(
            recipeID: recipeID,
            onBack: nil,
            onViewIngredients: onViewIngredients
        )
    }

    init(
        recipeID: String,
        onBack: (() -> Void)?,
        onViewIngredients: @escaping () -> Void = {}
    ) {
        self.recipeID = recipeID
        self.onBack = onBack
        self.onViewIngredients = onViewIngredients
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
        .navigationDestination(isPresented: $isCartPresented) {
            ShoppingCartView {
                isCartPresented = false
            }
            .toolbar(.hidden, for: .tabBar)
        }
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
                    onCartTap: { isCartPresented = true },
                    onBack: { goBack() },
                    onFavoriteTap: { favoritesStore.toggleFavorite(recipe.id) }
                )
                .frame(height: heroHeight)
                .ignoresSafeArea(edges: .top)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Color.clear
                            .frame(height: heroHeight - RecipeDetailLayout.panelOverlap)

                        contentPanel(recipe)
                    }
                }

                heroBackButton(topInset: proxy.safeAreaInsets.top)
            }
            .safeAreaInset(edge: .bottom) {
                bottomActionBar
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
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            titleBlock(recipe)
            RecipeInfoCarousel(recipe: recipe)
            ChefPilotCard(isEnabled: $isChefPilotEnabled)
            ingredientsPreview(recipe)
            cookingSteps(recipe)
            equipmentPreview(recipe)
            tipsPreview(recipe)
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
                .font(AppTypography.recipeDetailTitle)
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(2)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Text(recipe.subtitle)
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColors.olive)
                .lineLimit(2)

            Text(recipe.description)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(3)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func ingredientsPreview(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeaderView("Ingredients", actionTitle: "View Ingredients", style: .compact) {
                onViewIngredients()
            }

            SurfaceCard(
                backgroundColor: AppColors.elevatedCardBackground,
                borderColor: AppColors.warmBorder,
                cornerRadius: AppRadius.large,
                contentPadding: AppSpacing.sm,
                showsShadow: false
            ) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    ForEach(Array(recipe.ingredients.prefix(4).enumerated()), id: \.offset) { _, ingredient in
                        IngredientPreviewRow(ingredient: ingredient)
                    }
                }
            }
        }
    }

    private func cookingSteps(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeaderView("Cooking Steps", subtitle: "\(recipe.instructions.count) guided steps", style: .compact)

            VStack(spacing: AppSpacing.xs) {
                ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                    let stepNumber = index + 1

                    ExpandableRecipeStepRow(
                        stepNumber: stepNumber,
                        title: stepTitle(for: stepNumber),
                        detail: instruction,
                        durationText: stepDurationText(for: recipe, stepNumber: stepNumber),
                        isExpanded: expandedStepID == stepNumber
                    ) {
                        withAnimation(.easeInOut) {
                            expandedStepID = expandedStepID == stepNumber ? nil : stepNumber
                        }
                    }
                }
            }
        }
    }

    private func equipmentPreview(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeaderView("Equipment", style: .compact)

            SurfaceCard(
                backgroundColor: AppColors.elevatedCardBackground,
                borderColor: AppColors.warmBorder,
                cornerRadius: AppRadius.large,
                contentPadding: AppSpacing.xs,
                showsShadow: false
            ) {
                Text(recipe.equipment.prefix(4).joined(separator: " · "))
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(2)
            }
        }
    }

    private func tipsPreview(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeaderView("Chef Notes", style: .compact)

            SurfaceCard(
                backgroundColor: AppColors.cardBackground.opacity(0.70),
                borderColor: AppColors.warmBorder,
                cornerRadius: AppRadius.large,
                contentPadding: AppSpacing.sm,
                showsShadow: false
            ) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    ForEach(Array(recipe.tips.prefix(2).enumerated()), id: \.offset) { _, tip in
                        HStack(alignment: .top, spacing: AppSpacing.xs) {
                            Image(systemName: "sparkles")
                                .font(AppTypography.metadata)
                                .foregroundStyle(AppColors.premiumGold)

                            Text(tip)
                                .font(AppTypography.callout)
                                .foregroundStyle(AppColors.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }

    private var bottomActionBar: some View {
        VStack(spacing: AppSpacing.xs) {
            PrimaryButton("View Ingredients", systemImage: "list.bullet.clipboard", style: .recipe, height: 50) {
                onViewIngredients()
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

            VStack(spacing: AppSpacing.lg) {
                IconCircleButton(systemName: "chevron.left", accessibilityLabel: "Back", size: AppTopActionMetrics.buttonSize) {
                    goBack()
                }

                SurfaceCard(cornerRadius: AppRadius.extraLarge, contentPadding: AppSpacing.lg) {
                    VStack(alignment: .center, spacing: AppSpacing.sm) {
                        Text("Recipe unavailable")
                            .font(AppTypography.heroTitle)
                            .foregroundStyle(AppColors.primaryText)

                        Text("This recipe could not be found in the local collection.")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(AppSpacing.lg)
        }
    }

    private func resolvedHeroHeight(for screenHeight: CGFloat) -> CGFloat {
        min(
            max(screenHeight * RecipeDetailLayout.heroHeightRatio, RecipeDetailLayout.minHeroHeight),
            RecipeDetailLayout.maxHeroHeight
        )
    }

    private func shareText(for recipe: Recipe) -> String {
        "Check out this recipe: \(recipe.title) in Flame & Fleur. \(recipe.totalTimeText) total, \(recipe.servingsText)."
    }

    private func stepTitle(for stepNumber: Int) -> String {
        let titles = [
            "Prepare Ingredients",
            "Build Flavor",
            "Cook Gently",
            "Finish the Dish",
            "Plate and Serve"
        ]

        return titles.indices.contains(stepNumber - 1) ? titles[stepNumber - 1] : "Step \(stepNumber)"
    }

    private func stepDurationText(for recipe: Recipe, stepNumber: Int) -> String {
        let stepCount = max(recipe.instructions.count, 1)
        let baseMinutes = max(recipe.cookingTimeMinutes / stepCount, 3)
        let adjustedMinutes = baseMinutes + (stepNumber.isMultiple(of: 2) ? 1 : 0)
        return "\(adjustedMinutes) min"
    }
}

private enum RecipeDetailLayout {
    static let minHeroHeight: CGFloat = 232
    static let maxHeroHeight: CGFloat = 286
    static let heroHeightRatio: CGFloat = 0.31
    static let panelOverlap: CGFloat = 72
}

#Preview {
    RecipeDetailView(recipeID: RecipeRepository.shared.allRecipes[0].id)
        .environmentObject(FavoritesStore.shared)
        .environmentObject(ShoppingCartStore.shared)
}
