import SwiftUI

struct AddShoppingSuggestedItemRow: View {
    let item: ShoppingCartItem
    @Binding var quantity: Int
    let isAdded: Bool
    let onAdd: () -> Void

    init(
        item: ShoppingCartItem,
        quantity: Binding<Int>,
        isAdded: Bool,
        onAdd: @escaping () -> Void
    ) {
        self.item = item
        self._quantity = quantity
        self.isAdded = isAdded
        self.onAdd = onAdd
    }

    init(item: ShoppingCartItem, onAdd: @escaping () -> Void) {
        self.init(item: item, quantity: .constant(1), isAdded: false, onAdd: onAdd)
    }

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            ShoppingCartIngredientImageView(item: item, size: 44)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(item.name)
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(3)

                Text(itemDetailText)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(2)

            Menu {
                ForEach(1...10, id: \.self) { value in
                    Button("\(value)") {
                        quantity = value
                    }
                }
            } label: {
                Text("\(quantity)")
                    .font(AppTypography.smallButton)
                    .foregroundStyle(AppColors.deepBasil)
                    .frame(width: 28, height: 34)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous)
                            .fill(AppColors.softOlive)
                    )
            }
            .accessibilityLabel("Quantity")
            .accessibilityValue("\(quantity)")

            PrimaryButton(
                isAdded ? "Added" : "Add",
                style: .olive,
                isFullWidth: false,
                height: 34,
                font: AppTypography.smallButton,
                horizontalPadding: AppSpacing.md,
                action: onAdd
            )
        }
        .frame(minHeight: 58)
    }

    private var itemDetailText: String {
        if item.unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return item.category.title
        }

        return "\(item.unit) - \(item.category.title)"
    }
}

#Preview {
    AddShoppingSuggestedItemRow(
        item: SampleShoppingCartItems.suggestedItems[0],
        quantity: .constant(1),
        isAdded: false,
        onAdd: {}
    )
    .padding()
    .background(AppColors.appBackground)
}
