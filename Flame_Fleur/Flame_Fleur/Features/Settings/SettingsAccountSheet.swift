import SwiftUI

struct SettingsAccountSheet: View {
    let profile: UserProfile

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                header

                SurfaceCard(
                    backgroundColor: AppColors.elevatedCardBackground,
                    cornerRadius: AppRadius.extraLarge,
                    contentPadding: AppSpacing.md
                ) {
                    HStack(spacing: AppSpacing.md) {
                        FoodImagePlaceholder(imageName: profile.profileImageName, style: .circle)
                            .frame(width: 64, height: 64)

                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            Text(profile.name)
                                .font(AppTypography.sectionTitle)
                                .foregroundStyle(AppColors.primaryText)

                            Text(profile.location)
                                .font(AppTypography.metadata)
                                .foregroundStyle(AppColors.olive)
                        }
                    }
                }

                SurfaceCard(
                    backgroundColor: AppColors.cardBackground,
                    borderColor: AppColors.warmBorder,
                    cornerRadius: AppRadius.large,
                    contentPadding: AppSpacing.sm
                ) {
                    Label("Account editing is a local placeholder in this build.", systemImage: "info.circle")
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.secondaryText)
                }

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

    private var header: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text("Account")
                    .font(AppTypography.heroTitle)
                    .foregroundStyle(AppColors.primaryText)

                Text("Profile identity stays local for this prototype.")
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.secondaryText)
            }

            Spacer()

            IconCircleButton(
                systemName: "xmark",
                accessibilityLabel: "Close account details",
                size: 30,
                action: { dismiss() }
            )
        }
    }
}

#Preview {
    SettingsAccountSheet(
        profile: SampleUserProfile.profile
    )
}
