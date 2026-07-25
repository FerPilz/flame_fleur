import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settingsStore: AppSettingsStore

    @State private var activeSheet: ActiveSettingsSheet?
    @State private var feedbackItems: [Any] = []
    @State private var isFeedbackSheetPresented = false

    private var settings: AppSettings {
        settingsStore.settings
    }

    private var appVersionText: String {
        let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "Version \(shortVersion) (\(buildNumber))"
    }

    var body: some View {
        ZStack {
            AppColors.appBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.md) {
                    header
                    preferencesSection
                    supportSection
                    legalSection
                    versionFooter
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
        .sheet(isPresented: $isFeedbackSheetPresented, onDismiss: { feedbackItems = [] }) {
            if !feedbackItems.isEmpty {
                ActivityView(activityItems: feedbackItems)
            }
        }
    }

    private var header: some View {
        AppHeader(
            leadingActions: [
                AppHeaderAction(
                    systemName: "chevron.left",
                    accessibilityLabel: "Back to profile",
                    action: { dismiss() }
                )
            ]
        )
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
                title: "Cuisine Preferences",
                action: { activeSheet = .cuisineStyle }
            ) {
                SettingsRowValue(settings.cuisineStyle)
            }

            SettingsRowDivider()

            SettingsOptionRow(
                systemImage: "leaf.fill",
                iconBackground: AppColors.softOlive,
                iconForeground: AppColors.olive,
                title: "Dietary Preferences",
                action: { activeSheet = .dietaryPreferences }
            ) {
                SettingsRowValue(settingsStore.dietaryPreferenceSummary)
            }
        }
    }

    private var supportSection: some View {
        SettingsSectionCard(title: "Support") {
            SettingsOptionRow(
                systemImage: "paperplane.fill",
                iconBackground: AppColors.softOrange,
                iconForeground: AppColors.burntOrange,
                title: "Send Feedback",
                action: openFeedbackShareSheet
            ) {
                rowChevron
            }
        }
    }

    private var legalSection: some View {
        SettingsSectionCard(title: "Legal") {
            SettingsOptionRow(
                systemImage: "hand.raised.fill",
                iconBackground: AppColors.softOrange,
                iconForeground: AppColors.burntOrange,
                title: "Privacy Policy",
                action: { activeSheet = .privacyPolicy }
            ) {
                rowChevron
            }

            SettingsRowDivider()

            SettingsOptionRow(
                systemImage: "doc.text.fill",
                iconBackground: AppColors.softOlive,
                iconForeground: AppColors.olive,
                title: "Terms of Use",
                action: { activeSheet = .termsOfUse }
            ) {
                rowChevron
            }
        }
    }

    private var rowChevron: some View {
        Image(systemName: "chevron.right")
            .font(AppTypography.metadata)
            .foregroundStyle(AppColors.tertiaryText)
    }

    private var versionFooter: some View {
        Text(appVersionText)
            .font(AppTypography.metadata)
            .foregroundStyle(AppColors.secondaryText)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, AppSpacing.xxs)
    }

    @ViewBuilder
    private func sheetContent(for sheet: ActiveSettingsSheet) -> some View {
        switch sheet {
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
                title: "Cuisine Preferences",
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

        case .privacyPolicy:
            SettingsDocumentSheet(
                title: "Privacy Policy",
                systemImage: "hand.raised.fill",
                sections: [
                    SettingsDocumentSection(
                        title: "Local-first data",
                        body: "Flame & Fleur keeps your recipes, planner activity, favorites, cart actions, and profile preferences on this device unless you explicitly share content."
                    ),
                    SettingsDocumentSection(
                        title: "Usage insights",
                        body: "Analytics and profile insights are generated from local usage events such as saved recipes, planned meals, viewed recipes, and shopping activity. No cloud analytics or account tracking is used in this MVP."
                    ),
                    SettingsDocumentSection(
                        title: "Shared content",
                        body: "When you share a cart, plan, or recipe, only the content you choose to export is included in that share action."
                    )
                ]
            )

        case .termsOfUse:
            SettingsDocumentSheet(
                title: "Terms of Use",
                systemImage: "doc.text.fill",
                sections: [
                    SettingsDocumentSection(
                        title: "Personal use",
                        body: "This MVP is intended as a personal cooking companion for browsing recipes, planning meals, saving favorites, and organizing shopping lists."
                    ),
                    SettingsDocumentSection(
                        title: "Recipe and planning guidance",
                        body: "Nutrition values, planner insights, and cooking suggestions are informational only and should be reviewed using your own judgment."
                    ),
                    SettingsDocumentSection(
                        title: "Prototype features",
                        body: "Some areas of the app are still evolving. Features that are not fully implemented may change or be removed in future versions."
                    )
                ]
            )
        }
    }

    private func openFeedbackShareSheet() {
        feedbackItems = [
            """
            Flame & Fleur Feedback

            I’d like to share the following feedback:

            -

            Device:
            iOS Version:
            App Version: \(appVersionText)
            """
        ]
        isFeedbackSheetPresented = true
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
}

private enum ActiveSettingsSheet: String, Identifiable {
    case units
    case cuisineStyle
    case dietaryPreferences
    case privacyPolicy
    case termsOfUse

    var id: String { rawValue }

    var detents: Set<PresentationDetent> {
        switch self {
        case .units, .cuisineStyle, .dietaryPreferences:
            return [.large]
        case .privacyPolicy, .termsOfUse:
            return [.medium]
        }
    }
}

private struct SettingsDocumentSection: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}

private struct SettingsDocumentSheet: View {
    let title: String
    let systemImage: String
    let sections: [SettingsDocumentSection]

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

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        ForEach(sections) { section in
                            SurfaceCard(
                                backgroundColor: AppColors.elevatedCardBackground,
                                borderColor: AppColors.warmBorder,
                                cornerRadius: AppRadius.large,
                                contentPadding: AppSpacing.md
                            ) {
                                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                    Text(section.title)
                                        .font(AppTypography.bodyEmphasis)
                                        .foregroundStyle(AppColors.primaryText)

                                    Text(section.body)
                                        .font(AppTypography.callout)
                                        .foregroundStyle(AppColors.secondaryText)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }

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
