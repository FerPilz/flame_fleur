import SwiftUI

struct RecipeInfoCarousel: View {
    let recipe: Recipe

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: RecipeInfoCarouselLayout.itemSpacing) {
                ForEach(Array(metrics.enumerated()), id: \.element.id) { index, metric in
                    HStack(alignment: .center, spacing: RecipeInfoCarouselLayout.itemContentSpacing) {
                        metric.iconView

                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            Text(metric.title)
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.secondaryText)
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)

                            Text(metric.value)
                                .font(AppTypography.bodyEmphasis)
                                .foregroundStyle(AppColors.primaryText)
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                        }

                        if index < metrics.count - 1 {
                            Rectangle()
                                .fill(AppColors.warmBorder)
                                .frame(width: 2, height: RecipeInfoCarouselLayout.dividerHeight)
                                .padding(.leading, RecipeInfoCarouselLayout.spaceBeforeDivider)
                        }
                    }
                    .padding(.leading, RecipeInfoCarouselLayout.itemLeadingPadding)
                    .padding(.trailing, RecipeInfoCarouselLayout.itemTrailingPadding)
                    .frame(minHeight: RecipeInfoCarouselLayout.itemHeight)
                }
            }
            .padding(.horizontal, RecipeInfoCarouselLayout.carouselSidePadding)
        }
    }

    private var metrics: [RecipeInfoMetric] {
        [
            RecipeInfoMetric(title: "Prep", value: "\(recipe.prepMinutes) min", icon: .asset("PrepTimeIcon"), iconSize: 32, isLast: false),
            RecipeInfoMetric(title: "Cook", value: "\(recipe.cookMinutes) min", icon: .asset("CookIcon"), iconSize: 32, isLast: false),
            RecipeInfoMetric(title: "Calories", value: recipe.caloriesText, icon: .system("flame"), iconSize: 24, isLast: false),
            RecipeInfoMetric(title: "Serves", value: recipe.servingsText, icon: .system("person.2"), iconSize: 26, isLast: false),
            RecipeInfoMetric(
                title: "Difficulty",
                value: recipe.difficulty.title,
                icon: .asset("Difficulty"),
                iconSize: 40,
                isLast: true
            )
        ]
    }
}

private enum RecipeInfoIcon {
    case system(String)
    case asset(String)
}

private struct RecipeInfoMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let icon: RecipeInfoIcon
    let iconSize: CGFloat
    let isLast: Bool

    @ViewBuilder
    var iconView: some View {
        switch icon {
        case let .system(name):
            Image(systemName: name)
                .font(.system(size: iconSize, weight: .regular))
                .foregroundStyle(Color("DeepBasil"))
        case let .asset(name):
            Image(name)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .foregroundStyle(Color("DeepBasil"))
        }
    }
}

private enum RecipeInfoCarouselLayout {
    static let itemHeight: CGFloat = 68
    static let itemSpacing: CGFloat = 4
    static let itemContentSpacing: CGFloat = 4
    static let itemLeadingPadding: CGFloat = 4
    static let itemTrailingPadding: CGFloat = 4
    static let spaceBeforeDivider: CGFloat = 8
    static let dividerHeight: CGFloat = 48
    static let carouselSidePadding: CGFloat = 0
}

#Preview {
    RecipeInfoCarousel(recipe: RecipeRepository.shared.allRecipes[0])
        .padding()
        .background(AppColors.appBackground)
}
