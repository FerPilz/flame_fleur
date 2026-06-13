import SwiftUI

struct PreferencesEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var profileStore: UserProfileStore

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                header

                VStack(spacing: AppSpacing.xs) {
                    ForEach(profileStore.profile.preferences) { preference in
                        preferenceRow(preference)
                    }
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
                Text("Edit Preferences")
                    .font(AppTypography.heroTitle)
                    .foregroundStyle(AppColors.primaryText)

                Text("Tune the local profile signals used by this mock experience.")
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(2)
            }

            Spacer()

            IconCircleButton(
                systemName: "xmark",
                accessibilityLabel: "Close preferences",
                size: 30,
                action: { dismiss() }
            )
        }
    }

    private func preferenceRow(_ preference: ProfilePreference) -> some View {
        Button {
            profileStore.togglePreference(id: preference.id)
        } label: {
            SurfaceCard(
                backgroundColor: AppColors.elevatedCardBackground,
                borderColor: preference.isSelected ? AppColors.olive.opacity(0.50) : AppColors.warmBorder,
                cornerRadius: AppRadius.large,
                contentPadding: AppSpacing.sm
            ) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: preference.systemImage)
                        .font(AppTypography.caption)
                        .foregroundStyle(preference.isSelected ? AppColors.olive : AppColors.tertiaryText)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(preference.isSelected ? AppColors.softOlive : AppColors.cardBackground))

                    Text(preference.title)
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColors.primaryText)

                    Spacer()

                    Image(systemName: preference.isSelected ? "checkmark.circle.fill" : "circle")
                        .font(AppTypography.sectionTitle)
                        .foregroundStyle(preference.isSelected ? AppColors.olive : AppColors.tertiaryText)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(preference.isSelected ? .isSelected : [])
    }
}

#Preview {
    PreferencesEditorSheet()
        .environmentObject(UserProfileStore.shared)
}
