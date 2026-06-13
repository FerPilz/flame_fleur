import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var profileStore: UserProfileStore
    @EnvironmentObject private var settingsStore: AppSettingsStore

    @State private var activeSheet: ActiveSettingsSheet?

    private let accountEmail = "julia.martinez@example.com"

    private var profile: UserProfile {
        profileStore.profile
    }

    private var settings: AppSettings {
        settingsStore.settings
    }

    var body: some View {
        ZStack {
            AppColors.appBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.md) {
                    header
                    accountSection
                    preferencesSection
                    privacySection
                    locationSection
                    accountSubscriptionSection
                    appSection
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.xs)
                .padding(.bottom, AppSpacing.xxxl)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $activeSheet) { sheet in
            sheetContent(for: sheet)
                .presentationDetents(sheet.detents)
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(AppRadius.hero)
        }
    }

    private var header: some View {
        ZStack {
            HStack {
                IconCircleButton(
                    systemName: "chevron.left",
                    accessibilityLabel: "Back to profile",
                    size: AppTopActionMetrics.buttonSize,
                    action: { dismiss() }
                )
                .frame(width: 44, alignment: .leading)

                Spacer()

                FoodImagePlaceholder(imageName: "salad", style: .thumbnail)
                    .frame(width: 70, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            }

            Text("Settings")
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.primaryText)
                .accessibilityAddTraits(.isHeader)
        }
        .frame(height: 50)
    }

    private var accountSection: some View {
        SettingsSectionCard(title: "Account") {
            Button {
                activeSheet = .account
            } label: {
                HStack(spacing: AppSpacing.sm) {
                    FoodImagePlaceholder(imageName: profile.profileImageName, style: .circle)
                        .frame(width: 44, height: 44)

                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text(profile.name)
                            .font(AppTypography.bodyEmphasis)
                            .foregroundStyle(AppColors.primaryText)
                            .lineLimit(1)

                        Text(accountEmail)
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.secondaryText)
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.tertiaryText)
                }
                .frame(minHeight: 62)
                .padding(.horizontal, AppSpacing.sm)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private var preferencesSection: some View {
        SettingsSectionCard(title: "Preferences") {
            SettingsOptionRow(
                systemImage: "scalemass.fill",
                iconBackground: AppColors.softOlive,
                iconForeground: AppColors.olive,
                title: "Units",
                action: { activeSheet = .units }
            ) {
                SettingsRowValue(settings.units.displayValue)
            }

            SettingsRowDivider()

            SettingsOptionRow(
                systemImage: "flame.fill",
                iconBackground: AppColors.softOrange,
                iconForeground: AppColors.burntOrange,
                title: "Cuisine style",
                action: { activeSheet = .cuisineStyle }
            ) {
                SettingsRowValue(settings.cuisineStyle)
            }

            SettingsRowDivider()

            SettingsOptionRow(
                systemImage: "leaf.fill",
                iconBackground: AppColors.softOlive,
                iconForeground: AppColors.olive,
                title: "Dietary preferences",
                action: { activeSheet = .dietaryPreferences }
            ) {
                SettingsRowValue(settingsStore.dietaryPreferenceSummary)
            }

            SettingsRowDivider()

            SettingsOptionRow(
                systemImage: "person.2.fill",
                iconBackground: AppColors.premiumGold.opacity(0.16),
                iconForeground: AppColors.premiumGold,
                title: "Default servings",
                action: { activeSheet = .defaultServings }
            ) {
                SettingsRowValue(settingsStore.defaultServingsSummary)
            }
        }
    }

    private var privacySection: some View {
        SettingsSectionCard(title: "Privacy") {
            SettingsOptionRow(
                systemImage: "lock.fill",
                iconBackground: AppColors.softOlive,
                iconForeground: AppColors.olive,
                title: "Profile visibility",
                subtitle: "Choose who can see your profile"
            ) {
                SettingsVisibilityControl(isPrivate: settings.isProfilePrivate) { isPrivate in
                    settingsStore.setProfilePrivate(isPrivate)
                }
            }

            SettingsRowDivider()

            SettingsOptionRow(
                systemImage: "eye.fill",
                iconBackground: AppColors.softOrange,
                iconForeground: AppColors.burntOrange,
                title: "Activity visibility",
                subtitle: "Show your meal plans and recipes"
            ) {
                SettingsToggleControl(isOn: settings.isActivityVisible) {
                    settingsStore.setActivityVisible(!settings.isActivityVisible)
                }
            }
        }
    }

    private var locationSection: some View {
        SettingsSectionCard(title: "Location & Region") {
            SettingsOptionRow(
                systemImage: "mappin.circle.fill",
                iconBackground: AppColors.softOlive,
                iconForeground: AppColors.olive,
                title: "Location",
                action: { activeSheet = .location }
            ) {
                SettingsRowValue(settings.location)
            }
        }
    }

    private var accountSubscriptionSection: some View {
        SettingsSectionCard(title: "Account & Subscription") {
            SettingsOptionRow(
                systemImage: "crown.fill",
                iconBackground: AppColors.premiumGold.opacity(0.16),
                iconForeground: AppColors.premiumGold,
                title: "Manage subscription",
                action: { activeSheet = .subscription }
            ) {
                SettingsRowValue("", badge: "Premium")
            }

            SettingsRowDivider()

            SettingsOptionRow(
                systemImage: "creditcard.fill",
                iconBackground: AppColors.softOlive,
                iconForeground: AppColors.olive,
                title: "Payment methods",
                action: { activeSheet = .payment }
            ) {
                SettingsRowValue("Visa **** 4242")
            }
        }
    }

    private var appSection: some View {
        SettingsSectionCard(title: "App") {
            SettingsOptionRow(
                systemImage: "bell.fill",
                iconBackground: AppColors.softOrange,
                iconForeground: AppColors.burntOrange,
                title: "Notifications"
            ) {
                SettingsToggleControl(isOn: settings.notificationsEnabled) {
                    settingsStore.setNotificationsEnabled(!settings.notificationsEnabled)
                }
            }

            SettingsRowDivider()

            SettingsOptionRow(
                systemImage: "globe",
                iconBackground: AppColors.softOlive,
                iconForeground: AppColors.olive,
                title: "Language",
                action: { activeSheet = .language }
            ) {
                SettingsRowValue(settings.language)
            }
        }
    }

    @ViewBuilder
    private func sheetContent(for sheet: ActiveSettingsSheet) -> some View {
        switch sheet {
        case .account:
            SettingsAccountSheet(profile: profile, email: accountEmail)

        case .units:
            SettingsSelectionSheet(
                title: "Units",
                subtitle: "Choose the measurement system used across recipes.",
                options: MeasurementSystem.allCases.map {
                    SettingsSelectionOption(id: $0.rawValue, title: $0.title, subtitle: $0.detail)
                },
                selectedIDs: [settings.units.rawValue],
                onSelect: { id in
                    guard let units = MeasurementSystem(rawValue: id) else { return }
                    settingsStore.setUnits(units)
                }
            )

        case .cuisineStyle:
            SettingsSelectionSheet(
                title: "Cuisine Style",
                options: cuisineStyleOptions,
                selectedIDs: [settings.cuisineStyle],
                onSelect: { settingsStore.setCuisineStyle($0) }
            )

        case .dietaryPreferences:
            SettingsSelectionSheet(
                title: "Dietary Preferences",
                subtitle: "Select any preferences that should guide local profile UI.",
                options: dietaryPreferenceOptions,
                selectedIDs: Set(settings.dietaryPreferences),
                allowsMultiple: true,
                onSelect: { _ in },
                onSave: { selectedIDs in
                    settingsStore.setDietaryPreferences(
                        dietaryPreferenceOptions.map(\.id).filter { selectedIDs.contains($0) }
                    )
                }
            )

        case .defaultServings:
            SettingsSelectionSheet(
                title: "Default Servings",
                options: servingOptions,
                selectedIDs: [settings.defaultServings],
                onSelect: { settingsStore.setDefaultServings($0) }
            )

        case .location:
            SettingsLocationSheet(currentLocation: settings.location)
                .environmentObject(settingsStore)

        case .subscription:
            SettingsPlaceholderSheet(
                title: "Manage Subscription",
                message: "Subscription management is a placeholder only in this local prototype.",
                systemImage: "crown.fill"
            )

        case .payment:
            SettingsPlaceholderSheet(
                title: "Payment Methods",
                message: "Payment method management is a placeholder only. No payment handling is implemented.",
                systemImage: "creditcard.fill"
            )

        case .language:
            SettingsSelectionSheet(
                title: "Language",
                options: languageOptions,
                selectedIDs: [settings.language],
                onSelect: { settingsStore.setLanguage($0) }
            )
        }
    }

    private var cuisineStyleOptions: [SettingsSelectionOption] {
        [
            "Mediterranean",
            "Mexican",
            "Italian",
            "Asian",
            "Vegetarian",
            "High Protein",
            "Balanced"
        ].map { SettingsSelectionOption(id: $0, title: $0) }
    }

    private var dietaryPreferenceOptions: [SettingsSelectionOption] {
        [
            "Vegetarian",
            "Vegan",
            "Gluten-free",
            "Dairy-free",
            "Low-carb",
            "High-protein",
            "Family-friendly",
            "Quick & Easy"
        ].map { SettingsSelectionOption(id: $0, title: $0) }
    }

    private var servingOptions: [SettingsSelectionOption] {
        ["1", "2", "3", "4", "5", "6+"].map { servings in
            SettingsSelectionOption(
                id: servings,
                title: servings == "1" ? "1 serving" : "\(servings) servings"
            )
        }
    }

    private var languageOptions: [SettingsSelectionOption] {
        ["English", "Spanish", "German", "Polish"].map {
            SettingsSelectionOption(id: $0, title: $0)
        }
    }
}

