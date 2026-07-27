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
    @StateObject private var chefPilotController = ChefPilotController()
    @State private var isCartPresented = false
    @State private var isShowingIngredients = false
    @State private var ingredientServings = 1
    @State private var selectedIngredientIndexes: Set<Int> = []
    @State private var addSelectedMessage: String?
    @State private var isNutritionExpanded = false
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
        .alert(item: $chefPilotController.presentedAlert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationDestination(isPresented: $isCartPresented) {
            ShoppingCartView {
                isCartPresented = false
            }
            .toolbar(.hidden, for: .tabBar)
        }
        .onDisappear {
            chefPilotController.deactivate(resetStepIndex: true)
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
                            .allowsHitTesting(false)

                        contentPanel(recipe)
                    }
                }
                .zIndex(1)

                RecipeHeroHeader(
                    recipe: recipe,
                    isFavorite: favoritesStore.isFavorite(recipe.id),
                    shareText: shareText(for: recipe),
                    showsBackground: true,
                    showsBackButton: false,
                    showsShareButton: false,
                    showsBrandTitle: false,
                    showsFavoriteButton: false,
                    topControlsPadding: RecipeDetailLayout.topControlsPadding,
                    onCartTap: nil,
                    cartBadgeValue: nil,
                    onBack: { goBack() },
                    onFavoriteTap: { favoritesStore.toggleFavorite(recipe.id) }
                )
                .frame(height: heroHeight)
                .ignoresSafeArea(edges: .top)
                .zIndex(0)

                RecipeHeroHeader(
                    recipe: recipe,
                    isFavorite: favoritesStore.isFavorite(recipe.id),
                    shareText: shareText(for: recipe),
                    showsBackground: false,
                    showsBackButton: true,
                    showsShareButton: true,
                    showsBrandTitle: false,
                    showsFavoriteButton: false,
                    topControlsPadding: RecipeDetailLayout.topControlsPadding,
                    onCartTap: { isCartPresented = true },
                    cartBadgeValue: cartStore.totalItemCount > 0 ? cartStore.totalItemCount : nil,
                    onBack: { goBack() },
                    onFavoriteTap: { favoritesStore.toggleFavorite(recipe.id) }
                )
                .frame(height: heroHeight)
                .ignoresSafeArea(edges: .top)
                .zIndex(2)

            }
            .safeAreaInset(edge: .bottom) {
                bottomActionBar(recipe)
            }
            .onAppear {
                chefPilotController.updateSteps(recipe.instructions)
                syncIngredientsState(for: recipe)
            }
            .onChange(of: recipe.instructions) { _, newValue in
                chefPilotController.updateSteps(newValue)
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
            contentPanelBody(recipe)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.md)
        .padding(.bottom, AppSpacing.xxxl + AppSpacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 40,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 40,
                style: .continuous
            )
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

    @ViewBuilder
    private func contentPanelBody(_ recipe: Recipe) -> some View {
        if isShowingIngredients {
            ingredientsPanelContent(recipe)
        } else {
            recipePanelContent(recipe)
        }
    }

    @ViewBuilder
    private func recipePanelContent(_ recipe: Recipe) -> some View {
        RecipeInfoCarousel(recipe: recipe)
            .padding(.top, -8)
        sourcePreview(recipe)
        notesPreview(recipe)
        nutritionPreview(recipe)
            .padding(.top, -8)
        ChefPilotCard(
            state: chefPilotController.state,
            currentStepIndex: chefPilotController.currentStepIndex,
            action: {
                chefPilotController.toggle()
            }
        )
        ingredientsPreview(recipe)
        cookingSteps(recipe)
        equipmentPreview(recipe)
        tipsPreview(recipe)
    }

    private func ingredientsPanelContent(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(alignment: .top, spacing: AppSpacing.sm) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("Ingredients")
                        .font(AppTypography.sectionTitle)
                        .foregroundStyle(AppColors.primaryText)

                    Text("Adjust servings, select items, and add them to your cart.")
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: AppSpacing.sm)

                Button {
                    withAnimation(nil) {
                        isShowingIngredients = false
                        addSelectedMessage = nil
                    }
                } label: {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "chevron.left")
                        Text("Back to Recipe")
                    }
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.olive)
                }
                .buttonStyle(.plain)
            }

            ingredientsServingsControl
            ingredientsChecklistHeader(recipe)
            ingredientsChecklist(recipe)
        }
        .transition(.opacity)
    }

    private func ingredientsPreview(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeaderView("Ingredients", actionTitle: "View Ingredients", style: .compact) {
                presentIngredientsOverlay()
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

    private var ingredientsServingsControl: some View {
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

                ingredientsStepperButton(systemName: "minus") {
                    ingredientServings = max(1, ingredientServings - 1)
                }

                Text("\(ingredientServings)")
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColors.primaryText)
                    .frame(width: AppSpacing.xl)

                ingredientsStepperButton(systemName: "plus") {
                    ingredientServings += 1
                }
            }
        }
    }

    private func ingredientsChecklistHeader(_ recipe: Recipe) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Button {
                toggleSelectAllIngredients(recipe)
            } label: {
                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: isAllIngredientsSelected(recipe) ? "checkmark.circle.fill" : "circle")
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

    private func ingredientsChecklist(_ recipe: Recipe) -> some View {
        VStack(spacing: AppSpacing.xs) {
            ForEach(Array(recipe.structuredIngredients.enumerated()), id: \.offset) { index, ingredient in
                IngredientChecklistRow(
                    ingredient: ingredient,
                    isSelected: selectedIngredientIndexes.contains(index)
                ) {
                    toggleIngredientSelection(at: index)
                }
            }
        }
    }

    private func nutritionPreview(_ recipe: Recipe) -> some View {
        let nutrition = recipe.nutritionPerServing

        return SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            borderColor: AppColors.warmBorder,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.sm,
            showsShadow: false
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Button {
                    withAnimation(.easeInOut(duration: 0.24)) {
                        isNutritionExpanded.toggle()
                    }
                } label: {
                    HStack(spacing: AppSpacing.sm) {
                        Text("Nutrition Info")
                            .font(.system(size: 20, weight: .semibold, design: .serif))
                            .foregroundStyle(Color("DeepBasil"))

                        Spacer(minLength: 0)

                        Image(systemName: isNutritionExpanded ? "chevron.up" : "chevron.down")
                            .font(AppTypography.metadata)
                            .foregroundStyle(Color("DeepBasil"))
                    }
                }
                .buttonStyle(.plain)

                if isNutritionExpanded {
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
                            NutritionMetricView(title: "Protein", value: "\(nutrition.proteinGrams) g", iconName: "ProteinIcon")
                            NutritionMetricView(title: "Carbs", value: "\(nutrition.carbsGrams) g", iconName: "CarbsIcon")
                            NutritionMetricView(title: "Fat", value: "\(nutrition.fatGrams) g", iconName: "FatIcon")
                        }

                        HStack(spacing: AppSpacing.sm) {
                            NutritionMetricView(title: "Fiber", value: "\(nutrition.fiberGrams) g", iconName: "FiberIcon")
                            NutritionMetricView(title: "Sugar", value: "\(nutrition.sugarGrams) g", iconName: "SugarIcon")
                            NutritionMetricView(title: "Sodium", value: "\(nutrition.sodiumMilligrams) mg", iconName: "SodiumIcon")
                        }
                    }
                } else {
                    HStack(alignment: .firstTextBaseline, spacing: AppSpacing.sm) {
                            Text("Protein: \(nutrition.proteinGrams)g • Carbs: \(nutrition.carbsGrams)g • Fat: \(nutrition.fatGrams)g")
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.primaryText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)

                            Spacer(minLength: AppSpacing.sm)

                            Text("Expand for details")
                                .font(AppTypography.metadata)
                                .foregroundStyle(AppColors.secondaryText)
                                .lineLimit(1)
                    }
                }
            }
        }
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
            if isShowingIngredients {
                if let addSelectedMessage {
                    Text(addSelectedMessage)
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(1)
                        .transition(.opacity)
                }

                PrimaryButton(
                    "Add Selected to Cart",
                    systemImage: "cart.badge.plus",
                    style: .recipe,
                    height: RecipeDetailLayout.viewIngredientsButtonHeight,
                    font: RecipeDetailLayout.viewIngredientsButtonFont
                ) {
                    addSelectedIngredientsToCart(recipe)
                }
            } else if let plannerSelectionContext, let onAddToPlanner {
                PrimaryButton(plannerSelectionContext.actionTitle, systemImage: "plus", style: .recipe, height: 50) {
                    onAddToPlanner(recipe)
                }

                Button {
                    presentIngredientsOverlay()
                } label: {
                    Text("View Ingredients")
                        .font(AppTypography.smallButton)
                        .foregroundStyle(AppColors.olive)
                }
                .buttonStyle(.plain)
            } else {
                PrimaryButton("View Ingredients", systemImage: "list.bullet.clipboard", style: .recipe, height: RecipeDetailLayout.viewIngredientsButtonHeight,
                              font: RecipeDetailLayout.viewIngredientsButtonFont
                ) {
                    presentIngredientsOverlay()
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.sm)
        .padding(.bottom, AppSpacing.xs)
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

    private func presentIngredientsOverlay() {
        withAnimation(nil) {
            isShowingIngredients = true
            addSelectedMessage = nil
        }
    }

    private func syncIngredientsState(for recipe: Recipe) {
        ingredientServings = max(recipe.servings, 1)
        selectedIngredientIndexes = Set(recipe.structuredIngredients.indices)
    }

    private func ingredientsStepperButton(systemName: String, action: @escaping () -> Void) -> some View {
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

    private func toggleIngredientSelection(at index: Int) {
        if selectedIngredientIndexes.contains(index) {
            selectedIngredientIndexes.remove(index)
        } else {
            selectedIngredientIndexes.insert(index)
        }
    }

    private func toggleSelectAllIngredients(_ recipe: Recipe) {
        if isAllIngredientsSelected(recipe) {
            selectedIngredientIndexes.removeAll()
        } else {
            selectedIngredientIndexes = Set(recipe.structuredIngredients.indices)
        }
    }

    private func isAllIngredientsSelected(_ recipe: Recipe) -> Bool {
        selectedIngredientIndexes.count == recipe.structuredIngredients.count
    }

    private func addSelectedIngredientsToCart(_ recipe: Recipe) {
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
    static let minHeroHeight: CGFloat = RecipeScreenHeroLayout.minHeroHeight
    static let maxHeroHeight: CGFloat = RecipeScreenHeroLayout.maxHeroHeight
    static let heroHeightRatio: CGFloat = RecipeScreenHeroLayout.heroHeightRatio
    static let panelOverlap: CGFloat = RecipeScreenHeroLayout.panelOverlap
    static let topControlsPadding: CGFloat = RecipeScreenHeroLayout.topControlsPadding
    static let viewIngredientsButtonHeight: CGFloat = 34
    static let viewIngredientsButtonFont: Font = .system(size: 16, weight: .semibold)
}

private struct NutritionMetricView: View {
    let title: String
    let value: String
    let iconName: String

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.xs) {
            Image(iconName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .foregroundStyle(Color("DeepBasil"))
                .padding(.top, 1)

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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    RecipeDetailView(recipeID: RecipeRepository.shared.allRecipes[0].id)
        .environmentObject(FavoritesStore.shared)
        .environmentObject(ShoppingCartStore.shared)
}
