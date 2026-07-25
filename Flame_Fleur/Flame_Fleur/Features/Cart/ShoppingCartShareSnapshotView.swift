import SwiftUI

struct ShoppingCartShareSnapshotView: View {
    let items: [ShoppingCartItem]
    let generatedAt: Date

    init(items: [ShoppingCartItem], generatedAt: Date = Date()) {
        self.items = items
        self.generatedAt = generatedAt
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            header

            ShoppingCartSummaryCard(
                totalItemCount: totalItemCount,
                categoryCount: categoryCount,
                selectedItemCount: checkedItemCount
            )

            if items.isEmpty {
                emptyState
            } else {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(populatedCategories) { category in
                        categorySection(category)
                    }
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.appBackground)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text("Flame & Fleur")
                    .font(AppTypography.brandTitle)
                    .foregroundStyle(AppColors.primaryText)

                Text("Shopping List")
                    .font(AppTypography.heroTitle)
                    .foregroundStyle(AppColors.primaryText)

                Text(generatedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)
            }

            Spacer(minLength: AppSpacing.sm)

            ZStack {
                Circle()
                    .fill(AppColors.softOlive)
                    .frame(width: 44, height: 44)

                Image(systemName: "basket.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColors.deepBasil)
            }
        }
    }

    private var emptyState: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.md
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("No items yet")
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColors.primaryText)

                Text("This list is ready for ingredients.")
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
    }

    private func categorySection(_ category: ShoppingCartCategory) -> some View {
        let categoryItems = items(for: category)

        return SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.sm
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.xs) {
                    CartCategoryIconView(category: category, size: 30)

                    Text(category.title)
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColors.primaryText)

                    Text("\(categoryItems.count)")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                        .padding(.horizontal, AppSpacing.xs)
                        .frame(height: 20)
                        .background(Capsule(style: .continuous).fill(AppColors.softOlive))
                }

                ForEach(categoryItems) { item in
                    itemRow(item)

                    if item.id != categoryItems.last?.id {
                        Divider()
                            .overlay(AppColors.warmBorder)
                    }
                }
            }
        }
    }

    private func itemRow(_ item: ShoppingCartItem) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.xs) {
            Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(item.isChecked ? AppColors.olive : AppColors.tertiaryText)
                .frame(width: 20, height: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(2)

                Text(item.storeName)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: AppSpacing.sm)

            Text(item.quantityText)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.deepBasil)
                .lineLimit(1)
        }
        .padding(.vertical, AppSpacing.xxs)
    }

    private var populatedCategories: [ShoppingCartCategory] {
        ShoppingCartCategory.allCases.filter { !items(for: $0).isEmpty }
    }

    private var totalItemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    private var categoryCount: Int {
        Set(items.map(\.category)).count
    }

    private var checkedItemCount: Int {
        items.filter(\.isChecked).count
    }

    private func items(for category: ShoppingCartCategory) -> [ShoppingCartItem] {
        items.filter { $0.category == category }
    }
}

#Preview {
    ShoppingCartShareSnapshotView(items: SampleShoppingCartItems.currentWeek)
        .frame(width: 390)
}
