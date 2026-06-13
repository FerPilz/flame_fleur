import SwiftUI

struct AchievementsSheet: View {
    let achievements: [ProfileAchievement]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                header

                VStack(spacing: AppSpacing.xs) {
                    ForEach(achievements) { achievement in
                        achievementRow(achievement)
                    }
                }

                Spacer(minLength: AppSpacing.md)
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
                Text("Achievements")
                    .font(AppTypography.heroTitle)
                    .foregroundStyle(AppColors.primaryText)

                Text("A local snapshot of profile milestones.")
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.secondaryText)
            }

            Spacer()

            IconCircleButton(
                systemName: "xmark",
                accessibilityLabel: "Close achievements",
                size: 30,
                action: { dismiss() }
            )
        }
    }

    private func achievementRow(_ achievement: ProfileAchievement) -> some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.sm
        ) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: achievement.systemImage)
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(accent(for: achievement))
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(AppColors.softOlive))

                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(achievement.title)
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColors.primaryText)

                    Text(achievement.subtitle)
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                }

                Spacer()

                Text(achievement.value)
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.olive)
            }
        }
    }

    private func accent(for achievement: ProfileAchievement) -> Color {
        switch achievement.id {
        case "streak":
            return AppColors.burntOrange
        case "planned":
            return AppColors.olive
        default:
            return AppColors.premiumGold
        }
    }
}

#Preview {
    AchievementsSheet(achievements: SampleUserProfile.profile.achievements)
}
