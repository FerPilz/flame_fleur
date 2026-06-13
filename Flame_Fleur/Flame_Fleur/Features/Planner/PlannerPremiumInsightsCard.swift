import SwiftUI

struct PlannerPremiumInsightsCard: View {
    let onUpgrade: () -> Void

    var body: some View {
        Button(action: onUpgrade) {
            SurfaceCard(
                backgroundColor: AppColors.softOrange.opacity(0.52),
                cornerRadius: AppRadius.large,
                contentPadding: AppSpacing.xs
            ) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "sparkles")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.premiumGold)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(AppColors.elevatedCardBackground.opacity(0.78)))

                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text("Premium Insights")
                            .font(AppTypography.bodyEmphasis)
                            .foregroundStyle(AppColors.primaryText)

                        Text("Unlock deeper macro trends and nutrition forecasts")
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.secondaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                    }

                    Spacer(minLength: AppSpacing.xs)

                    Text("Upgrade")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.olive)
                        .padding(.horizontal, AppSpacing.sm)
                        .frame(height: 26)
                        .background(Capsule(style: .continuous).fill(AppColors.elevatedCardBackground))
                        .overlay(Capsule(style: .continuous).stroke(AppColors.warmBorder, lineWidth: 1))

                    Image(systemName: "chevron.right")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PlannerPremiumInsightsCard {}
        .padding()
        .background(AppColors.appBackground)
}
