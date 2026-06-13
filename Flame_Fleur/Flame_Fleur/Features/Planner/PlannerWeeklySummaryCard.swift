import SwiftUI

struct PlannerWeeklySummaryCard: View {
    let summary: MealPlanSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("This Week at a Glance")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)

            SurfaceCard(
                backgroundColor: AppColors.elevatedCardBackground,
                cornerRadius: AppRadius.large,
                contentPadding: 3
            ) {
                HStack(spacing: AppSpacing.xs) {
                    metric(
                        systemImage: "flame.fill",
                        value: summary.averageCalories.formatted(),
                        label: "Avg Calories",
                        detail: nil
                    )

                    divider

                    metric(
                        systemImage: "fork.knife",
                        value: "\(summary.mealsPlanned)",
                        label: "Meals Planned",
                        detail: nil
                    )

                    divider

                    metric(
                        systemImage: "target",
                        value: "\(summary.goalScore)/100",
                        label: "Goal Score",
                        detail: summary.goalLabel
                    )
                }
            }
        }
    }

    private func metric(systemImage: String, value: String, label: String, detail: String?) -> some View {
        VStack(alignment: .center, spacing: 1) {
            HStack(spacing: AppSpacing.xxs) {
                Image(systemName: systemImage)
                    .font(AppTypography.tabLabel)
                    .foregroundStyle(AppColors.olive)

                Text(value)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            Text(label)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.82)

            if let detail {
                Text(detail)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.tertiaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(AppColors.warmBorder)
            .frame(width: 1, height: 23)
    }
}

#Preview {
    PlannerWeeklySummaryCard(summary: MealPlannerStore.shared.weeklySummary)
        .padding()
        .background(AppColors.appBackground)
}
