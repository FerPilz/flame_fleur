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
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(item.isChecked ? AppColors.olive : AppColors.tertiaryText)
                    .frame(width: 28, height: 28)
                    .padding(.top, 2)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(item.isChecked ? "Deselect \(item.name)" : "Select \(item.name)"))

            ShoppingCartIngredientImageView(item: item)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 0) {
                Text(item.name)
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(item.quantityUnitText)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)

            HStack(spacing: AppSpacing.xxs) {
                quantityControl
                storeMenu
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
                    .font(.system(size: 13, weight: .semibold))
                    .frame(width: 22, height: 22)
            }
            .contentShape(Rectangle())

            Text("\(item.quantity)")
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.primaryText)
                .frame(width: 18)

            Button(action: onIncrement) {
                Image(systemName: "plus")
                    .font(.system(size: 13, weight: .semibold))
                    .frame(width: 22, height: 22)
            }
            .contentShape(Rectangle())
        }
        .foregroundStyle(AppColors.olive)
        .padding(.horizontal, 4)
        .frame(width: 74, height: 32)
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
                    .font(AppTypography.callout)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .minimumScaleFactor(0.82)

                Image(systemName: "chevron.down")
                    .font(AppTypography.metadata)
            }
            .foregroundStyle(AppColors.secondaryText)
            .padding(.horizontal, AppSpacing.xs)
            .frame(width: 94, height: 32)
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
