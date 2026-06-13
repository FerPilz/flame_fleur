import SwiftUI

struct WeeklyMacroBalanceCard: View {
    let balance: MacroBalance

    var body: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.xs
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                HStack {
                    Text("Weekly Macro Balance")
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColors.primaryText)

                    Spacer()

                    Text("Carbs \(percentageText(balance.carbsPercentage))")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                }

                macroBar
                    .frame(height: 10)

                HStack(spacing: AppSpacing.xs) {
                    legend("Carbs", value: balance.carbsGrams, color: AppColors.olive)
                    legend("Protein", value: balance.proteinGrams, color: AppColors.premiumGold)
                    legend("Fat", value: balance.fatGrams, color: AppColors.burntOrange)
                }
            }
        }
    }

    private var macroBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(AppColors.cardBackground)

                if balance.totalGrams > 0 {
                    HStack(spacing: 0) {
                        AppColors.olive
                            .frame(width: proxy.size.width * balance.carbsPercentage)
                        AppColors.premiumGold
                            .frame(width: proxy.size.width * balance.proteinPercentage)
                        AppColors.burntOrange
                            .frame(width: proxy.size.width * balance.fatPercentage)
                    }
                    .clipShape(Capsule(style: .continuous))
                }
            }
            .overlay(Capsule(style: .continuous).stroke(AppColors.warmBorder, lineWidth: 1))
        }
    }

    private func legend(_ title: String, value: Int, color: Color) -> some View {
        HStack(spacing: AppSpacing.xxs) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)

            Text("\(title) \(value)g")
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(1)
        }
    }

    private func percentageText(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }
}

#Preview {
    WeeklyMacroBalanceCard(balance: MealPlannerStore.shared.macroBalance)
        .padding()
        .background(AppColors.appBackground)
}
