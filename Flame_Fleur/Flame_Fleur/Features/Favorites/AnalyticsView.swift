import SwiftUI

struct AnalyticsView: View {
    let onBack: (() -> Void)?

    @EnvironmentObject private var usageTrackingStore: UsageTrackingStore
    @EnvironmentObject private var favoritesStore: FavoritesStore
    @EnvironmentObject private var mealPlannerStore: MealPlannerStore
    @Environment(\.dismiss) private var dismiss

    @State private var navigationPath: [AnalyticsRoute] = []

    private let recipeRepository = RecipeRepository.shared

    init(onBack: (() -> Void)? = nil) {
        self.onBack = onBack
    }

    private var summary: AnalyticsSummary {
        AnalyticsSummaryBuilder(
            usageTrackingStore: usageTrackingStore,
            favoritesStore: favoritesStore,
            mealPlannerStore: mealPlannerStore,
            recipeRepository: recipeRepository
        )
        .build()
    }

    private var showsNavigationHeader: Bool {
        onBack != nil
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            AppScreen(
                contentSpacing: AppSpacing.md,
                headerTopPadding: showsNavigationHeader ? AppSpacing.xs : 0,
                contentTopPadding: AppSpacing.sm,
                contentBottomPadding: AppSpacing.xxxl + AppSpacing.lg
            ) {
                if showsNavigationHeader {
                    AppHeader(
                        leadingActions: [
                            AppHeaderAction(systemName: "chevron.left", accessibilityLabel: "Back") {
                                goBack()
                            }
                        ]
                    )
                }
            } content: {
                weeklySnapshotSection
                macroBreakdownSection
                savedRecipesSection
                favoriteCuisineSection
                topIngredientsSection
                topRecipesSection
            }
            .navigationDestination(for: AnalyticsRoute.self) { route in
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

    private var weeklySnapshotSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeaderView("Weekly Snapshot", subtitle: "Based on the meals currently planned in your week.")

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: AppSpacing.sm),
                    GridItem(.flexible(), spacing: AppSpacing.sm)
                ],
                spacing: AppSpacing.sm
            ) {
                snapshotCard(
                    title: "Avg Calories / Day",
                    value: summary.averagePlannedCaloriesPerDay.map(String.init) ?? "—",
                    detail: summary.averagePlannedCaloriesPerDay == nil ? "Plan meals to unlock this." : "Days with planned meals only.",
                    systemImage: "flame.fill",
                    tint: AppColors.burntOrange
                )

                snapshotCard(
                    title: "Planned Dishes",
                    value: "\(summary.plannedDishesThisWeek)",
                    detail: summary.plannedDishesThisWeek == 1 ? "1 meal slot this week." : "\(summary.plannedDishesThisWeek) meal slots this week.",
                    systemImage: "calendar.badge.clock",
                    tint: AppColors.deepBasil
                )

                snapshotCard(
                    title: "Saved Recipes",
                    value: "\(summary.savedRecipeCount)",
                    detail: summary.savedRecipeCount == 1 ? "1 recipe saved." : "\(summary.savedRecipeCount) recipes saved.",
                    systemImage: "bookmark.fill",
                    tint: AppColors.premiumGold
                )

                snapshotCard(
                    title: summary.usesCookedHistory ? "Top Cooked" : "Top Planned",
                    value: summary.topRecipeSnapshot?.recipeTitle ?? "Not enough data",
                    detail: summary.topRecipeSnapshot?.countText ?? "Plan a few repeats to see a winner.",
                    systemImage: "fork.knife.circle.fill",
                    tint: AppColors.olive,
                    compactValue: summary.topRecipeSnapshot == nil
                )
            }
        }
    }

    private var macroBreakdownSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeaderView("Calorie Source Breakdown", subtitle: "Macro calories from your planned recipes this week.")

            if let macroBreakdown = summary.macroSplit {
                SurfaceCard(
                    backgroundColor: AppColors.elevatedCardBackground,
                    cornerRadius: AppRadius.extraLarge,
                    contentPadding: AppSpacing.md
                ) {
                    VStack(spacing: AppSpacing.md) {
                        AnalyticsDonutChart(
                            slices: macroBreakdown.slices,
                            totalCalories: macroBreakdown.totalCalories
                        )
                        .frame(maxWidth: .infinity)

                        VStack(spacing: AppSpacing.xs) {
                            ForEach(macroBreakdown.slices) { slice in
                                macroLegendRow(slice: slice)
                            }
                        }
                    }
                }
            } else {
                emptyCard(
                    icon: "chart.pie",
                    title: "No macro breakdown yet",
                    message: "Plan at least one meal this week to see how protein, carbs, and fat contribute to your calories."
                )
            }
        }
    }

    private var savedRecipesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeaderView("Saved Recipes", subtitle: "Your bookmarked dishes stay here and still open into recipe detail.")

            if summary.savedRecipes.isEmpty {
                emptyCard(
                    icon: "bookmark",
                    title: "No saved recipes yet",
                    message: "Save dishes from Home, Explore, or Planner and they will appear here."
                )
            } else {
                HorizontalCarousel(
                    items: summary.savedRecipes,
                    visibleItemCount: 2.2,
                    cardHeight: 204
                ) { recipe in
                    RecipeCard(
                        recipe: recipe,
                        isFavorite: favoritesStore.isFavorite(recipe.id),
                        imageHeight: 116,
                        action: {
                            navigationPath.append(.recipe(recipe.id))
                        },
                        favoriteAction: {
                            favoritesStore.toggleFavorite(recipe.id)
                        }
                    )
                }
            }
        }
    }

    private var favoriteCuisineSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeaderView("Favorite Cuisine", subtitle: "Most common across your planned meals and saved recipes.")

            if let favoriteCuisine = summary.topCuisine {
                SurfaceCard(
                    backgroundColor: AppColors.elevatedCardBackground,
                    cornerRadius: AppRadius.extraLarge,
                    contentPadding: AppSpacing.md
                ) {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        HStack(spacing: AppSpacing.sm) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.softOlive)
                                    .frame(width: 42, height: 42)

                                Image(systemName: "globe.americas.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(AppColors.deepBasil)
                            }

                            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                                Text(favoriteCuisine.name)
                                    .font(AppTypography.sectionTitle)
                                    .foregroundStyle(AppColors.primaryText)

                                Text(favoriteCuisine.countText)
                                    .font(AppTypography.metadata)
                                    .foregroundStyle(AppColors.secondaryText)
                            }

                            Spacer(minLength: 0)
                        }

                        if !summary.topCuisines.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppSpacing.xs) {
                                    ForEach(summary.topCuisines) { cuisine in
                                        HStack(spacing: AppSpacing.xxs) {
                                            Text(cuisine.name)
                                            Text(cuisine.countText)
                                                .foregroundStyle(AppColors.tertiaryText)
                                        }
                                        .font(AppTypography.metadata)
                                        .padding(.horizontal, AppSpacing.sm)
                                        .frame(height: 32)
                                        .background(Capsule(style: .continuous).fill(AppColors.softOlive.opacity(0.72)))
                                        .overlay(
                                            Capsule(style: .continuous)
                                                .stroke(AppColors.warmBorder, lineWidth: 1)
                                        )
                                    }
                                }
                                .padding(.vertical, 1)
                            }
                            .scrollClipDisabled()
                        }
                    }
                }
            } else {
                emptyCard(
                    icon: "globe",
                    title: "Not enough cuisine data",
                    message: "Save a few recipes or plan a mixed week to surface your strongest cuisine pattern."
                )
            }
        }
    }

    private var topIngredientsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeaderView(
                "Top Ingredients",
                subtitle: ingredientSubtitle
            )

            if summary.topIngredients.isEmpty {
                emptyCard(
                    icon: "leaf",
                    title: "No ingredient insights yet",
                    message: "Once recipes are saved or planned, the ingredients you lean on most will show up here."
                )
            } else {
                SurfaceCard(
                    backgroundColor: AppColors.elevatedCardBackground,
                    cornerRadius: AppRadius.extraLarge,
                    contentPadding: AppSpacing.md
                ) {
                    VStack(spacing: AppSpacing.sm) {
                        ForEach(Array(summary.topIngredients.enumerated()), id: \.element.id) { index, ingredient in
                            ingredientRow(
                                ingredient,
                                maxCount: summary.topIngredients.first?.count ?? 1
                            )

                            if index < summary.topIngredients.count - 1 {
                                Divider()
                                    .overlay(AppColors.warmBorder)
                            }
                        }
                    }
                }
            }
        }
    }

    private var topRecipesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeaderView(
                summary.usesCookedHistory ? "Most Cooked Recipes" : "Most Planned Recipes",
                subtitle: summary.usesCookedHistory
                    ? "Your most repeated cooked dishes."
                    : "Based on how often recipes appear in the planner."
            )

            if summary.topPlannedRecipes.isEmpty {
                emptyCard(
                    icon: "fork.knife",
                    title: "No planned recipe trends yet",
                    message: "Add dishes to the planner and repeated recipes will bubble up here."
                )
            } else {
                SurfaceCard(
                    backgroundColor: AppColors.elevatedCardBackground,
                    cornerRadius: AppRadius.extraLarge,
                    contentPadding: AppSpacing.md
                ) {
                    VStack(spacing: AppSpacing.sm) {
                        ForEach(Array(summary.topPlannedRecipes.prefix(5).enumerated()), id: \.element.id) { index, insight in
                            Button {
                                if let recipeID = insight.recipe?.id ?? insight.recipeID {
                                    navigationPath.append(.recipe(recipeID))
                                }
                            } label: {
                                HStack(spacing: AppSpacing.sm) {
                                    FoodImagePlaceholder(imageName: insight.imageName, style: .thumbnail)
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))

                                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                                        Text(insight.recipeTitle)
                                            .font(AppTypography.cardTitle)
                                            .foregroundStyle(AppColors.primaryText)
                                            .lineLimit(2)

                                        Text(insight.recipeSubtitle ?? "Tracked from your planning activity")
                                            .font(AppTypography.metadata)
                                            .foregroundStyle(AppColors.secondaryText)
                                            .lineLimit(1)
                                    }

                                    Spacer(minLength: AppSpacing.sm)

                                    Text(insight.countText)
                                        .font(AppTypography.metadata)
                                        .foregroundStyle(AppColors.deepBasil)
                                        .padding(.horizontal, AppSpacing.sm)
                                        .frame(height: 28)
                                        .background(Capsule(style: .continuous).fill(AppColors.softOlive))
                                        .overlay(
                                            Capsule(style: .continuous)
                                                .stroke(AppColors.warmBorder, lineWidth: 1)
                                        )
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .disabled(insight.recipe == nil && insight.recipeID == nil)

                            if index < min(summary.topPlannedRecipes.count, 5) - 1 {
                                Divider()
                                    .overlay(AppColors.warmBorder)
                            }
                        }
                    }
                }
            }
        }
    }

    private func snapshotCard(
        title: String,
        value: String,
        detail: String,
        systemImage: String,
        tint: Color,
        compactValue: Bool = false
    ) -> some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.sm
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.14))
                        .frame(width: 34, height: 34)

                    Image(systemName: systemImage)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(tint)
                }

                Text(title)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)

                Text(value)
                    .font(compactValue ? AppTypography.cardTitle : AppTypography.heroTitle)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(compactValue ? 2 : 1)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)

                Text(detail)
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.tertiaryText)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: 154, alignment: .topLeading)
        }
    }

    private func macroLegendRow(slice: MacroSplitSlice) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Circle()
                .fill(color(for: slice.title))
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(slice.title)
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColors.primaryText)

                Text("\(slice.gramsText) • \(slice.caloriesText)")
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)
            }

            Spacer(minLength: AppSpacing.sm)

            Text(slice.percentageText)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.deepBasil)
                .padding(.horizontal, AppSpacing.sm)
                .frame(height: 28)
                .background(Capsule(style: .continuous).fill(AppColors.softOlive))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(AppColors.warmBorder, lineWidth: 1)
                )
        }
    }

    private func ingredientRow(
        _ ingredient: IngredientInsight,
        maxCount: Int
    ) -> some View {
        HStack(spacing: AppSpacing.sm) {
            FoodImagePlaceholder(imageName: ingredient.imageName, style: .circle)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(ingredient.displayName)
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)

                Text(ingredient.countText)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)
            }

            Spacer(minLength: AppSpacing.sm)

            VStack(alignment: .trailing, spacing: AppSpacing.xxs) {
                Text("\(ingredient.count)x")
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.deepBasil)

                GeometryReader { proxy in
                    Capsule(style: .continuous)
                        .fill(AppColors.softOlive.opacity(0.72))
                        .overlay(alignment: .leading) {
                            Capsule(style: .continuous)
                                .fill(AppColors.deepBasil)
                                .frame(
                                    width: proxy.size.width * ingredientUsageProgress(
                                        ingredient.count,
                                        maxCount: maxCount
                                    )
                                )
                        }
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(AppColors.warmBorder, lineWidth: 1)
                        )
                }
                .frame(width: 74, height: 8)
            }
        }
    }

    private var ingredientSubtitle: String {
        switch summary.ingredientSource {
        case .plannedMeals:
            return "Most repeated ingredients from your planned meals."
        case .savedRecipes:
            return "Using your saved recipes until planned meals have enough ingredient data."
        case .viewedRecipes:
            return "Derived from the recipes you spend the most time viewing."
        case .none:
            return "Ingredient trends will appear once recipes are viewed, saved, or planned."
        }
    }

    private func ingredientUsageProgress(_ count: Int, maxCount: Int) -> CGFloat {
        guard maxCount > 0 else {
            return 0
        }

        return CGFloat(Double(count) / Double(maxCount))
    }

    private func emptyCard(
        icon: String,
        title: String,
        message: String
    ) -> some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.extraLarge,
            contentPadding: AppSpacing.md
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(AppColors.softOlive)
                        .frame(width: 38, height: 38)

                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.deepBasil)
                }

                Text(title)
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColors.primaryText)

                Text(message)
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineSpacing(2)
            }
        }
    }

    private func color(for sliceTitle: String) -> Color {
        switch sliceTitle {
        case "Protein":
            return AppColors.deepBasil
        case "Carbs":
            return AppColors.burntOrange
        case "Fat":
            return AppColors.premiumGold
        default:
            return AppColors.olive
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

private enum AnalyticsRoute: Hashable {
    case recipe(String)
    case ingredients(String)
}

private struct AnalyticsDonutChart: View {
    let slices: [MacroSplitSlice]
    let totalCalories: Int

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let lineWidth = max(size * 0.17, 18)

            ZStack {
                Circle()
                    .stroke(AppColors.softOlive.opacity(0.55), lineWidth: lineWidth)

                ForEach(slices) { slice in
                    if slice.percentage > 0 {
                        Circle()
                            .trim(
                                from: startValue(for: slice),
                                to: endValue(for: slice)
                            )
                            .stroke(
                                color(for: slice),
                                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                    }
                }

                VStack(spacing: 2) {
                    Text("\(totalCalories)")
                        .font(AppTypography.heroTitle)
                        .foregroundStyle(AppColors.primaryText)

                    Text("planned cal")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
            .frame(width: size, height: size)
        }
        .frame(width: 164, height: 164)
    }

    private func startValue(for slice: MacroSplitSlice) -> CGFloat {
        let start = slices
            .prefix { $0.id != slice.id }
            .reduce(0.0) { partialResult, currentSlice in
                partialResult + currentSlice.percentage
            }

        return CGFloat(start)
    }

    private func endValue(for slice: MacroSplitSlice) -> CGFloat {
        min(startValue(for: slice) + CGFloat(slice.percentage), 1)
    }

    private func color(for slice: MacroSplitSlice) -> Color {
        switch slice.title {
        case "Protein":
            return AppColors.deepBasil
        case "Carbs":
            return AppColors.burntOrange
        case "Fat":
            return AppColors.premiumGold
        default:
            return AppColors.olive
        }
    }
}

#Preview {
    AnalyticsView()
        .environmentObject(UsageTrackingStore.shared)
        .environmentObject(FavoritesStore.shared)
        .environmentObject(MealPlannerStore.shared)
}
