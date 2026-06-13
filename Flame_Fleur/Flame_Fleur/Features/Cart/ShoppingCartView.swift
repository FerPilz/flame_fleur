import SwiftUI

struct ShoppingCartView: View {
    let onClose: (() -> Void)?

    @EnvironmentObject private var cartStore: ShoppingCartStore

    @State private var isAddItemSheetPresented = false
    @State private var collapsedCategories: Set<ShoppingCartCategory> = []
    @State private var didSaveCart = false

    init(onClose: (() -> Void)? = nil) {
        self.onClose = onClose
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AppColors.appBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    header
                    addItemRow
                    ShoppingCartSummaryCard(
                        totalEstimatedCost: cartStore.totalEstimatedCost,
                        totalItemCount: cartStore.totalItemCount,
                        categoryCount: cartStore.categoryCount
                    )
                    FoodAnalyticsCard(onUpgrade: placeholderUpgrade)

                    if cartStore.items.isEmpty {
                        emptyCartState
                    } else {
                        cartSections
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.xs)
                .padding(.bottom, AppSpacing.xxxl + AppSpacing.lg)
            }

            bottomActionBar
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isAddItemSheetPresented) {
            AddShoppingItemSheet()
                .environmentObject(cartStore)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(AppRadius.hero)
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: AppSpacing.md) {
            if let onClose {
                IconCircleButton(
                    systemName: "chevron.left",
                    accessibilityLabel: "Close shopping cart",
                    size: AppTopActionMetrics.buttonSize,
                    backgroundColor: AppColors.elevatedCardBackground,
                    foregroundColor: AppColors.darkOlive,
                    action: onClose
                )
            }

            VStack(alignment: .leading, spacing: 1) {
                Text("Flame & Fleur")
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.olive)
                    .lineLimit(1)

                Text("Shopping Cart")
                    .font(AppTypography.heroTitle)
                    .foregroundStyle(AppColors.olive)
                    .lineLimit(1)

                Text("This week's ingredients")
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: AppSpacing.sm)

            ShareLink(item: cartStore.cartSummaryText) {
                VStack(spacing: AppSpacing.xxs) {
                    Image(systemName: "square.and.arrow.up")
                        .font(AppTypography.caption)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(AppColors.elevatedCardBackground))
                        .overlay(Circle().stroke(AppColors.warmBorder, lineWidth: 1))

                    Text("Share")
                        .font(AppTypography.metadata)
                }
                .foregroundStyle(AppColors.olive)
            }
            .buttonStyle(.plain)
        }
    }

    private var addItemRow: some View {
        Button {
            isAddItemSheetPresented = true
        } label: {
            HStack(spacing: AppSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(AppColors.olive)
                        .frame(width: 26, height: 26)

                    Image(systemName: "plus")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.elevatedCardBackground)
                }

                Text("Add Item")
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColors.olive)

                Spacer()

                Image(systemName: "basket")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.olive)
            }
            .padding(.horizontal, AppSpacing.sm)
            .frame(height: 42)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                    .fill(AppColors.softOlive)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                    .stroke(AppColors.warmBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var cartSections: some View {
        VStack(spacing: AppSpacing.sm) {
            ForEach(cartStore.populatedCategories) { category in
                ShoppingCartSectionView(
                    category: category,
                    items: cartStore.items(for: category),
                    isCollapsed: collapsedCategories.contains(category),
                    onToggleCollapsed: { toggleSection(category) },
                    onToggleChecked: { item in cartStore.toggleChecked(for: item.id) },
                    onIncrement: { item in cartStore.incrementQuantity(for: item.id) },
                    onDecrement: { item in cartStore.decrementQuantity(for: item.id) },
                    onUpdateStore: { item, store in
                        cartStore.updateStore(for: item.id, to: store)
                    }
                )
            }
        }
    }

    private var emptyCartState: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.extraLarge,
            contentPadding: AppSpacing.xl
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Image(systemName: "basket")
                    .font(AppTypography.heroTitle)
                    .foregroundStyle(AppColors.olive)

                Text("Your cart is ready for ingredients.")
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.primaryText)

                Text("Add a few items to build this week's shopping list.")
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
    }

    private var bottomActionBar: some View {
        HStack(spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text("Est. total")
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)

                Text(ShoppingCartStore.currencyString(cartStore.totalEstimatedCost))
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.olive)
                    .lineLimit(1)
            }

            Spacer(minLength: AppSpacing.xs)

            Button(action: placeholderViewDetails) {
                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: "list.bullet")
                        .font(AppTypography.metadata)

                    Text("View details")
                        .font(AppTypography.smallButton)
                        .lineLimit(1)
                }
                .foregroundStyle(AppColors.olive)
                .padding(.horizontal, AppSpacing.sm)
                .frame(height: 36)
                .background(Capsule(style: .continuous).fill(AppColors.elevatedCardBackground))
                .overlay(Capsule(style: .continuous).stroke(AppColors.warmBorder, lineWidth: 1))
            }
            .buttonStyle(.plain)

            PrimaryButton(
                didSaveCart ? "Saved" : "Save Cart",
                systemImage: didSaveCart ? "checkmark" : "chevron.right",
                style: .olive,
                isFullWidth: false,
                height: 40,
                horizontalPadding: AppSpacing.md,
                action: saveCart
            )
        }
        .padding(AppSpacing.xs)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous)
                .fill(AppColors.elevatedCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous)
                        .stroke(AppColors.warmBorder, lineWidth: 1)
                )
        )
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.bottom, AppSpacing.xxs)
        .background(AppColors.appBackground.opacity(0.96))
    }

    private func toggleSection(_ category: ShoppingCartCategory) {
        if collapsedCategories.contains(category) {
            collapsedCategories.remove(category)
        } else {
            collapsedCategories.insert(category)
        }
    }

    private func placeholderViewDetails() {}

    private func placeholderUpgrade() {}

    private func saveCart() {
        didSaveCart = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            didSaveCart = false
        }
    }
}

#Preview {
    NavigationStack {
        ShoppingCartView()
            .environmentObject(ShoppingCartStore(items: SampleShoppingCartItems.currentWeek))
    }
}
