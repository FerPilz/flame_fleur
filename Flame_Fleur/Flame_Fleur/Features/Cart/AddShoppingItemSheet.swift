import SwiftUI

struct AddShoppingItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cartStore: ShoppingCartStore

    @State private var searchText = ""
    @State private var selectedQuickAction: QuickAction?
    @State private var selectedQuantities: [ShoppingCartItem.ID: Int] = [:]
    @State private var selectedStores: [ShoppingCartItem.ID: ShoppingStoreOption] = [:]
    @State private var sortOption: SortOption = .relevance

    private let suggestedItems = SampleShoppingCartItems.suggestedItems

    var body: some View {
        ZStack {
            AppColors.appBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    sheetHeader
                    searchBar
                    quickActions
                    suggestedHeader

                    SurfaceCard(
                        backgroundColor: AppColors.elevatedCardBackground,
                        cornerRadius: AppRadius.large,
                        contentPadding: AppSpacing.xs
                    ) {
                        VStack(spacing: AppSpacing.xxs) {
                            ForEach(filteredSuggestedItems) { item in
                                AddShoppingSuggestedItemRow(
                                    item: item,
                                    selectedQuantity: selectedQuantities[item.id, default: 0],
                                    selectedStore: selectedStore(for: item),
                                    onIncrement: { increment(item) },
                                    onDecrement: { decrement(item) },
                                    onUpdateStore: { option in
                                        selectedStores[item.id] = option
                                    }
                                )

                                if item.id != filteredSuggestedItems.last?.id {
                                    Rectangle()
                                        .fill(AppColors.warmBorder.opacity(0.70))
                                        .frame(height: 1)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.xxxl + AppSpacing.md)
            }
        }
        .safeAreaInset(edge: .bottom) {
            selectedItemsBar
        }
    }

    private var sheetHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text("Add Item")
                .font(AppTypography.heroTitle)
                .foregroundStyle(AppColors.primaryText)

            Text("Search, scan, or create a custom item")
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.secondaryText)
        }
    }

    private var searchBar: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.tertiaryText)

            TextField(
                "",
                text: $searchText,
                prompt: Text("Search ingredients or products")
                    .foregroundStyle(AppColors.tertiaryText)
            )
            .font(AppTypography.callout)
            .foregroundStyle(AppColors.primaryText)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        }
        .padding(.horizontal, AppSpacing.sm)
        .frame(height: 38)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                .fill(AppColors.elevatedCardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                .stroke(AppColors.warmBorder, lineWidth: 1)
        )
    }

    private var quickActions: some View {
        HStack(spacing: AppSpacing.xs) {
            ForEach(QuickAction.allCases) { action in
                FilterChip(
                    action.title,
                    systemImage: action.systemImage,
                    isSelected: selectedQuickAction == action,
                    selectedColor: AppColors.olive
                ) {
                    selectedQuickAction = selectedQuickAction == action ? nil : action
                }
            }
        }
    }

    private var suggestedHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Suggested Items")
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.primaryText)

            Spacer()

            Menu {
                ForEach(SortOption.allCases) { option in
                    Button(option.title) {
                        sortOption = option
                    }
                }
            } label: {
                HStack(spacing: AppSpacing.xxs) {
                    Text(sortOption.menuTitle)
                        .font(AppTypography.metadata)
                    Image(systemName: "chevron.down")
                        .font(AppTypography.metadata)
                }
                .foregroundStyle(AppColors.secondaryText)
            }
            .tint(AppColors.olive)
        }
    }

    private var selectedItemsBar: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppColors.olive)
                    .frame(width: 34, height: 34)

                Image(systemName: "basket.fill")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.elevatedCardBackground)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text("\(selectedCount) items selected")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)

                Text("Est. total \(ShoppingCartStore.currencyString(selectedEstimatedTotal))")
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: AppSpacing.xs)

            PrimaryButton(
                "Add to Cart",
                style: .olive,
                isFullWidth: false,
                height: 40,
                horizontalPadding: AppSpacing.lg
            ) {
                addSelectedItems()
            }
            .disabled(selectedCount == 0)
            .opacity(selectedCount == 0 ? 0.62 : 1)
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
        .padding(.top, AppSpacing.xxs)
        .padding(.bottom, AppSpacing.xxs)
        .background(AppColors.appBackground.opacity(0.96))
    }

    private var filteredSuggestedItems: [ShoppingCartItem] {
        let filtered = suggestedItems.filter { item in
            let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedSearch.isEmpty else { return true }

            return item.name.localizedCaseInsensitiveContains(trimmedSearch)
            || item.category.title.localizedCaseInsensitiveContains(trimmedSearch)
            || item.unit.localizedCaseInsensitiveContains(trimmedSearch)
        }

        switch sortOption {
        case .relevance:
            return filtered
        case .name:
            return filtered.sorted { $0.name < $1.name }
        case .price:
            return filtered.sorted { $0.price < $1.price }
        }
    }

    private var selectedCount: Int {
        selectedQuantities.values.reduce(0, +)
    }

    private var selectedEstimatedTotal: Double {
        suggestedItems.reduce(0) { total, item in
            total + (Double(selectedQuantities[item.id, default: 0]) * item.price)
        }
    }

    private func selectedStore(for item: ShoppingCartItem) -> ShoppingStoreOption {
        selectedStores[item.id] ?? ShoppingStoreOption.option(named: item.storeName)
    }

    private func increment(_ item: ShoppingCartItem) {
        selectedQuantities[item.id, default: 0] += 1
        selectedStores[item.id] = selectedStore(for: item)
    }

    private func decrement(_ item: ShoppingCartItem) {
        selectedQuantities[item.id] = max(0, selectedQuantities[item.id, default: 0] - 1)
    }

    private func addSelectedItems() {
        let itemsToAdd = suggestedItems.compactMap { item -> ShoppingCartItem? in
            let quantity = selectedQuantities[item.id, default: 0]
            guard quantity > 0 else { return nil }

            return ShoppingCartItem(
                name: item.name,
                quantity: quantity,
                unit: item.unit,
                category: item.category,
                price: item.price,
                storeName: selectedStore(for: item).displayName,
                imageName: item.imageName,
                notes: item.notes
            )
        }

        guard !itemsToAdd.isEmpty else { return }
        cartStore.addItems(itemsToAdd)
        dismiss()
    }
}

private enum QuickAction: String, CaseIterable, Identifiable {
    case scan
    case fromRecipes
    case customItem

    var id: String { rawValue }

    var title: String {
        switch self {
        case .scan:
            return "Scan"
        case .fromRecipes:
            return "From recipes"
        case .customItem:
            return "Custom item"
        }
    }

    var systemImage: String {
        switch self {
        case .scan:
            return "barcode.viewfinder"
        case .fromRecipes:
            return "book.closed"
        case .customItem:
            return "pencil"
        }
    }
}

private enum SortOption: String, CaseIterable, Identifiable {
    case relevance
    case name
    case price

    var id: String { rawValue }

    var title: String {
        switch self {
        case .relevance:
            return "Relevance"
        case .name:
            return "Name"
        case .price:
            return "Price"
        }
    }

    var menuTitle: String {
        "Sort by \(title.lowercased())"
    }
}

#Preview {
    AddShoppingItemSheet()
        .environmentObject(ShoppingCartStore(items: SampleShoppingCartItems.currentWeek))
}
