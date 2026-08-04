import SwiftUI

struct IngredientOptionCell: View {
    enum Layout {
        case compact
        case grid
    }

    let ingredient: ShoppingIngredientCatalogItem
    let isSelected: Bool
    let layout: Layout
    let action: () -> Void

    init(
        ingredient: ShoppingIngredientCatalogItem,
        isSelected: Bool,
        layout: Layout = .grid,
        action: @escaping () -> Void
    ) {
        self.ingredient = ingredient
        self.isSelected = isSelected
        self.layout = layout
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                ingredientImage

                Text(ingredient.displayName)
                    .font(AppTypography.exploreIngredientLabel)
                    .foregroundStyle(isSelected ? AppColors.elevatedCardBackground : AppColors.primaryText)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .minimumScaleFactor(0.9)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isSelected ? AppColors.elevatedCardBackground : AppColors.tertiaryText)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, horizontalPadding)
            .frame(maxWidth: .infinity, minHeight: cellHeight, maxHeight: cellHeight, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isSelected ? AppColors.basilGreen : AppColors.elevatedCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(isSelected ? AppColors.deepBasil : AppColors.warmBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isSelected ? "\(ingredient.displayName) selected" : "Select \(ingredient.displayName)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var ingredientImage: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .overlay(
                    Circle()
                        .stroke(AppColors.warmBorder.opacity(0.65), lineWidth: 1)
                )

            FoodImagePlaceholder(imageName: ingredient.imageName, style: .circle)
                .frame(width: renderedImageSize, height: renderedImageSize)
                .clipShape(Circle())
        }
        .frame(width: imageContainerSize, height: imageContainerSize)
        .accessibilityHidden(true)
    }

    private var renderedImageSize: CGFloat {
        29
    }

    private var imageContainerSize: CGFloat {
        33
    }

    private var cellHeight: CGFloat {
        44
    }

    private var horizontalPadding: CGFloat {
        8
    }

    private var cornerRadius: CGFloat {
        10
    }
}

#Preview {
    IngredientOptionCell(
        ingredient: SampleShoppingIngredientCatalog.all.first ?? ShoppingIngredientCatalogItem(
            id: "preview",
            displayName: "Basil",
            normalizedName: "basil",
            category: "Produce",
            defaultUnit: "bunch",
            estimatedPrice: 0,
            imageName: nil
        ),
        isSelected: true
    ) {}
    .padding()
    .background(AppColors.appBackground)
}
