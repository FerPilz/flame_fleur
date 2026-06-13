import SwiftUI

struct ShoppingCartItemRow: View {
    let item: ShoppingCartItem
    let onToggleChecked: () -> Void
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onUpdateStore: (ShoppingStoreOption) -> Void

    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.xs) {
            Button(action: onToggleChecked) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(AppTypography.caption)
                    .foregroundStyle(item.isChecked ? AppColors.olive : AppColors.tertiaryText)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)

            FoodImagePlaceholder(imageName: item.imageName, style: .thumbnail)
                .frame(width: 34, height: 34)

            VStack(alignment: .leading, spacing: 1) {
                Text(item.name)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(2)

                Text(item.quantityText)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)

            quantityControl

            storeMenu

            Text(ShoppingCartStore.currencyString(item.estimatedLineCost))
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .frame(width: 44, alignment: .trailing)
        }
        .padding(.horizontal, AppSpacing.xs)
        .frame(minHeight: 46)
        .opacity(item.isChecked ? 0.58 : 1)
    }

    private var quantityControl: some View {
        HStack(spacing: AppSpacing.xxs) {
            Button(action: onDecrement) {
                Image(systemName: "minus")
                    .font(AppTypography.metadata)
                    .frame(width: 16, height: 20)
            }

            Text("\(item.quantity)")
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.primaryText)
                .frame(width: 12)

            Button(action: onIncrement) {
                Image(systemName: "plus")
                    .font(AppTypography.metadata)
                    .frame(width: 16, height: 20)
            }
        }
        .foregroundStyle(AppColors.olive)
        .padding(.horizontal, AppSpacing.xxs)
        .frame(width: 58, height: 24)
        .background(
            Capsule(style: .continuous)
                .fill(AppColors.elevatedCardBackground)
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(AppColors.warmBorder, lineWidth: 1)
        )
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
                Text(shortStoreName)
                    .font(AppTypography.metadata)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Image(systemName: "chevron.down")
                    .font(AppTypography.metadata)
            }
            .foregroundStyle(AppColors.secondaryText)
            .padding(.horizontal, AppSpacing.xs)
            .frame(width: 78, height: 24)
            .background(
                Capsule(style: .continuous)
                    .fill(AppColors.elevatedCardBackground)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(AppColors.warmBorder, lineWidth: 1)
            )
        }
        .tint(AppColors.olive)
    }

    private var shortStoreName: String {
        ShoppingStoreOption.option(named: item.storeName).compactDisplayName
    }
}

#Preview {
    ShoppingCartItemRow(
        item: SampleShoppingCartItems.currentWeek[0],
        onToggleChecked: {},
        onIncrement: {},
        onDecrement: {},
        onUpdateStore: { _ in }
    )
    .padding()
    .background(AppColors.appBackground)
}
