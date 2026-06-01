import SwiftUI

struct RecipeCard: View {
    let recipe: Recipe
    let showsCreator: Bool
    let isFavorite: Bool
    let favoriteAction: () -> Void

    init(
        recipe: Recipe,
        showsCreator: Bool = false,
        isFavorite: Bool = false,
        favoriteAction: @escaping () -> Void = {}
    ) {
        self.recipe = recipe
        self.showsCreator = showsCreator
        self.isFavorite = isFavorite
        self.favoriteAction = favoriteAction
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            ZStack(alignment: .topTrailing) {
                FoodImagePlaceholder(imageName: recipe.imageName, style: .card)
                    .frame(maxWidth: .infinity)
                    .frame(height: 102)
                    .clipped()
                    .overlay(alignment: .bottomLeading) {
                        if showsCreator, let creatorName = recipe.creatorName {
                            creatorOverlay(creatorName)
                                .padding(AppSpacing.xs)
                        }
                    }

                IconCircleButton(
                    systemName: isFavorite ? "heart.fill" : "heart",
                    accessibilityLabel: isFavorite ? "Unsave \(recipe.title)" : "Save \(recipe.title)",
                    size: 24,
                    backgroundColor: AppColors.elevatedCardBackground.opacity(0.92),
                    foregroundColor: isFavorite ? AppColors.error : AppColors.darkOlive,
                    action: favoriteAction
                )
                .padding(5)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(recipe.title)
                    .font(AppTypography.smallTitle)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .truncationMode(.tail)

                metadataRow
            }
            .padding(.horizontal, AppSpacing.xs)
            .padding(.bottom, AppSpacing.xs)
        }
        .background(
            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                .fill(AppColors.elevatedCardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                .stroke(AppColors.warmBorder, lineWidth: 1)
        )
    }

    private var metadataRow: some View {
        HStack(spacing: AppSpacing.xxs) {
            Image(systemName: "clock")
                .font(.system(size: 9, weight: .semibold))

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
