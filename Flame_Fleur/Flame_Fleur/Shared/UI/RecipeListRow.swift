import SwiftUI

struct RecipeListRow: View {
    enum Layout: Equatable {
        case regular
        case compact
    }

    let recipe: Recipe
    let isFavorite: Bool
    let layout: Layout
    let onFavoriteTap: () -> Void
    let onTap: () -> Void

    init(
        recipe: Recipe,
        isFavorite: Bool,
        layout: Layout = .regular,
        onFavoriteTap: @escaping () -> Void,
        onTap: @escaping () -> Void
    ) {
        self.recipe = recipe
        self.isFavorite = isFavorite
        self.layout = layout
        self.onFavoriteTap = onFavoriteTap
        self.onTap = onTap
    }

    var body: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            borderColor: AppColors.warmBorder,
            cornerRadius: AppRadius.large,
            contentPadding: layout == .compact ? 6 : AppSpacing.xs,
            showsShadow: false
        ) {
            HStack(alignment: .center, spacing: AppSpacing.sm) {
                Button(action: onTap) {
                    HStack(alignment: .center, spacing: AppSpacing.sm) {
                        FoodImagePlaceholder(imageName: recipe.imageName, style: .thumbnail)
                            .frame(width: imageSize, height: imageSize)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))

                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            Text(recipe.title)
                                .font(layout == .compact ? AppTypography.compactRecipePreviewTitle : AppTypography.cardTitle)
                                .foregroundStyle(AppColors.primaryText)
                                .lineLimit(layout == .compact ? 2 : 1)
                                .truncationMode(.tail)

                            Text(layout == .compact ? "Matches all selected ingredients" : recipe.subtitle)
                                .font(AppTypography.metadata)
                                .foregroundStyle(layout == .compact ? AppColors.basil : AppColors.secondaryText)
                                .lineLimit(layout == .compact ? 1 : 2)
                                .truncationMode(.tail)

                            metadataRow
                                .padding(.top, AppSpacing.xxs)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .leading)

                Group {
                    if layout == .compact {
                        Image(systemName: "chevron.right")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.tertiaryText)
                            .accessibilityHidden(true)
                    } else {
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
                .frame(width: 36)
            }
        }
    }

    private var metadataRow: some View {
        HStack(spacing: AppSpacing.xs) {
            metadataItem(systemName: "clock", text: recipe.cookingTimeText)
            if layout == .compact {
                metadataItem(systemName: "chart.bar", text: recipe.difficulty.title)
            } else {
                metadataItem(systemName: "flame", text: recipe.caloriesText)
                metadataItem(systemName: "person.2", text: recipe.servingsText)
            }
        }
    }

    private var imageSize: CGFloat {
        layout == .compact ? 74 : 82
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
