import SwiftUI

struct FoodAnalyticsCard: View {
    let onUpgrade: () -> Void

    private let segments: [FoodAnalyticsSegment] = [
        FoodAnalyticsSegment(title: "Carbs", value: 0.32, color: AppColors.olive),
        FoodAnalyticsSegment(title: "Protein", value: 0.27, color: AppColors.burntOrange),
        FoodAnalyticsSegment(title: "Fiber", value: 0.19, color: AppColors.premiumGold),
        FoodAnalyticsSegment(title: "Other", value: 0.22, color: AppColors.tertiaryText.opacity(0.55))
    ]

    var body: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.xs
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.olive)

                    Text("Food Analytics")
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColors.primaryText)

                    Text("Insights about your cart")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.tertiaryText)

                    Spacer()
                }

                segmentedBar
                    .frame(height: 8)

                HStack(spacing: AppSpacing.xs) {
                    ForEach(segments) { segment in
                        HStack(spacing: AppSpacing.xxs) {
                            Circle()
                                .fill(segment.color)
                                .frame(width: 6, height: 6)

                            Text(segment.title)
                                .font(AppTypography.metadata)
                                .foregroundStyle(AppColors.secondaryText)
                                .lineLimit(1)
                        }
                    }
                }

                Button(action: onUpgrade) {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "sparkle")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.premiumGold)

                        Text("Unlock deeper food analysis and savings.")
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.secondaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)

                        Spacer(minLength: AppSpacing.xs)

                        Text("Upgrade")
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.olive)

                        Image(systemName: "chevron.right")
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.olive)
                    }
                    .padding(.horizontal, AppSpacing.xs)
                    .frame(height: 28)
                    .background(
                        Capsule(style: .continuous)
                            .fill(AppColors.softOrange.opacity(0.55))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var segmentedBar: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                ForEach(segments) { segment in
                    segment.color
                        .frame(width: proxy.size.width * segment.value)
                }
            }
            .clipShape(Capsule(style: .continuous))
            .overlay(
                Capsule(style: .continuous)
                    .stroke(AppColors.warmBorder, lineWidth: 1)
            )
        }
    }
}

private struct FoodAnalyticsSegment: Identifiable {
    let title: String
    let value: CGFloat
    let color: Color

    var id: String { title }
}

#Preview {
    FoodAnalyticsCard {}
        .padding()
        .background(AppColors.appBackground)
}
