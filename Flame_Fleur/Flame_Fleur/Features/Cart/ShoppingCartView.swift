import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct ShoppingCartView: View {
    let onClose: (() -> Void)?
    @Binding private var pendingSharedCartImport: SharedCartPayload?
    @Binding private var sharedCartImportError: String?

    @EnvironmentObject private var cartStore: ShoppingCartStore
    @Environment(\.dismiss) private var dismiss

    @State private var isAddItemSheetPresented = false
    @State private var isSaveCartSheetPresented = false
    @State private var isShareSheetPresented = false
    @State private var isSavedCartsSheetPresented = false
    @State private var isDeleteSelectedAlertPresented = false
    @State private var isClearCartAlertPresented = false
    @State private var pendingSavedCartToDelete: SavedShoppingCart?
    @State private var cartShareError: String?
    @State private var collapsedCategories: Set<ShoppingCartCategory> = []
    @State private var didSaveCart = false
    @State private var draftCartName = "Weekly groceries"
    @State private var shareSheetItems: [Any] = []

    private let cartHorizontalPadding = AppSpacing.md

    init(
        onClose: (() -> Void)? = nil,
        pendingSharedCartImport: Binding<SharedCartPayload?> = .constant(nil),
        sharedCartImportError: Binding<String?> = .constant(nil)
    ) {
        self.onClose = onClose
        self._pendingSharedCartImport = pendingSharedCartImport
        self._sharedCartImportError = sharedCartImportError
    }

    var body: some View {
        AppScreen(
            contentSpacing: AppSpacing.sm,
            headerTopPadding: AppSpacing.xxs,
            contentHorizontalPadding: cartHorizontalPadding,
            contentTopPadding: AppSpacing.xs,
            contentBottomPadding: AppSpacing.xxxl + 44
        ) {
            fixedHeader
        } content: {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                if cartStore.items.isEmpty {
                    emptyCartState
                } else {
                    cartSections
                }

                FoodAnalyticsCard(
                    balance: cartStore.recipeMacroBalance,
                    onUpgrade: placeholderUpgrade
                )
            }
            .padding(.top, AppSpacing.xs)
            .padding(.bottom, AppSpacing.sm)
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
        .alert("Delete saved cart?", isPresented: Binding(
            get: { pendingSavedCartToDelete != nil },
            set: { if !$0 { pendingSavedCartToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                pendingSavedCartToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let savedCart = pendingSavedCartToDelete {
                    cartStore.deleteSavedCart(id: savedCart.id)
                }
                pendingSavedCartToDelete = nil
            }
        } message: {
            Text("This permanently removes the saved cart.")
        }
        .alert("Remove selected items?", isPresented: $isDeleteSelectedAlertPresented) {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                cartStore.removeSelectedItems()
            }
        } message: {
            Text("This removes all selected ingredients from the cart.")
        }
        .alert("Clear Cart?", isPresented: $isClearCartAlertPresented) {
            Button("Cancel", role: .cancel) {}
            Button("Clear Cart", role: .destructive) {
                cartStore.clearCart()
            }
        } message: {
            Text("This removes every item from the current cart.")
        }
        .alert(
            "Couldn’t Share Cart",
            isPresented: Binding(
                get: { cartShareError != nil },
                set: { if !$0 { cartShareError = nil } }
            )
        ) {
            Button("OK", role: .cancel) {
                cartShareError = nil
            }
        } message: {
            Text(cartShareError ?? "The cart share file could not be created.")
        }
        .confirmationDialog(
            "Import shared cart?",
            isPresented: Binding(
                get: { pendingSharedCartImport != nil },
                set: { if !$0 { pendingSharedCartImport = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Import") {
                importSharedCart()
            }

            Button("Cancel", role: .cancel) {
                pendingSharedCartImport = nil
            }
        } message: {
            Text("This will replace your current cart.")
        }
        .alert(
            "Couldn’t Import Cart",
            isPresented: Binding(
                get: { sharedCartImportError != nil },
                set: { if !$0 { sharedCartImportError = nil } }
            )
        ) {
            Button("OK", role: .cancel) {
                sharedCartImportError = nil
            }
        } message: {
            Text(sharedCartImportError ?? "The selected file could not be imported.")
        }
        .sheet(isPresented: $isShareSheetPresented, onDismiss: cleanupShareSheet) {
            if !shareSheetItems.isEmpty {
                ActivityView(activityItems: shareSheetItems)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var fixedHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            ZStack {
                AppBrandTitle()

                HStack(alignment: .center, spacing: AppSpacing.sm) {
                    backButton
                        .frame(width: AppTopActionMetrics.actionGroupWidth, alignment: .leading)

                    Spacer(minLength: 0)

                    HStack(spacing: 6) {
                        clearCartButton
                        savedCartsButton
                    }
                    .frame(width: ShoppingCartLayoutMetrics.trailingActionWidth, alignment: .trailing)
                }
            }
            .frame(height: 44)

            VStack(spacing: AppSpacing.sm) {
                addItemRow
                ShoppingCartSummaryCard(
                    totalItemCount: cartStore.totalItemCount,
                    categoryCount: cartStore.categoryCount,
                    selectedItemCount: cartStore.selectedItemCount
                )

                if cartStore.hasSelectedItems {
                    deleteSelectedButton
                }
            }
        }
    }

    private var backButton: some View {
        IconCircleButton(
            systemName: "chevron.left",
            accessibilityLabel: "Back",
            size: AppTopActionMetrics.compactButtonSize,
            backgroundColor: AppColors.elevatedCardBackground,
            foregroundColor: AppColors.darkOlive
        ) {
            closeCart()
        }
    }

    private var savedCartsButton: some View {
        IconCircleButton(
            systemName: "tray.full",
            accessibilityLabel: "Saved carts",
            size: ShoppingCartLayoutMetrics.actionButtonSize,
            backgroundColor: AppColors.elevatedCardBackground,
            foregroundColor: AppColors.darkOlive
        ) {
            isSavedCartsSheetPresented = true
        }
    }

    private var clearCartButton: some View {
        IconCircleButton(
            systemName: "trash",
            accessibilityLabel: "Clear cart",
            size: ShoppingCartLayoutMetrics.actionButtonSize,
            backgroundColor: AppColors.elevatedCardBackground,
            foregroundColor: AppColors.darkOlive
        ) {
            if !cartStore.items.isEmpty {
                isClearCartAlertPresented = true
            }
        }
    }

    private var addItemRow: some View {
        Button {
            isAddItemSheetPresented = true
        } label: {
                HStack(spacing: AppSpacing.sm) {
                    ZStack {
                        Circle()
                            .strokeBorder(AppColors.deepBasil, lineWidth: 1.4)
                            .frame(width: 26, height: 26)

                        Image(systemName: "plus")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.deepBasil)
                    }

                    Text("Add Item")
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColors.deepBasil)

                    Spacer()

                    Image(systemName: "basket")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.deepBasil)
                }
                .padding(.horizontal, AppSpacing.sm)
                .frame(height: 42)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                        .fill(AppColors.deepBasil.opacity(0.10))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                        .stroke(AppColors.deepBasil, lineWidth: 1)
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
                Text("Cart")
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)

                Text("\(cartStore.totalItemCount) items")
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.olive)
                    .lineLimit(1)
            }

            Spacer(minLength: AppSpacing.xs)

            HStack(spacing: AppSpacing.xs) {
                PrimaryButton(
                    "Share Cart",
                    systemImage: "square.and.arrow.up",
                    style: .olive,
                    backgroundColor: AppColors.elevatedCardBackground,
                    foregroundColor: AppColors.deepBasil,
                    borderColor: AppColors.deepBasil,
                    isFullWidth: true,
                    height: 42,
                    font: AppTypography.callout,
                    horizontalPadding: AppSpacing.sm,
                    textLineLimit: 1,
                    minimumScaleFactor: 0.75,
                    allowsTightening: true,
                    action: presentShareCart
                )
                .frame(maxWidth: .infinity)

                PrimaryButton(
                    didSaveCart ? "Saved" : "Save Cart",
                    systemImage: didSaveCart ? "checkmark" : "chevron.right",
                    style: .olive,
                    backgroundColor: AppColors.deepBasil,
                    isFullWidth: true,
                    height: 42,
                    font: AppTypography.callout,
                    horizontalPadding: AppSpacing.sm,
                    textLineLimit: 1,
                    minimumScaleFactor: 0.75,
                    allowsTightening: true,
                    action: { isSaveCartSheetPresented = true }
                )
                .frame(maxWidth: .infinity)
            }
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
        .padding(.horizontal, cartHorizontalPadding)
        .padding(.bottom, AppSpacing.xxs)
        .background(AppColors.appBackground.opacity(0.96))
    }

    private func closeCart() {
        if let onClose {
            onClose()
        } else {
            dismiss()
        }
    }

    private func presentShareCart() {
        do {
            let shareURL = try CartSharingService.exportTextFileURL(for: cartStore.cartSummaryText)
            let nutrition = cartStore.recipeNutritionSummary
            var activityItems: [Any] = [shareURL]

            #if canImport(UIKit)
            if #available(iOS 16.0, *) {
                guard let screenshot = cartShareSnapshotImage() else {
                    throw CartShareError.snapshotUnavailable
                }
                activityItems.append(screenshot)
            }
            #endif

            UsageTrackingStore.shared.record(
                type: .cartShared,
                recipeTitle: "Current Cart",
                ingredientNames: cartStore.items.map(\.normalizedName),
                calories: nutrition.calories,
                proteinGrams: nutrition.proteinGrams,
                carbGrams: nutrition.carbohydrateGrams,
                fatGrams: nutrition.fatGrams
            )
            shareSheetItems = activityItems
            isShareSheetPresented = true
        } catch {
            cartShareError = "Couldn’t prepare the cart text file and screenshot."
        }
    }

    #if canImport(UIKit)
    @available(iOS 16.0, *)
    private func cartShareSnapshotImage() -> UIImage? {
        let renderer = ImageRenderer(
            content: ShoppingCartShareSnapshotView(items: cartStore.items)
                .frame(width: 390)
        )
        renderer.scale = 3
        return renderer.uiImage
    }
    #endif

    private func importSharedCart() {
        guard let payload = pendingSharedCartImport else {
            return
        }

        let summary = cartStore.replaceCart(with: payload)
        pendingSharedCartImport = nil
        _ = summary
    }

    private func cleanupShareSheet() {
        shareSheetItems = []
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
                                HStack(spacing: AppSpacing.xxs) {
                                    Button {
                                        cartStore.restoreCart(savedCart)
                                        isSavedCartsSheetPresented = false
                                    } label: {
                                        savedCartRow(savedCart)
                                    }
                                    .buttonStyle(.plain)

                                    IconCircleButton(
                                        systemName: "trash",
                                        accessibilityLabel: "Delete saved cart",
                                        size: 32,
                                        backgroundColor: AppColors.elevatedCardBackground,
                                        foregroundColor: AppColors.burntOrange
                                    ) {
                                        pendingSavedCartToDelete = savedCart
                                    }
                                }
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
                    Text("\(savedCart.itemCount) items")
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColors.olive)

                    Text("\(savedCartCategoryCount(savedCart)) groups")
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

    private func savedCartCategoryCount(_ savedCart: SavedShoppingCart) -> Int {
        Set(savedCart.items.map(\.category)).count
    }
}

private enum CartShareError: Error {
    case snapshotUnavailable
}

private enum ShoppingCartLayoutMetrics {
    static let actionButtonSize: CGFloat = 30
    static let trailingActionWidth: CGFloat = 138
}

#Preview {
    ShoppingCartView()
        .environmentObject(ShoppingCartStore.shared)
        .environmentObject(AppSettingsStore.shared)
}
