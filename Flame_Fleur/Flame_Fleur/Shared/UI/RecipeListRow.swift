import SwiftUI

struct RecipeListRow: View {
    let recipe: Recipe
    let isFavorite: Bool
    let onFavoriteTap: () -> Void
    let onTap: () -> Void

    var body: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            borderColor: AppColors.warmBorder,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.xs,
            showsShadow: false
        ) {
            HStack(alignment: .center, spacing: AppSpacing.sm) {
                FoodImagePlaceholder(imageName: recipe.imageName, style: .thumbnail)
                    .frame(width: 82, height: 82)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))

                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(recipe.title)
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Text(recipe.subtitle)
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(2)
                        .truncationMode(.tail)

                    metadataRow
                        .padding(.top, AppSpacing.xxs)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                IconCircleButton(
                    systemName: isFavorite ? "heart.fill" : "heart",
                    accessibilityLabel: isFavorite ? "Unsave \(recipe.title)" : "Save \(recipe.title)",
                    size: 28,
                    backgroundColor: AppColors.elevatedCardBackground,
                    foregroundColor: isFavorite ? AppColors.error : AppColors.burntOrange,
                    action: onFavoriteTap
                )
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
        .onTapGesture(perform: onTap)
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
                .font(AppTypography.tabLabel)

            Text(text)
                .font(AppTypography.metadata)
                .lineLimit(1)
        }
        .foregroundStyle(AppColors.tertiaryText)
    }
}

#Preview {
    RecipeListRow(
        recipe: RecipeRepository.shared.recipes(forSubcategoryID: "meat-seafood-fish").first ?? RecipeRepository.shared.allRecipes[0],
        isFavorite: true,
        onFavoriteTap: {},
        onTap: {}
    )
    .padding()
    .background(AppColors.appBackground)
}
