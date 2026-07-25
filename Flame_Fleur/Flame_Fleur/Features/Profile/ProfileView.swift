import SwiftUI

struct ProfileView: View {
    let onBack: (() -> Void)?

    @EnvironmentObject private var usageTrackingStore: UsageTrackingStore
    @EnvironmentObject private var profileStore: UserProfileStore
    @EnvironmentObject private var favoritesStore: FavoritesStore
    @EnvironmentObject private var mealPlannerStore: MealPlannerStore
    @Environment(\.dismiss) private var dismiss

    @State private var isAchievementsPresented = false
    @State private var navigationPath: [ProfileRoute] = []

    private let recipeRepository = RecipeRepository.shared

    private var profile: UserProfile {
        profileStore.profile
    }

    private var displayName: String {
        let trimmed = profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Profile" : trimmed
    }

    private var displayMemberSinceText: String? {
        guard profile.memberSince.timeIntervalSince1970 > 0 else { return nil }
        return profile.memberSince.formatted(.dateTime.month(.abbreviated).year())
    }

    private var analyticsSummary: AnalyticsSummary {
        AnalyticsSummaryBuilder(
            usageTrackingStore: usageTrackingStore,
            favoritesStore: favoritesStore,
            mealPlannerStore: mealPlannerStore,
            recipeRepository: recipeRepository
        )
        .build()
    }

    private var profileInsights: ProfileInsights {
        ProfileInsightsBuilder(
            analyticsSummary: analyticsSummary,
            usageTrackingStore: usageTrackingStore,
            mealPlannerStore: mealPlannerStore,
            recipeRepository: recipeRepository
        )
        .build()
    }

    private var safeAchievements: [ProfileAchievement] {
        profile.achievements
    }

