import SwiftUI

struct HeroRecipeCard: View {
    let recipe: Recipe
    let actionTitle: String
    let isFavorite: Bool
    let imageWidthScale: CGFloat
    let cardHeight: CGFloat
    let action: () -> Void
    let favoriteAction: () -> Void

    init(
        recipe: Recipe,
        actionTitle: String = "View Recipe",
        isFavorite: Bool = false,
        imageWidthScale: CGFloat = 1,
        cardHeight: CGFloat = 155,
        action: @escaping () -> Void = {},
        favoriteAction: @escaping () -> Void = {}
    ) {
        self.recipe = recipe
        self.actionTitle = actionTitle
        self.isFavorite = isFavorite
        self.imageWidthScale = imageWidthScale
        self.cardHeight = cardHeight
        self.action = action
        self.favoriteAction = favoriteAction
    }

    var body: some View {
        GeometryReader { proxy in
            let sectionWidth = proxy.size.width * 0.5

            ZStack(alignment: .topTrailing) {
                Button(action: action) {
                    HStack(spacing: 0) {
                        textContent
                            .frame(width: sectionWidth, height: cardHeight, alignment: .leading)
                            .background(AppColors.elevatedCardBackground)

                        FoodImagePlaceholder(imageName: recipe.imageName, style: .cardTop)
                            .frame(width: sectionWidth, height: cardHeight)
                            .clipped()
                    }
                    .frame(width: proxy.size.width, height: cardHeight)
                    .contentShape(cardShape)
                }
                .buttonStyle(.plain)

                FavoriteHeartButton(
                    isFavorite: isFavorite,
                    accessibilityLabel: isFavorite ? "Unsave \(recipe.title)" : "Save \(recipe.title)",
                    action: favoriteAction
                )
                .padding(.top, 3)
                .padding(.trailing, 3)
            }
            .frame(width: proxy.size.width, height: cardHeight)
            .background(AppColors.cardBackground)
            .clipShape(cardShape)
            .overlay(
                cardShape
                    .stroke(AppColors.warmBorder, lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
    }

    private var ctaLabel: some View {
        HStack(spacing: AppSpacing.xxs) {
            Text(actionTitle)
                .font(AppTypography.smallButton)

            Image(systemName: "chevron.right")
                .font(.caption2.weight(.semibold))
        }
        .foregroundStyle(AppColors.elevatedCardBackground)
        .padding(.horizontal, AppSpacing.sm)
        .frame(height: 32)
        .background(
            Capsule(style: .continuous)
                .fill(AppColors.burntOrange)
        )
    }

    private var metadataRow: some View {
        HStack(spacing: AppSpacing.xs) {
            metadataItem(systemName: "clock", text: recipe.cookingTimeText)
            metadataItem(systemName: "flame", text: recipe.caloriesText)
            metadataItem(systemName: "person.2", text: recipe.servingsText)
        }
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(recipe.title)
                .font(AppTypography.heroTitle)
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(recipe.subtitle)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.primaryText.opacity(0.68))
                .lineLimit(1)

            metadataRow
                .padding(.top, 1)

            Spacer(minLength: AppSpacing.xxs)

            ctaLabel
        }
        .padding(AppSpacing.md)
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous)
    }

    private func metadataItem(systemName: String, text: String) -> some View {
        HStack(spacing: 2) {
            Image(systemName: systemName)
                .font(AppTypography.metadata)

            Text(text)
                .font(AppTypography.metadata)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .foregroundStyle(AppColors.primaryText.opacity(0.70))
    }
}

#Preview {
    HeroRecipeCard(
        recipe: RecipeRepository.shared.featuredRecipes[0]
    )
    .padding()
    .background(AppColors.appBackground)
}
