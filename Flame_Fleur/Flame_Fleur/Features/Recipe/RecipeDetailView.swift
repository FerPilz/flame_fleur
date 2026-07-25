import SwiftUI

struct RecipeDetailView: View {
    let recipeID: String
    let onBack: (() -> Void)?
    let onViewIngredients: () -> Void
    let plannerSelectionContext: PlannerRecipeSelectionContext?
    let onAddToPlanner: ((Recipe) -> Void)?

    @EnvironmentObject private var favoritesStore: FavoritesStore
    @EnvironmentObject private var cartStore: ShoppingCartStore
    @Environment(\.dismiss) private var dismiss
    @State private var isChefPilotEnabled = false
    @State private var isCartPresented = false
    @State private var expandedStepID: Int?

    private let recipeRepository = RecipeRepository.shared

    init(
        recipeID: String,
        onBack: (() -> Void)? = nil,
        onViewIngredients: @escaping () -> Void = {},
        plannerSelectionContext: PlannerRecipeSelectionContext? = nil,
        onAddToPlanner: ((Recipe) -> Void)? = nil
    ) {
        self.recipeID = recipeID
        self.onBack = onBack
        self.onViewIngredients = onViewIngredients
        self.plannerSelectionContext = plannerSelectionContext
        self.onAddToPlanner = onAddToPlanner
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
        .onAppear {
            guard let recipe = recipeRepository.recipe(id: recipeID) else {
                return
            }

            UsageTrackingStore.shared.recordRecipeViewIfNeeded(for: recipe)
        }
    }

