import SwiftUI

struct ShoppingCartView: View {
    let onClose: (() -> Void)?

    @EnvironmentObject private var cartStore: ShoppingCartStore

    @State private var isAddItemSheetPresented = false
    @State private var isSaveCartSheetPresented = false
    @State private var isSavedCartsSheetPresented = false
    @State private var isDeleteSelectedAlertPresented = false
    @State private var collapsedCategories: Set<ShoppingCartCategory> = []
    @State private var didSaveCart = false
    @State private var draftCartName = "Weekly groceries"

    init(onClose: (() -> Void)? = nil) {
        self.onClose = onClose
    }

    var body: some View {
        AppScreen(
            contentSpacing: AppSpacing.sm,
            headerTopPadding: AppSpacing.xxs,
            contentBottomPadding: AppSpacing.xxxl + AppSpacing.lg
        ) {
            fixedHeader
        } content: {
            if cartStore.items.isEmpty {
                emptyCartState
            } else {
                FoodAnalyticsCard(onUpgrade: placeholderUpgrade)
                cartSections
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomActionBar
        }
        .sheet(isPresented: $isAddItemSheetPresented) {
            AddShoppingItemSheet()
                .environmentObject(cartStore)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(AppRadius.hero)
        }
        .sheet(isPresented: $isSaveCartSheetPresented) {
            saveCartSheet
                .presentationDetents([.height(250)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(AppRadius.hero)
        }
        .sheet(isPresented: $isSavedCartsSheetPresented) {
            savedCartsSheet
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(AppRadius.hero)
        }
        .alert("Remove selected items?", isPresented: $isDeleteSelectedAlertPresented) {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                cartStore.removeSelectedItems()
            }
        } message: {
            Text("This removes all selected ingredients from the cart.")
        }
    }

    private var fixedHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(alignment: .center, spacing: AppSpacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Flame & Fleur")
                        .font(.system(size: 21, weight: .medium, design: .serif))
                        .foregroundStyle(AppColors.olive)
                        .lineLimit(1)

                    Text("Shopping Cart")
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(1)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                }

                Spacer(minLength: AppSpacing.xs)

                HStack(spacing: AppSpacing.xs) {
                    savedCartsButton
                    shareButton
                }
            }

            VStack(spacing: AppSpacing.sm) {
                addItemRow
                ShoppingCartSummaryCard(
                    totalEstimatedCost: cartStore.totalEstimatedCost,
                    totalItemCount: cartStore.totalItemCount,
                    categoryCount: cartStore.categoryCount
                )

                if cartStore.hasSelectedItems {
                    deleteSelectedButton
                }
            }
        }
    }

    private var savedCartsButton: some View {
        IconCircleButton(
            systemName: "tray.full",
            accessibilityLabel: "Saved carts",
            size: AppTopActionMetrics.compactButtonSize,
            backgroundColor: AppColors.elevatedCardBackground,
            foregroundColor: AppColors.darkOlive
        ) {
            isSavedCartsSheetPresented = true
        }
    }

    private var shareButton: some View {
        ShareLink(item: cartStore.cartSummaryText) {
            ZStack {
                Circle()
                    .fill(AppColors.elevatedCardBackground)
                    .overlay(
                        Circle()
                            .stroke(AppColors.warmBorder.opacity(0.78), lineWidth: 1)
                    )
                    .frame(width: AppTopActionMetrics.compactButtonSize, height: AppTopActionMetrics.compactButtonSize)

                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: AppTopActionMetrics.compactButtonSize * 0.42, weight: .medium))
                    .foregroundStyle(AppColors.darkOlive)
                    .frame(width: AppTopActionMetrics.compactButtonSize, height: AppTopActionMetrics.compactButtonSize)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Share cart"))
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

    private var deleteSelectedButton: some View {
        Button {
            isDeleteSelectedAlertPresented = true
        } label: {
            HStack(spacing: AppSpacing.xxs) {
                Image(systemName: "trash")
                    .font(AppTypography.caption)

                Text("Delete selected (\(cartStore.selectedItemCount))")
                    .font(AppTypography.smallButton)
                    .lineLimit(1)
            }
            .foregroundStyle(AppColors.burntOrange)
            .frame(maxWidth: .infinity)
            .frame(height: 34)
            .background(
                Capsule(style: .continuous)
                    .fill(AppColors.softOrange.opacity(0.55))
            )
            .overlay(
                Capsule(style: .continuous)
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
                    onToggleSelection: { item in
                        cartStore.toggleChecked(for: item.id)
                    },
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

            PrimaryButton(
                didSaveCart ? "Saved" : "Save Cart",
                systemImage: didSaveCart ? "checkmark" : "chevron.right",
                style: .olive,
                isFullWidth: false,
                height: 40,
                horizontalPadding: AppSpacing.md,
                action: { isSaveCartSheetPresented = true }
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

    private var saveCartSheet: some View {
        NavigationStack {
            ZStack {
                AppColors.appBackground.ignoresSafeArea()

                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Save Cart")
                        .font(AppTypography.heroTitle)
                        .foregroundStyle(AppColors.primaryText)

                    Text("Name this shopping list so you can return to it later.")
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.secondaryText)

                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        TextField("Cart name", text: $draftCartName)
                            .font(AppTypography.body)
                            .padding(.horizontal, AppSpacing.sm)
                            .frame(height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                                    .fill(AppColors.elevatedCardBackground)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                                    .stroke(AppColors.warmBorder, lineWidth: 1)
                            )

                        Text("Example: Weekly groceries")
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.tertiaryText)
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.md)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        draftCartName = "Weekly groceries"
                        isSaveCartSheetPresented = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        _ = cartStore.saveCurrentCart(named: draftCartName)
                        draftCartName = "Weekly groceries"
                        isSaveCartSheetPresented = false
                        didSaveCart = true

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                            if didSaveCart {
                                didSaveCart = false
                            }
                        }
                    }
                }
            }
        }
    }

    private var savedCartsSheet: some View {
        NavigationStack {
            ZStack {
                AppColors.appBackground.ignoresSafeArea()

                if cartStore.savedCarts.isEmpty {
                    emptySavedCartsState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            ForEach(cartStore.savedCarts) { savedCart in
                                Button {
                                    cartStore.restoreCart(savedCart)
                                    isSavedCartsSheetPresented = false
                                } label: {
                                    savedCartRow(savedCart)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.top, AppSpacing.sm)
                        .padding(.bottom, AppSpacing.lg)
                    }
                }
            }
            .navigationTitle("Saved Carts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        isSavedCartsSheetPresented = false
                    }
                }
            }
        }
    }

    private var emptySavedCartsState: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.extraLarge,
            contentPadding: AppSpacing.xl
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text("No saved carts yet.")
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.primaryText)

                Text("Save your current list to access it here later.")
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, AppSpacing.lg)
    }

    private func savedCartRow(_ savedCart: SavedShoppingCart) -> some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.sm
        ) {
            HStack(alignment: .top, spacing: AppSpacing.sm) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(savedCart.name)
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(1)

                    Text(savedCart.savedAt.formatted(date: .abbreviated, time: .shortened))
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(1)
                }

                Spacer(minLength: AppSpacing.sm)

                VStack(alignment: .trailing, spacing: AppSpacing.xxs) {
                    Text(ShoppingCartStore.currencyString(savedCart.estimatedTotal))
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColors.olive)

                    Text("\(savedCart.itemCount) items")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
        }
    }

    private func toggleSection(_ category: ShoppingCartCategory) {
        if collapsedCategories.contains(category) {
            collapsedCategories.remove(category)
        } else {
            collapsedCategories.insert(category)
        }
    }

    private func placeholderUpgrade() {}
}

#Preview {
    ShoppingCartView()
        .environmentObject(ShoppingCartStore.shared)
        .environmentObject(AppSettingsStore.shared)
}
