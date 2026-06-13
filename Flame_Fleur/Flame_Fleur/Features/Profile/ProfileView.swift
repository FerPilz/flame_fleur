import SwiftUI

struct ProfileView: View {
    let onBack: (() -> Void)?

    @EnvironmentObject private var profileStore: UserProfileStore
    @Environment(\.dismiss) private var dismiss

    @State private var isPreferencesEditorPresented = false
    @State private var isAchievementsPresented = false
    @State private var isSettingsPresented = false
    @State private var alert: ProfileAlert?

    private var profile: UserProfile {
        profileStore.profile
    }

    init(onBack: (() -> Void)? = nil) {
        self.onBack = onBack
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.md) {
                        header
                        identityHeader
                        profileSummaryCard
                        preferencesSection
                        favoriteCuisinesSection
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
            .navigationDestination(isPresented: $isSettingsPresented) {
                SettingsView()
            }
            .alert(item: $alert) { alert in
                Alert(
                    title: Text(alert.title),
                    message: Text(alert.message),
                    dismissButton: .default(Text("OK"))
                )
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
            ZStack(alignment: .bottomTrailing) {
                FoodImagePlaceholder(imageName: profile.profileImageName, style: .circle)
                    .frame(width: 92, height: 92)

                Button(action: showPhotoPlaceholder) {
                    Image(systemName: "camera.fill")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.olive)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(AppColors.elevatedCardBackground))
                        .overlay(Circle().stroke(AppColors.warmBorder, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Edit profile photo"))
            }

            VStack(spacing: AppSpacing.xxs) {
                Text(profile.name)
                    .font(AppTypography.heroTitle)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)

                Label(profile.location, systemImage: "mappin.circle.fill")
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.olive)
                    .lineLimit(1)

                HStack(spacing: AppSpacing.xxs) {
                    Text(profile.tagline)
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
        }
        .frame(maxWidth: .infinity)
    }

    private var profileSummaryCard: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.extraLarge,
            contentPadding: AppSpacing.sm
        ) {
            HStack(spacing: AppSpacing.xs) {
                summaryMetric(
                    title: "Cuisine style",
                    value: profile.cuisineStyle,
                    subtitle: nil,
                    systemImage: "fork.knife"
                )

                verticalDivider

                Button(action: showFavoriteMealsPlaceholder) {
                    summaryMetric(
                        title: "Favorite meals",
                        value: "\(profile.favoriteMealsCount)",
                        subtitle: "Recipes",
                        systemImage: "heart.fill"
                    )
                }
                .buttonStyle(.plain)

                verticalDivider

                summaryMetric(
                    title: "Member since",
                    value: profile.memberSince.formatted(.dateTime.month(.abbreviated).year()),
                    subtitle: nil,
                    systemImage: "calendar"
                )
            }
        }
    }

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            sectionHeader(title: "My preferences", actionTitle: "Edit") {
                isPreferencesEditorPresented = true
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: AppSpacing.xs),
                    GridItem(.flexible(), spacing: AppSpacing.xs)
                ],
                spacing: AppSpacing.xs
            ) {
                ForEach(profile.preferences) { preference in
                    preferenceCard(preference)
                }
            }
        }
    }

    private var favoriteCuisinesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Favorite cuisines")
                .font(AppTypography.cardTitle)
                .foregroundStyle(AppColors.primaryText)

            HorizontalCarousel(
                items: profile.favoriteCuisines,
                visibleItemCount: 3.35,
                itemSpacing: AppSpacing.xs,
                cardHeight: 106,
                edgePadding: 1
            ) { cuisine in
                cuisineCard(cuisine)
            }
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            sectionHeader(title: "Achievements", actionTitle: "View all") {
                isAchievementsPresented = true
            }

            HStack(spacing: AppSpacing.xs) {
                ForEach(profile.achievements) { achievement in
                    achievementCard(achievement)
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
        isSettingsPresented = true
    }

    private func goBack() {
        if let onBack {
            onBack()
        } else {
            dismiss()
        }
    }

    private func showPhotoPlaceholder() {
        alert = ProfileAlert(
            title: "Edit Photo",
            message: "Profile photo editing is a local placeholder for now."
        )
    }

    private func showFavoriteMealsPlaceholder() {
        alert = ProfileAlert(
            title: "Favorite Meals",
            message: "Favorite meal navigation is not wired in this pass."
        )
    }
}

private struct ProfileAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

#Preview {
    ProfileView()
        .environmentObject(UserProfileStore.shared)
        .environmentObject(AppSettingsStore.shared)
}
