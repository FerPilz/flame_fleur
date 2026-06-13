import SwiftUI

struct HeroRecipeCard: View {
    let recipe: Recipe
    let actionTitle: String
    let isFavorite: Bool
    let action: () -> Void
    let favoriteAction: () -> Void

    init(
        recipe: Recipe,
        actionTitle: String = "View Recipe",
        isFavorite: Bool = false,
        action: @escaping () -> Void = {},
        favoriteAction: @escaping () -> Void = {}
    ) {
        self.recipe = recipe
        self.actionTitle = actionTitle
        self.isFavorite = isFavorite
        self.action = action
        self.favoriteAction = favoriteAction
    }

    var body: some View {
        SurfaceCard(
            backgroundColor: AppColors.cardBackground,
            borderColor: AppColors.warmBorder,
            cornerRadius: AppRadius.extraLarge,
            contentPadding: AppSpacing.xs,
            showsShadow: false
        ) {
            GeometryReader { proxy in
                let imageWidth = min(190, max(138, proxy.size.width * 0.49))
                let imageHeight = max(132, proxy.size.height - AppSpacing.xs)
                let textWidth = max(116, proxy.size.width - imageWidth - AppSpacing.sm)

                ZStack(alignment: .topTrailing) {
                    Button(action: action) {
                        HStack(alignment: .center, spacing: AppSpacing.sm) {
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text(recipe.title)
                                    .font(AppTypography.heroTitle)
                                    .foregroundStyle(AppColors.primaryText)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)

                                Text(recipe.subtitle)
                                    .font(AppTypography.metadata)
                                    .foregroundStyle(AppColors.secondaryText)
                                    .lineLimit(1)

                                metadataRow
                                    .padding(.top, 1)

                                ctaLabel
                                    .padding(.top, AppSpacing.xs)
                            }
                            .frame(width: textWidth, alignment: .leading)

                            FoodImagePlaceholder(imageName: recipe.imageName, style: .hero)
                                .frame(width: imageWidth, height: imageHeight)
                                .clipped()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    IconCircleButton(
                        systemName: isFavorite ? "heart.fill" : "heart",
                        accessibilityLabel: isFavorite ? "Unsave \(recipe.title)" : "Save \(recipe.title)",
                        size: 28,
                        backgroundColor: AppColors.elevatedCardBackground.opacity(0.92),
                        foregroundColor: isFavorite ? AppColors.error : AppColors.darkOlive,
                        action: favoriteAction
                    )
                    .padding(AppSpacing.xs)
                }
            }
            .frame(height: 155)
        }
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

    private func metadataItem(systemName: String, text: String) -> some View {
        HStack(spacing: 2) {
            Image(systemName: systemName)
                .font(AppTypography.metadata)

            Text(text)
                .font(AppTypography.metadata)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .foregroundStyle(AppColors.tertiaryText)
    }
}

#Preview {
    HeroRecipeCard(
        recipe: RecipeRepository.shared.featuredRecipes[0]
    )
    .padding()
    .background(AppColors.appBackground)
}
