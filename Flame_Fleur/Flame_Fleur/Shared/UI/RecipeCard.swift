import SwiftUI

struct RecipeCard: View {
    let recipe: Recipe
    let showsCreator: Bool
    let isFavorite: Bool
    let imageHeight: CGFloat
    let action: () -> Void
    let favoriteAction: () -> Void

    init(
        recipe: Recipe,
        showsCreator: Bool = false,
        isFavorite: Bool = false,
        imageHeight: CGFloat = 102,
        action: @escaping () -> Void = {},
        favoriteAction: @escaping () -> Void = {}
    ) {
        self.recipe = recipe
        self.showsCreator = showsCreator
        self.isFavorite = isFavorite
        self.imageHeight = imageHeight
        self.action = action
        self.favoriteAction = favoriteAction
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            ZStack(alignment: .topTrailing) {
                Button(action: action) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        FoodImagePlaceholder(imageName: recipe.imageName, style: .cardTop)
                            .frame(maxWidth: .infinity)
                            .frame(height: imageHeight)
                            .clipped()
                            .clipShape(imageTopShape)
                            .overlay(
                                imageTopShape
                                    .stroke(AppColors.warmBorder.opacity(0.70), lineWidth: 1)
                            )
                            .overlay(alignment: .bottomLeading) {
                                if showsCreator, let creatorName = recipe.creatorName {
                                    creatorOverlay(creatorName)
                                        .padding(AppSpacing.xs)
                                }
                            }

                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            Text(recipe.title)
                                .font(AppTypography.compactRecipeTitle)
                                .foregroundStyle(AppColors.primaryText)
                                .lineLimit(1)
                                .truncationMode(.tail)

                            metadataRow
                        }
                        .padding(.horizontal, AppSpacing.xs)
                        .padding(.bottom, AppSpacing.xs)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .leading)

                FavoriteHeartButton(
                    isFavorite: isFavorite,
                    accessibilityLabel: isFavorite ? "Unsave \(recipe.title)" : "Save \(recipe.title)",
                    action: favoriteAction
                )
                .padding(.top, 3)
                .padding(.trailing, 3)
            }
        }
        .background(
            cardShape
                .fill(AppColors.elevatedCardBackground)
        )
        .clipShape(cardShape)
        .overlay(
            cardShape
                .stroke(AppColors.warmBorder, lineWidth: 1)
        )
    }

    private var metadataRow: some View {
        HStack(spacing: AppSpacing.xxs) {
            Image(systemName: "clock")
                .font(AppTypography.metadata)

            Text("\(recipe.cookingTimeText)  \(recipe.caloriesText)")
                .font(AppTypography.metadata)
                .lineLimit(1)
                .minimumScaleFactor(0.76)
        }
        .foregroundStyle(AppColors.tertiaryText)
    }

    private func creatorOverlay(_ creator: String) -> some View {
        HStack(spacing: AppSpacing.xxs) {
            Circle()
                .fill(AppColors.elevatedCardBackground)
                .frame(width: 13, height: 13)
                .overlay(
                    Circle()
                        .fill(AppColors.softOlive)
                        .padding(2)
                )

            Text(creator)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding(.horizontal, AppSpacing.xs)
        .padding(.vertical, AppSpacing.xxs)
        .background(
            Capsule(style: .continuous)
                .fill(AppColors.elevatedCardBackground.opacity(0.86))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(AppColors.warmBorder.opacity(0.72), lineWidth: 1)
        )
    }

    private var cardCornerRadius: CGFloat {
        AppRadius.medium
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
    }

    private var imageTopShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: cardCornerRadius,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: cardCornerRadius,
            style: .continuous
        )
    }
}

#Preview {
    RecipeCard(
        recipe: RecipeRepository.shared.communityRecipes[0],
        showsCreator: true
    )
    .frame(width: 108)
    .padding()
    .background(AppColors.appBackground)
}
