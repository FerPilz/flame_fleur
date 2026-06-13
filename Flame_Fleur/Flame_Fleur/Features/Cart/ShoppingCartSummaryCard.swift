import SwiftUI

struct ShoppingCartSummaryCard: View {
    let totalEstimatedCost: Double
    let totalItemCount: Int
    let categoryCount: Int

    var body: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.xs
        ) {
            HStack(spacing: AppSpacing.xs) {
                metric(
                    title: "Est. total cost",
                    value: ShoppingCartStore.currencyString(totalEstimatedCost),
                    footnote: "USD"
                )

                verticalDivider

                metric(
                    title: "Total items",
                    value: "\(totalItemCount)",
                    footnote: "items"
                )

                verticalDivider

                metric(
                    title: "Categories",
                    value: "\(categoryCount)",
                    footnote: "groups"
                )
            }
        }
    }

    private func metric(title: String, value: String, footnote: String) -> some View {
        VStack(alignment: .center, spacing: 1) {
            Text(title)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Text(value)
                .font(title == "Est. total cost" ? AppTypography.sectionTitle : AppTypography.bodyEmphasis)
                .foregroundStyle(AppColors.olive)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Text(footnote)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.tertiaryText)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    private var verticalDivider: some View {
        Rectangle()
            .fill(AppColors.warmBorder)
            .frame(width: 1, height: 34)
    }
}

#Preview {
    ShoppingCartSummaryCard(totalEstimatedCost: 68.47, totalItemCount: 24, categoryCount: 6)
        .padding()
        .background(AppColors.appBackground)
}