    private func recipeContent(_ recipe: Recipe) -> some View {
        GeometryReader { proxy in
            let heroHeight = resolvedHeroHeight(for: proxy.size.height)

            ZStack(alignment: .top) {
                AppColors.appBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Color.clear
                            .frame(height: heroHeight - RecipeDetailLayout.panelOverlap)

                        contentPanel(recipe)
                    }
                }
                .zIndex(0)

                RecipeHeroHeader(
                    recipe: recipe,
                    isFavorite: favoritesStore.isFavorite(recipe.id),
                    shareText: shareText(for: recipe),
                    showsBackButton: true,
                    showsBrandTitle: false,
                    onCartTap: { isCartPresented = true },
                    cartBadgeValue: cartStore.totalItemCount,
                    onBack: { goBack() },
                    onFavoriteTap: { favoritesStore.toggleFavorite(recipe.id) }
                )
                .frame(height: heroHeight)
                .ignoresSafeArea(edges: .top)
                .zIndex(1)
            }
            .safeAreaInset(edge: .bottom) {
                bottomActionBar(recipe)
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

    private func contentPanel(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            titleBlock(recipe)
            RecipeInfoCarousel(recipe: recipe)
            sourcePreview(recipe)
            notesPreview(recipe)
            nutritionPreview(recipe)
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

            if let plannerSelectionContext {
                Text(plannerSelectionContext.subtitle)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.olive)
                    .padding(.horizontal, AppSpacing.sm)
                    .frame(height: 26)
                    .background(
                        Capsule(style: .continuous)
                            .fill(AppColors.softOlive)
                    )
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(AppColors.warmBorder, lineWidth: 1)
                    )
            }
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
                    ForEach(Array(recipe.structuredIngredients.prefix(4).enumerated()), id: \.offset) { _, ingredient in
                        IngredientPreviewRow(ingredient: ingredient)
                    }
                }
            }
        }
    }

    private func nutritionPreview(_ recipe: Recipe) -> some View {
        let nutrition = recipe.nutritionPerServing

        return VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeaderView("Approx. nutrition per serving", style: .compact)

            SurfaceCard(
                backgroundColor: AppColors.elevatedCardBackground,
                borderColor: AppColors.warmBorder,
                cornerRadius: AppRadius.large,
                contentPadding: AppSpacing.sm,
                showsShadow: false
            ) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack(alignment: .firstTextBaseline, spacing: AppSpacing.sm) {
                        Text("\(nutrition.calories) kcal")
                            .font(AppTypography.sectionTitle)
                            .foregroundStyle(AppColors.primaryText)
                            .lineLimit(1)

                        Spacer(minLength: 0)

                        Text(recipe.servingsText)
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.secondaryText)
                            .lineLimit(1)
                    }

                    HStack(spacing: AppSpacing.sm) {
                        nutritionMetric(title: "Protein", value: "\(nutrition.proteinGrams) g")
                        nutritionMetric(title: "Carbs", value: "\(nutrition.carbsGrams) g")
                        nutritionMetric(title: "Fat", value: "\(nutrition.fatGrams) g")
                    }

                    HStack(spacing: AppSpacing.sm) {
                        nutritionMetric(title: "Fiber", value: "\(nutrition.fiberGrams) g")
                        nutritionMetric(title: "Sugar", value: "\(nutrition.sugarGrams) g")
                        nutritionMetric(title: "Sodium", value: "\(nutrition.sodiumMilligrams) mg")
                    }
                }
            }
        }
    }

    private func nutritionMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(1)

            Text(value)
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func sourcePreview(_ recipe: Recipe) -> some View {
        if recipe.userRecipeSourceType == .importedURL
            || recipe.sourceURLString?.isEmpty == false
            || recipe.sourceHost?.isEmpty == false {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                SectionHeaderView("Source", style: .compact)

                SurfaceCard(
                    backgroundColor: AppColors.elevatedCardBackground,
                    borderColor: AppColors.warmBorder,
                    cornerRadius: AppRadius.large,
                    contentPadding: AppSpacing.sm,
                    showsShadow: false
                ) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        if let sourceHost = recipe.sourceHost?.trimmingCharacters(in: .whitespacesAndNewlines),
                           !sourceHost.isEmpty {
                            metadataLine(systemName: "globe", text: sourceHost)
                        }

                        if let sourceURLString = recipe.sourceURLString?.trimmingCharacters(in: .whitespacesAndNewlines),
                           !sourceURLString.isEmpty {
                            if let url = URL(string: sourceURLString) {
                                Link(destination: url) {
                                    metadataLine(systemName: "link", text: sourceURLString)
                                }
                                .buttonStyle(.plain)
                            } else {
                                metadataLine(systemName: "link", text: sourceURLString)
                            }
                        }

                        if let importedAt = recipe.importedAt {
                            metadataLine(
                                systemName: "calendar",
                                text: "Imported \(importedAt.formatted(date: .abbreviated, time: .omitted))"
                            )
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func notesPreview(_ recipe: Recipe) -> some View {
        if let notes = recipe.notes?.trimmingCharacters(in: .whitespacesAndNewlines),
           !notes.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                SectionHeaderView("Notes", style: .compact)

                SurfaceCard(
                    backgroundColor: AppColors.cardBackground.opacity(0.70),
                    borderColor: AppColors.warmBorder,
                    cornerRadius: AppRadius.large,
                    contentPadding: AppSpacing.sm,
                    showsShadow: false
                ) {
                    Text(notes)
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func metadataLine(systemName: String, text: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.xs) {
            Image(systemName: systemName)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.olive)
                .frame(width: 16, alignment: .center)
                .padding(.top, 2)

            Text(text)
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
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

    private func bottomActionBar(_ recipe: Recipe) -> some View {
        VStack(spacing: AppSpacing.xs) {
            if let plannerSelectionContext, let onAddToPlanner {
                PrimaryButton(plannerSelectionContext.actionTitle, systemImage: "plus", style: .recipe, height: 50) {
                    onAddToPlanner(recipe)
                }

                Button {
                    onViewIngredients()
                } label: {
                    Text("View Ingredients")
                        .font(AppTypography.smallButton)
                        .foregroundStyle(AppColors.olive)
                }
                .buttonStyle(.plain)
            } else {
                PrimaryButton("View Ingredients", systemImage: "list.bullet.clipboard", style: .recipe, height: 50) {
                    onViewIngredients()
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
        "Check out this recipe: \(recipe.title) in ALLSPICED. \(recipe.totalTimeText) total, \(recipe.servingsText)."
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
    static let minHeroHeight: CGFloat = 278
    static let maxHeroHeight: CGFloat = 344
    static let heroHeightRatio: CGFloat = 0.37
    static let panelOverlap: CGFloat = 72
}

#Preview {
    RecipeDetailView(recipeID: RecipeRepository.shared.allRecipes[0].id)
        .environmentObject(FavoritesStore.shared)
        .environmentObject(ShoppingCartStore.shared)
}
