import SwiftUI

struct FoodAnalyticsCard: View {
    let balance: MacroBalance
    let onUpgrade: () -> Void

    var body: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.sm
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "chart.bar.fill")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.olive)

                    Text("Food Analytics")
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColors.primaryText)

                    Spacer()

                    Button(action: onUpgrade) {
                        Text("Upgrade")
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.olive)
                            .padding(.horizontal, AppSpacing.sm)
                            .frame(height: 24)
                            .background(Capsule(style: .continuous).fill(AppColors.softOlive))
                            .overlay(Capsule(style: .continuous).stroke(AppColors.warmBorder, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }

                segmentedMacroBar

                HStack(spacing: AppSpacing.xs) {
                    legendPill(title: "Protein", value: balance.proteinText, tint: AppColors.olive)
                    legendPill(title: "Carbs", value: balance.carbsText, tint: AppColors.burntOrange)
                    legendPill(title: "Fat", value: balance.fatText, tint: AppColors.premiumGold)
                }
            }
        }
    }

    private var segmentedMacroBar: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                segment(width: proxy.size.width * balance.proteinPercentage, tint: AppColors.olive)
                segment(width: proxy.size.width * balance.carbsPercentage, tint: AppColors.burntOrange)
                segment(width: proxy.size.width * balance.fatPercentage, tint: AppColors.premiumGold)
            }
            .frame(width: proxy.size.width, height: 12, alignment: .leading)
            .background(
                Capsule(style: .continuous)
                    .fill(AppColors.cardBackground.opacity(0.72))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(AppColors.warmBorder, lineWidth: 1)
            )
        }
        .frame(height: 12)
    }

    private func segment(width: CGFloat, tint: Color) -> some View {
        Rectangle()
            .fill(tint)
            .frame(width: max(width, 0))
    }

    private func legendPill(title: String, value: String, tint: Color) -> some View {
        HStack(spacing: AppSpacing.xxs) {
            Circle()
                .fill(tint)
                .frame(width: 8, height: 8)

            Text("\(title) \(value)")
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, AppSpacing.xs)
        .frame(height: 24)
        .background(
            Capsule(style: .continuous)
                .fill(AppColors.softOlive.opacity(0.42))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(AppColors.warmBorder, lineWidth: 1)
        )
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    FoodAnalyticsCard(
        balance: MacroBalance(
            summary: NutritionSummary(
                calories: 1_280,
                proteinGrams: 84,
                carbohydrateGrams: 146,
                fatGrams: 48
            )
        ),
        onUpgrade: {}
    )
    .padding()
    .background(AppColors.appBackground)
}