private enum ActiveSettingsSheet: String, Identifiable {
    case account
    case units
    case cuisineStyle
    case dietaryPreferences
    case defaultServings
    case location
    case subscription
    case payment
    case language

    var id: String { rawValue }

    var detents: Set<PresentationDetent> {
        switch self {
        case .dietaryPreferences:
            return [.medium, .large]
        default:
            return [.medium]
        }
    }
}

private struct SettingsLocationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settingsStore: AppSettingsStore

    @State private var draftLocation: String

    init(currentLocation: String) {
        _draftLocation = State(initialValue: currentLocation)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack(alignment: .top, spacing: AppSpacing.sm) {
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text("Location")
                            .font(AppTypography.heroTitle)
                            .foregroundStyle(AppColors.primaryText)

                        Text("Update the local location label for recipes and profile context.")
                            .font(AppTypography.callout)
                            .foregroundStyle(AppColors.secondaryText)
                            .lineLimit(2)
                    }

                    Spacer()

                    IconCircleButton(
                        systemName: "xmark",
                        accessibilityLabel: "Close location",
                        size: 30,
                        action: { dismiss() }
                    )
                }

                TextField("Location", text: $draftLocation)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.primaryText)
                    .tint(AppColors.olive)
                    .padding(AppSpacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                            .fill(AppColors.elevatedCardBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                            .stroke(AppColors.warmBorder, lineWidth: 1)
                    )

                Spacer(minLength: AppSpacing.md)

                PrimaryButton("Save Location", style: .olive, height: 44) {
                    let trimmedLocation = draftLocation.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmedLocation.isEmpty {
                        settingsStore.setLocation(trimmedLocation)
                    }
                    dismiss()
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, AppSpacing.md)
            .background(AppColors.appBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

private struct SettingsPlaceholderSheet: View {
    let title: String
    let message: String
    let systemImage: String

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.md) {
                IconCircleButton(
                    systemName: "xmark",
                    accessibilityLabel: "Close",
                    size: 30,
                    action: { dismiss() }
                )
                .frame(maxWidth: .infinity, alignment: .trailing)

                Image(systemName: systemImage)
                    .font(AppTypography.heroTitle)
                    .foregroundStyle(AppColors.premiumGold)
                    .frame(width: 58, height: 58)
                    .background(Circle().fill(AppColors.premiumGold.opacity(0.14)))

                Text(title)
                    .font(AppTypography.heroTitle)
                    .foregroundStyle(AppColors.primaryText)

                Text(message)
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)

                Spacer(minLength: AppSpacing.md)

                PrimaryButton("Done", style: .olive, height: 44) {
                    dismiss()
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, AppSpacing.md)
            .background(AppColors.appBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserProfileStore.shared)
        .environmentObject(AppSettingsStore.shared)
}
