import SwiftUI

struct AddShoppingSuggestedItemRow: View {
    let item: ShoppingCartItem
    let selectedQuantity: Int
    let selectedStore: ShoppingStoreOption
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onUpdateStore: (ShoppingStoreOption) -> Void

    var body: some View {
        HStack(spacing: AppSpacing.xxs) {
            FoodImagePlaceholder(imageName: item.imageName, style: .thumbnail)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(item.name)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(3)

                Text(item.unit)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(1)
            }
            .frame(minWidth: 82, maxWidth: .infinity, alignment: .leading)
            .layoutPriority(2)

            categoryBadge

            quantityControl

            storeMenu
        }
        .frame(minHeight: 44)
    }

    private var categoryBadge: some View {
        Text(item.category.title)
            .font(AppTypography.metadata)
            .foregroundStyle(AppColors.olive)
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .padding(.horizontal, AppSpacing.xxs)
            .frame(width: 50, height: 22)
            .background(
                Capsule(style: .continuous)
                    .fill(categoryBadgeColor)
            )
    }

    private var categoryBadgeColor: Color {
        switch item.category {
        case .produce:
            return AppColors.softOlive
        case .dairy:
            return AppColors.softOrange
        case .protein:
            return AppColors.softOrange.opacity(0.72)
        case .pantry, .frozen, .bakery, .other:
            return AppColors.cardBackground
        }
    }

    private var quantityControl: some View {
        HStack(spacing: AppSpacing.xxs) {
            Button(action: onDecrement) {
                Image(systemName: "minus")
                    .font(AppTypography.metadata)
                    .frame(width: 15, height: 18)
            }

            Text("\(selectedQuantity)")
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.primaryText)
                .frame(width: 12)

            Button(action: onIncrement) {
                Image(systemName: "plus")
                    .font(AppTypography.metadata)
                    .frame(width: 15, height: 18)
            }
        }
        .foregroundStyle(AppColors.olive)
        .padding(.horizontal, AppSpacing.xxs)
        .frame(width: 50, height: 24)
        .background(Capsule(style: .continuous).fill(AppColors.elevatedCardBackground))
        .overlay(Capsule(style: .continuous).stroke(AppColors.warmBorder, lineWidth: 1))
        .buttonStyle(.plain)
    }

    private var storeMenu: some View {
        Menu {
            ForEach(ShoppingStoreOption.allCases) { option in
                Button(option.displayName) {
                    onUpdateStore(option)
                }
            }
        } label: {
            HStack(spacing: AppSpacing.xxs) {
                Text(selectedStore.compactDisplayName)
                    .font(AppTypography.metadata)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Image(systemName: "chevron.down")
                    .font(AppTypography.metadata)
            }
            .foregroundStyle(AppColors.secondaryText)
            .padding(.horizontal, AppSpacing.xxs)
            .frame(width: 66, height: 24)
            .background(Capsule(style: .continuous).fill(AppColors.elevatedCardBackground))
            .overlay(Capsule(style: .continuous).stroke(AppColors.warmBorder, lineWidth: 1))
        }
        .tint(AppColors.olive)
    }
}

#Preview {
    AddShoppingSuggestedItemRow(
        item: SampleShoppingCartItems.suggestedItems[0],
        selectedQuantity: 1,
        selectedStore: .wholeFoods,
        onIncrement: {},
        onDecrement: {},
        onUpdateStore: { _ in }
    )
    .padding()
    .background(AppColors.appBackground)
}
