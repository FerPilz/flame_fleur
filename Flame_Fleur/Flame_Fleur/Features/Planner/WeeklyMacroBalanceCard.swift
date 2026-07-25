import SwiftUI

struct WeeklyMacroBalanceCard: View {
    let balance: MacroBalance

    var body: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.sm
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Nutrition Progress")
                            .font(AppTypography.cardTitle)
                            .foregroundStyle(AppColors.primaryText)

                        Text("Selected day")
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.secondaryText)
                    }

                    Spacer()

                    statusBadge
                }

                progressRow(
                    title: "Calories",
                    valueText: balance.caloriesText,
                    targetText: balance.calorieTargetText,
                    progress: balance.calorieProgress
                )

                progressRow(
                    title: "Protein",
                    valueText: balance.proteinText,
                    targetText: balance.proteinTargetText,
                    progress: balance.proteinProgress
                )

                progressRow(
                    title: "Carbs",
                    valueText: balance.carbsText,
                    targetText: balance.carbsTargetText,
                    progress: balance.carbsProgress
                )

                progressRow(
                    title: "Fat",
                    valueText: balance.fatText,
                    targetText: balance.fatTargetText,
                    progress: balance.fatProgress
                )
            }
        }
    }

    private func progressRow(
        title: String,
        valueText: String,
        targetText: String,
        progress: Double
    ) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)

                Spacer()

                Text("\(valueText) / \(targetText)")
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(AppColors.cardBackground.opacity(0.72))

                    Capsule(style: .continuous)
                        .fill(tint(for: title))
                        .frame(width: proxy.size.width * progress)
                }
                .overlay(Capsule(style: .continuous).stroke(AppColors.warmBorder, lineWidth: 1))
            }
            .frame(height: 10)
        }
    }

    private var statusBadge: some View {
        let status = balance.status(for: balance.calories, target: balance.calorieTarget)

        return Text(status.title)
            .font(AppTypography.metadata)
            .foregroundStyle(tint(for: "Calories"))
            .padding(.horizontal, AppSpacing.sm)
            .frame(height: 24)
            .background(Capsule(style: .continuous).fill(AppColors.softOlive))
            .overlay(Capsule(style: .continuous).stroke(AppColors.warmBorder, lineWidth: 1))
    }

    private func tint(for title: String) -> Color {
        switch title {
        case "Calories":
            return AppColors.basilGreen
        case "Protein":
            return AppColors.burntOrange
        case "Carbs":
            return AppColors.premiumGold
        case "Fat":
            return AppColors.darkOlive
        default:
            return AppColors.olive
        }
    }
}

private extension MacroTrendState {
    var title: String {
        switch self {
        case .low:
            return "Low"
        case .onTrack:
            return "On track"
        case .warning:
            return "Warning"
        case .overTarget:
            return "Over target"
        }
    }
}

#Preview {
    WeeklyMacroBalanceCard(
        balance: MealPlannerStore.shared.selectedDayMacroBalance
    )
        .padding()
        .background(AppColors.appBackground)
}