    init(onBack: (() -> Void)? = nil) {
        self.onBack = onBack
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            AppScreen(
                contentSpacing: AppSpacing.md,
                headerTopPadding: AppSpacing.xs,
                contentTopPadding: AppSpacing.xs,
                contentBottomPadding: AppSpacing.xxxl
            ) {
                header
            } content: {
                identityHeader
                profileSummaryCard
                planningStyleSection
                savedRecipesSection
                achievementsSection
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $isAchievementsPresented) {
                AchievementsSheet(achievements: profile.achievements)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(AppRadius.hero)
            }
            .navigationDestination(for: ProfileRoute.self) { route in
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
                case .settings:
                    SettingsView()
                }
            }
        }
    }

    private var header: some View {
        AppHeader(
            leadingActions: [
                AppHeaderAction(systemName: "chevron.left", accessibilityLabel: "Back", action: goBack)
            ],
            trailingActions: [
                AppHeaderAction(systemName: "gearshape", accessibilityLabel: "Open settings", action: openSettings)
            ]
        )
    }

    private var identityHeader: some View {
        VStack(spacing: AppSpacing.xs) {
            FoodImagePlaceholder(imageName: profile.profileImageName, style: .circle)
                .frame(width: 92, height: 92)

            VStack(spacing: AppSpacing.xxs) {
                Text(displayName)
                    .font(AppTypography.heroTitle)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)

                if let displayMemberSinceText {
                    Text("Member since \(displayMemberSinceText)")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.tertiaryText)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var profileSummaryCard: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.extraLarge,
            contentPadding: AppSpacing.md
        ) {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: AppSpacing.sm),
                    GridItem(.flexible(), spacing: AppSpacing.sm)
                ],
                spacing: AppSpacing.sm
            ) {
                summaryMetric(
                    title: "Saved Recipes",
                    value: "\(profileInsights.savedRecipeCount)"
                )

                summaryMetric(
                    title: "Planned This Week",
                    value: "\(profileInsights.plannedDishesThisWeek)"
                )

                summaryMetric(
                    title: "Favorite Cuisine",
                    value: profileInsights.favoriteCuisine?.name ?? "—",
                    isCompact: true
                )

                summaryMetric(
                    title: "Top Ingredient",
                    value: profileInsights.favoriteIngredient?.displayName ?? "—",
                    isCompact: true
                )
            }
        }
    }

    private var planningStyleSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Cooking Profile")
                .font(AppTypography.cardTitle)
                .foregroundStyle(AppColors.primaryText)

            if let planningStyle = profileInsights.planningStyle {
                SurfaceCard(
                    backgroundColor: AppColors.elevatedCardBackground,
                    cornerRadius: AppRadius.extraLarge,
                    contentPadding: AppSpacing.md
                ) {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        HStack(alignment: .center, spacing: AppSpacing.sm) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.softOlive)
                                    .frame(width: 48, height: 48)

                                Image(systemName: planningStyle.systemImage)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(AppColors.deepBasil)
                            }

                            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                                Text(planningStyle.title)
                                    .font(AppTypography.sectionTitle)
                                    .foregroundStyle(AppColors.primaryText)

                                Text(planningStyle.detail)
                                    .font(AppTypography.callout)
                                    .foregroundStyle(AppColors.secondaryText)
                                    .lineSpacing(2)
                            }
                        }

                        HStack(spacing: AppSpacing.sm) {
                            insightChip(
                                title: profileInsights.topMealType?.name ?? "Meal Rhythm",
                                detail: profileInsights.topMealType?.countText ?? "Not enough data"
                            )

                            if let favoriteCuisine = profileInsights.favoriteCuisine {
                                insightChip(
                                    title: favoriteCuisine.name,
                                    detail: favoriteCuisine.countText
                                )
                            }
                        }
                    }
                }
            } else {
                emptyInsightCard(
                    title: "Insights will sharpen as you cook",
                    message: "Save recipes, view dishes, and plan a few meals to reveal your cooking style."
                )
            }
        }
    }

    private var savedRecipesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Saved Recipes")
                .font(AppTypography.cardTitle)
                .foregroundStyle(AppColors.primaryText)

            if analyticsSummary.savedRecipes.isEmpty {
                emptyInsightCard(
                    title: "No saved recipes yet",
                    message: "Save recipes from Home, Explore, or Planner to build a more personal cooking profile."
                )
            } else {
                HorizontalCarousel(
                    items: analyticsSummary.savedRecipes,
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
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            sectionHeader(title: "Achievements", actionTitle: "View all") {
                isAchievementsPresented = true
            }

            if safeAchievements.isEmpty {
                Text("Achievements will appear once activity is recorded.")
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.secondaryText)
            } else {
                HStack(spacing: AppSpacing.xs) {
                    ForEach(safeAchievements) { achievement in
                        achievementCard(achievement)
                    }
                }
            }
        }
    }

    private func summaryMetric(
        title: String,
        value: String,
        isCompact: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text(value)
                .font(isCompact ? AppTypography.cardTitle : AppTypography.sectionTitle)
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(isCompact ? 2 : 1)
                .minimumScaleFactor(0.72)
                .fixedSize(horizontal: false, vertical: true)

            Text(title)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 74, alignment: .topLeading)
    }

    private func sectionHeader(
        title: String,
        actionTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(AppTypography.cardTitle)
                .foregroundStyle(AppColors.primaryText)

            Spacer()

            Button(actionTitle, action: action)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.olive)
                .buttonStyle(.plain)
        }
    }

    private func insightChip(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(1)

            Text(detail)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(1)
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                .fill(AppColors.softOlive.opacity(0.58))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                .stroke(AppColors.warmBorder, lineWidth: 1)
        )
    }

    private func emptyInsightCard(title: String, message: String) -> some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.extraLarge,
            contentPadding: AppSpacing.md
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack(spacing: AppSpacing.sm) {
                    Circle()
                        .fill(AppColors.softOlive)
                        .frame(width: 38, height: 38)
                        .overlay {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(AppColors.deepBasil)
                        }

                    Text(title)
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColors.primaryText)
                }

                Text(message)
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineSpacing(2)
            }
        }
    }

    private func achievementCard(_ achievement: ProfileAchievement) -> some View {
        SurfaceCard(
            backgroundColor: AppColors.softOlive.opacity(0.76),
            borderColor: AppColors.warmBorder,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.xs
        ) {
            VStack(spacing: AppSpacing.xxs) {
                Image(systemName: achievement.systemImage)
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(achievementAccent(for: achievement))

                Text(achievement.value)
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)

                Text(achievement.subtitle)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 76)
        }
    }

    private func achievementAccent(for achievement: ProfileAchievement) -> Color {
        switch achievement.id {
        case "streak":
            return AppColors.burntOrange
        case "planned":
            return AppColors.olive
        default:
            return AppColors.premiumGold
        }
    }

    private func openSettings() {
        navigationPath.append(.settings)
    }

    private func goBack() {
        if let onBack {
            onBack()
        } else {
            dismiss()
        }
    }
}

private enum ProfileRoute: Hashable {
    case recipe(String)
    case ingredients(String)
    case settings
}

#Preview {
    ProfileView()
        .environmentObject(UsageTrackingStore.shared)
        .environmentObject(UserProfileStore.shared)
        .environmentObject(FavoritesStore.shared)
        .environmentObject(MealPlannerStore.shared)
        .environmentObject(AppSettingsStore.shared)
}
