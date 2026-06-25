import SwiftUI

struct ProfileView: View {
    let onBack: (() -> Void)?

    @EnvironmentObject private var profileStore: UserProfileStore
    @EnvironmentObject private var favoritesStore: FavoritesStore
    @EnvironmentObject private var userRecipeStore: UserRecipeStore
    @Environment(\.dismiss) private var dismiss

    @State private var isPreferencesEditorPresented = false
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

    private var displayLocation: String? {
        let trimmed = profile.location.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private var displayTagline: String? {
        let trimmed = profile.tagline.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private var displayCuisineStyle: String {
        let trimmed = profile.cuisineStyle.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Not set" : trimmed
    }

    private var displayMemberSinceText: String? {
        guard profile.memberSince.timeIntervalSince1970 > 0 else { return nil }
        return profile.memberSince.formatted(.dateTime.month(.abbreviated).year())
    }

    private var safePreferences: [ProfilePreference] {
        profile.preferences
    }

    private var safeFavoriteCuisines: [FavoriteCuisine] {
        profile.favoriteCuisines
    }

    private var safeAchievements: [ProfileAchievement] {
        profile.achievements
    }

    init(onBack: (() -> Void)? = nil) {
        self.onBack = onBack
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                AppColors.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.md) {
                        header
                        identityHeader
                        profileSummaryCard
                        preferencesSection
                        favoriteCuisinesSection
                        savedRecipesSection
                        achievementsSection
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.xs)
                    .padding(.bottom, AppSpacing.xxxl)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $isPreferencesEditorPresented) {
                PreferencesEditorSheet()
                    .environmentObject(profileStore)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(AppRadius.hero)
            }
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
        HStack {
            IconCircleButton(
                systemName: "chevron.left",
                accessibilityLabel: "Back",
                size: AppTopActionMetrics.buttonSize,
                backgroundColor: AppColors.elevatedCardBackground,
                foregroundColor: AppColors.darkOlive,
                action: goBack
            )
            .frame(width: 44, alignment: .leading)

            Spacer()

            Text("Profile")
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.primaryText)
                .accessibilityAddTraits(.isHeader)

            Spacer()

            IconCircleButton(
                systemName: "gearshape",
                accessibilityLabel: "Open settings",
                size: AppTopActionMetrics.buttonSize,
                backgroundColor: AppColors.elevatedCardBackground,
                foregroundColor: AppColors.darkOlive,
                action: openSettings
            )
            .frame(width: 44, alignment: .trailing)
        }
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

