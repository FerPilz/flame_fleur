import SwiftUI

struct ShoppingCartSectionView: View {
    let category: ShoppingCartCategory
    let items: [ShoppingCartItem]
    let isCollapsed: Bool
    let onToggleCollapsed: () -> Void
    let onToggleSelection: (ShoppingCartItem) -> Void
    let onIncrement: (ShoppingCartItem) -> Void
    let onDecrement: (ShoppingCartItem) -> Void
    let onUpdateStore: (ShoppingCartItem, ShoppingStoreOption) -> Void

    var body: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.large,
            contentPadding: 0
        ) {
            VStack(spacing: 0) {
                Button(action: onToggleCollapsed) {
                    HStack(spacing: AppSpacing.xs) {
                        CartCategoryIconView(category: category, size: 32)
                            .frame(width: 32, height: 32)

                        Text(category.title)
                            .font(AppTypography.cardTitle)
                            .foregroundStyle(AppColors.primaryText)

                        Text("\(items.count)")
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.secondaryText)
                            .padding(.horizontal, AppSpacing.xs)
                            .frame(height: 20)
                            .background(Capsule(style: .continuous).fill(AppColors.softOlive))

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.secondaryText)
                            .rotationEffect(.degrees(isCollapsed ? -90 : 0))
                    }
                    .padding(.horizontal, AppSpacing.xs)
                    .frame(height: 38)
                }
                .buttonStyle(.plain)

                if !isCollapsed {
                    ForEach(items) { item in
                        Rectangle()
                            .fill(AppColors.warmBorder.opacity(0.72))
                            .frame(height: 1)
                            .padding(.leading, AppSpacing.sm)

                        ShoppingCartItemRow(
                            item: item,
                            onToggleSelection: { onToggleSelection(item) },
                            onIncrement: { onIncrement(item) },
                            onDecrement: { onDecrement(item) },
                            onUpdateStore: { option in onUpdateStore(item, option) }
                        )
                    }
                }
            }
        }
    }

}

#Preview {
    ShoppingCartSectionView(
        category: .produce,
        items: SampleShoppingCartItems.currentWeek.filter { $0.category == .produce },
        isCollapsed: false,
        onToggleCollapsed: {},
        onToggleSelection: { _ in },
        onIncrement: { _ in },
        onDecrement: { _ in },
        onUpdateStore: { _, _ in }
    )
    .padding()
    .background(AppColors.appBackground)
}
