import SwiftUI

struct AddShoppingItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cartStore: ShoppingCartStore

    @State private var searchText = ""
    @State private var searchResults: [ShoppingIngredientCatalogItem] = []
    @State private var quantities: [String: Int] = [:]
    @State private var addedResultIDs: Set<String> = []

    private let resultLimit = 20

    var body: some View {
        ZStack {
            AppColors.appBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: AppSpacing.sm) {
                    sheetHeader
                    searchBar
                    resultsContent
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.lg)
            }
        }
        .task(id: normalizedSearchText) {
            await updateSearchResults()
        }
    }

    private var sheetHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text("Add Item")
                .font(AppTypography.heroTitle)
                .foregroundStyle(AppColors.primaryText)

            Text("Search the ingredient catalog")
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

    @ViewBuilder
    private var resultsContent: some View {
        if normalizedSearchText.isEmpty {
            initialSearchState
        } else {
            resultsHeader

            if searchResults.isEmpty {
                noMatchesState
            } else {
                searchResultsCard
            }

            if canAddCustomItem {
                customItemCard
            }
        }
    }

    private var initialSearchState: some View {
        Text("Search for an ingredient")
            .font(AppTypography.callout)
            .foregroundStyle(AppColors.secondaryText)
            .frame(maxWidth: .infinity, minHeight: 96, alignment: .center)
    }

    private var resultsHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Catalog Matches")
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.primaryText)

            Spacer()

            Text("\(searchResults.count)")
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.secondaryText)
                .padding(.horizontal, AppSpacing.xs)
                .frame(height: 22)
                .background(Capsule(style: .continuous).fill(AppColors.softOlive))
        }
    }

    private var searchResultsCard: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.xs
        ) {
            LazyVStack(spacing: AppSpacing.xxs) {
                ForEach(searchResults) { catalogItem in
                    AddShoppingSuggestedItemRow(
                        item: cartStore.item(for: catalogItem),
                        quantity: quantityBinding(for: catalogItem.id),
                        isAdded: addedResultIDs.contains(catalogItem.id),
                        onAdd: { addCatalogItem(catalogItem) }
                    )

                    if catalogItem.id != searchResults.last?.id {
                        Rectangle()
                            .fill(AppColors.warmBorder.opacity(0.70))
                            .frame(height: 1)
                    }
                }
            }
        }
    }

    private var customItemCard: some View {
        SurfaceCard(
            backgroundColor: AppColors.softOlive.opacity(0.55),
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.sm
        ) {
            AddShoppingSuggestedItemRow(
                item: customItem,
                quantity: quantityBinding(for: customItemID),
                isAdded: addedResultIDs.contains(customItemID),
                onAdd: addCustomItem
            )
        }
    }

    private var noMatchesState: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.md
        ) {
            Text("No catalog matches")
                .font(AppTypography.cardTitle)
                .foregroundStyle(AppColors.primaryText)
        }
    }

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var normalizedSearchText: String {
        IngredientSuggestionEngine.normalize(searchText)
    }

    private var hasExactCatalogMatch: Bool {
        SampleShoppingIngredientCatalog.byNormalizedName[normalizedSearchText] != nil
    }

    private var canAddCustomItem: Bool {
        !normalizedSearchText.isEmpty && !hasExactCatalogMatch
    }

    private var customItemID: String {
        "custom-\(normalizedSearchText)"
    }

    private var customItem: ShoppingCartItem {
        ShoppingCartItem(
            name: trimmedSearchText.localizedCapitalized,
            unit: "item",
            category: .other,
            price: 0,
            storeName: ShoppingStoreOption.localMarket.displayName
        )
    }

    private func quantityBinding(for id: String) -> Binding<Int> {
        Binding(
            get: { quantities[id, default: 1] },
            set: { quantities[id] = $0 }
        )
    }

    private func updateSearchResults() async {
        let query = normalizedSearchText

        guard !query.isEmpty else {
            searchResults = []
            quantities = [:]
            addedResultIDs = []
            return
        }

        do {
            try await Task.sleep(for: .milliseconds(250))
        } catch {
            return
        }

        guard !Task.isCancelled, query == normalizedSearchText else { return }

        let results = IngredientSuggestionEngine.suggestions(for: query, limit: resultLimit)
        guard !Task.isCancelled, query == normalizedSearchText else { return }

        searchResults = results
        let resultIDs = Set(results.map(\.id))
        quantities = quantities.filter { resultIDs.contains($0.key) }
        addedResultIDs = addedResultIDs.intersection(resultIDs)
    }

    private func addCatalogItem(_ catalogItem: ShoppingIngredientCatalogItem) {
        let quantity = quantities[catalogItem.id, default: 1]
        cartStore.addItem(cartStore.item(for: catalogItem, quantity: quantity))
        markAdded(catalogItem.id)
        quantities[catalogItem.id] = 1
    }

    private func addCustomItem() {
        guard canAddCustomItem else { return }

        let quantity = quantities[customItemID, default: 1]
        var item = customItem
        item.quantity = quantity
        cartStore.addItem(item)
        markAdded(customItemID)
        quantities[customItemID] = 1
    }

    private func markAdded(_ id: String) {
        addedResultIDs.insert(id)

        Task {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            addedResultIDs.remove(id)
        }
    }
}

#Preview {
    AddShoppingItemSheet()
        .environmentObject(ShoppingCartStore.shared)
}
