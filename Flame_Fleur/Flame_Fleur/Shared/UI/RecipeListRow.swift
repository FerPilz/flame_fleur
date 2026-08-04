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
        HStack(alignment: .center, spacing: 0) {
            FoodImagePlaceholder(imageName: recipe.imageName, style: .cardTop)
                .frame(width: imageWidth, height: rowHeight)
                .clipped()

            Button(action: onTap) {
                textContent
                    .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, textLeadingPadding)
                .padding(.vertical, textVerticalPadding)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

            actionControl
                .frame(width: 36)
                .padding(.trailing, AppSpacing.sm)
        }
        .frame(maxWidth: .infinity)
        .frame(height: rowHeight)
        .background(AppColors.elevatedCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                .stroke(AppColors.warmBorder, lineWidth: 1)
        )
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text(recipe.title)
                .font(layout == .compact ? AppTypography.compactRecipePreviewTitle : AppTypography.cardTitle)
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(2)
                .truncationMode(.tail)

            Text(layout == .compact ? "Matches all selected ingredients" : recipe.subtitle)
                .font(AppTypography.metadata)
                .foregroundStyle(layout == .compact ? AppColors.basil : AppColors.secondaryText)
                .lineLimit(layout == .compact ? 1 : 2)
                .truncationMode(.tail)

            metadataRow
                .padding(.top, AppSpacing.xxs)
        }
    }

    @ViewBuilder
    private var actionControl: some View {
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

    private var rowHeight: CGFloat {
        layout == .compact ? 104 : 112
    }

    private var imageWidth: CGFloat {
        layout == .compact ? 112 : 120
    }

    private var textLeadingPadding: CGFloat {
        12
    }

    private var textVerticalPadding: CGFloat {
        10
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
