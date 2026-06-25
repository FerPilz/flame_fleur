import SwiftUI

struct ShoppingCartItemRow: View {
    let item: ShoppingCartItem
    let onToggleSelection: () -> Void
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onUpdateStore: (ShoppingStoreOption) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.xxs) {
            Button(action: onToggleSelection) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(item.isChecked ? AppColors.olive : AppColors.tertiaryText)
                    .frame(width: 24, height: 24)
                    .padding(.top, 2)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(item.isChecked ? "Deselect \(item.name)" : "Select \(item.name)"))

            FoodImagePlaceholder(imageName: item.imageName, style: .thumbnail)
                .frame(width: 34, height: 34)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(item.quantityText) · \(item.category.title)")
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.86)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)

            VStack(alignment: .trailing, spacing: AppSpacing.xxs) {
                Text(ShoppingCartStore.currencyString(item.estimatedLineCost))
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                HStack(spacing: AppSpacing.xxs) {
                    quantityControl
                    storeMenu
                }
            }
        }
        .padding(.horizontal, AppSpacing.xxs)
        .padding(.vertical, AppSpacing.xs)
        .frame(minHeight: 58)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                .fill(item.isChecked ? AppColors.softOlive.opacity(0.42) : Color.clear)
        )
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
        .padding(.horizontal, 3)
        .frame(width: 56, height: 24)
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
            .padding(.horizontal, AppSpacing.xxs)
            .frame(width: 72, height: 24)
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
        onToggleSelection: {},
        onIncrement: {},
        onDecrement: {},
        onUpdateStore: { _ in }
    )
    .padding()
    .background(AppColors.appBackground)
}
