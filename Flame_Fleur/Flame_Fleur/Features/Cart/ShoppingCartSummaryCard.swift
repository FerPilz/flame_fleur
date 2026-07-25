import SwiftUI

struct ShoppingCartSummaryCard: View {
    let totalItemCount: Int
    let categoryCount: Int
    let selectedItemCount: Int

    var body: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.xs
        ) {
            HStack(spacing: AppSpacing.xs) {
                metric(
                    title: "Total items",
                    value: "\(totalItemCount)",
                    footnote: totalItemCount == 1 ? "item" : "items"
                )

                verticalDivider

                metric(
                    title: "Categories",
                    value: "\(categoryCount)",
                    footnote: categoryCount == 1 ? "group" : "groups"
                )

                verticalDivider

                metric(
                    title: "Checked",
                    value: "\(selectedItemCount)",
                    footnote: selectedItemCount == 1 ? "item" : "items"
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
                .font(AppTypography.bodyEmphasis)
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
    ShoppingCartSummaryCard(totalItemCount: 24, categoryCount: 6, selectedItemCount: 3)
        .padding()
        .background(AppColors.appBackground)
}