                if let displayLocation {
                    Label(displayLocation, systemImage: "mappin.circle.fill")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.olive)
                        .lineLimit(1)
                }

                if let displayTagline {
                    HStack(spacing: AppSpacing.xxs) {
                        Text(displayTagline)
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.secondaryText)

                        Image(systemName: "checkmark.circle.fill")
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.olive)
                    }
                    .padding(.horizontal, AppSpacing.sm)
                    .frame(height: 26)
                    .background(Capsule(style: .continuous).fill(AppColors.elevatedCardBackground))
                    .overlay(Capsule(style: .continuous).stroke(AppColors.warmBorder, lineWidth: 1))
                }

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
            contentPadding: AppSpacing.sm
        ) {
            VStack(spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.xs) {
                    summaryMetric(
                        title: "Cuisine style",
                        value: displayCuisineStyle,
                        subtitle: nil,
                        systemImage: "fork.knife"
                    )

                    verticalDivider

                    summaryMetric(
                        title: "Favorite meals",
                        value: "\(favoritesStore.favoriteRecipeIDs.count)",
                        subtitle: "Saved",
                        systemImage: "heart.fill"
                    )
                }

                HStack(spacing: AppSpacing.xs) {
                    summaryMetric(
                        title: "Saved recipes",
                        value: "\(userRecipeStore.myRecipes.count)",
                        subtitle: "My Recipes",
                        systemImage: "book.closed"
                    )

                    verticalDivider

                    summaryMetric(
                        title: "Location",
                        value: profile.location,
                        subtitle: nil,
                        systemImage: "mappin.circle.fill"
                    )
                }
            }
        }
    }

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            sectionHeader(title: "My preferences", actionTitle: "Edit") {
                isPreferencesEditorPresented = true
            }

            if safePreferences.isEmpty {
                Text("No preferences selected yet.")
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.secondaryText)
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: AppSpacing.xs),
                        GridItem(.flexible(), spacing: AppSpacing.xs)
                    ],
                    spacing: AppSpacing.xs
                ) {
                    ForEach(safePreferences) { preference in
                        preferenceCard(preference)
                    }
                }
            }
        }
    }

    private var favoriteCuisinesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Favorite cuisines")
                .font(AppTypography.cardTitle)
                .foregroundStyle(AppColors.primaryText)

            if safeFavoriteCuisines.isEmpty {
                Text("Favorite cuisines will appear here.")
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.secondaryText)
            } else {
                HorizontalCarousel(
                    items: safeFavoriteCuisines,
                    visibleItemCount: 3.35,
                    itemSpacing: AppSpacing.xs,
                    cardHeight: 106,
                    edgePadding: 1
                ) { cuisine in
                    cuisineCard(cuisine)
                }
            }
        }
    }

    private var savedRecipesSection: some View {
        let recipes = savedRecipeCarouselItems

        guard !recipes.isEmpty else {
            return AnyView(EmptyView())
        }

        return AnyView(
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Saved Recipes")
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColors.primaryText)

                HorizontalCarousel(
                    items: recipes,
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
        subtitle: String?,
        systemImage: String
    ) -> some View {
        VStack(spacing: AppSpacing.xxs) {
            Image(systemName: systemImage)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.olive)

            Text(title)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Text(value)
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            if let subtitle {
                Text(subtitle)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.tertiaryText)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var verticalDivider: some View {
        Rectangle()
            .fill(AppColors.warmBorder)
            .frame(width: 1, height: 58)
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

    private func preferenceCard(_ preference: ProfilePreference) -> some View {
        Button {
            profileStore.togglePreference(id: preference.id)
        } label: {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: preference.systemImage)
                    .font(AppTypography.caption)
                    .foregroundStyle(preference.isSelected ? AppColors.olive : AppColors.tertiaryText)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(preference.isSelected ? AppColors.softOlive : AppColors.cardBackground))

                Text(preference.title)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, AppSpacing.xs)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                    .fill(AppColors.elevatedCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                    .stroke(preference.isSelected ? AppColors.olive.opacity(0.42) : AppColors.warmBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(preference.isSelected ? .isSelected : [])
    }

    private func cuisineCard(_ cuisine: FavoriteCuisine) -> some View {
        Button {
            profileStore.toggleFavoriteCuisine(id: cuisine.id)
        } label: {
            SurfaceCard(
                backgroundColor: AppColors.elevatedCardBackground,
                borderColor: cuisine.isSelected ? AppColors.olive.opacity(0.62) : AppColors.warmBorder,
                cornerRadius: AppRadius.large,
                contentPadding: AppSpacing.xs
            ) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    ZStack(alignment: .topTrailing) {
                        FoodImagePlaceholder(imageName: cuisine.imageName, style: .card)
                            .frame(height: 58)

                        if cuisine.isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.olive)
                                .background(Circle().fill(AppColors.elevatedCardBackground))
                                .padding(AppSpacing.xxs)
                        }
                    }

                    Text(cuisine.title)
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(cuisine.isSelected ? .isSelected : [])
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

    private var savedRecipeCarouselItems: [Recipe] {
        let favoriteRecipes = favoritesStore.favoriteRecipeIDs.compactMap { recipeRepository.recipe(id: $0) }
        if !favoriteRecipes.isEmpty {
            return Array(favoriteRecipes.prefix(3))
        }

        return Array(userRecipeStore.myRecipes.prefix(3))
    }
}

private enum ProfileRoute: Hashable {
    case recipe(String)
    case ingredients(String)
    case settings
}

#Preview {
    ProfileView()
        .environmentObject(UserProfileStore.shared)
        .environmentObject(FavoritesStore.shared)
        .environmentObject(UserRecipeStore.shared)
        .environmentObject(AppSettingsStore.shared)
}
