import SwiftUI

struct AddShoppingItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cartStore: ShoppingCartStore

    @State private var searchText = ""

    private let suggestedItems = SampleShoppingCartItems.suggestedItems

    var body: some View {
        ZStack {
            AppColors.appBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    sheetHeader
                    searchBar
                    suggestedHeader
                    suggestedItemsContent
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.lg)
            }
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

    private var suggestedHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(trimmedSearchText.isEmpty ? "Suggested Items" : "Catalog Matches")
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.primaryText)

            Spacer()

            Text("\(filteredSuggestedItems.count)")
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.secondaryText)
                .padding(.horizontal, AppSpacing.xs)
                .frame(height: 22)
                .background(Capsule(style: .continuous).fill(AppColors.softOlive))
        }
    }

    private var suggestedItemsContent: some View {
        VStack(spacing: AppSpacing.xs) {
            if filteredSuggestedItems.isEmpty {
                emptySuggestedItemsCard
            } else {
                suggestedItemsCard
            }

            if canAddGenericSearchItem {
                genericAddItemCard
            }
        }
    }

    private var suggestedItemsCard: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.xs
        ) {
            VStack(spacing: AppSpacing.xxs) {
                ForEach(filteredSuggestedItems) { item in
                    AddShoppingSuggestedItemRow(
                        item: item,
                        onAdd: { addItem(item) }
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

    private var genericAddItemCard: some View {
        SurfaceCard(
            backgroundColor: AppColors.softOlive.opacity(0.55),
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.sm
        ) {
            AddShoppingSuggestedItemRow(
                item: genericSearchItem,
                onAdd: addGenericSearchItem
            )
        }
    }

    private var emptySuggestedItemsCard: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.md
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Image(systemName: "magnifyingglass")
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.olive)

                Text("No catalog matches")
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColors.primaryText)

                Text("Add the item to Other or refine your search.")
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var filteredSuggestedItems: [ShoppingCartItem] {
        let filtered = suggestedItems.filter { item in
            guard !normalizedSearchText.isEmpty else { return true }

            return item.normalizedName.contains(normalizedSearchText)
            || normalized(item.category.title).contains(normalizedSearchText)
            || normalized(item.unit).contains(normalizedSearchText)
        }

        return filtered.sorted { lhs, rhs in
            let lhsRank = searchRank(for: lhs)
            let rhsRank = searchRank(for: rhs)

            if lhsRank != rhsRank {
                return lhsRank < rhsRank
            }

            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var normalizedSearchText: String {
        trimmedSearchText
            .lowercased()
            .replacingOccurrences(of: #"[^\p{L}\p{N}]+"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canAddGenericSearchItem: Bool {
        guard !normalizedSearchText.isEmpty else { return false }
        return !suggestedItems.contains { $0.normalizedName == normalizedSearchText }
    }

    private var displayGenericItemName: String {
        trimmedSearchText.localizedCapitalized
    }

    private var genericSearchItem: ShoppingCartItem {
        ShoppingCartItem(
            name: displayGenericItemName,
            unit: "item",
            category: .other,
            price: 0,
            storeName: ShoppingStoreOption.localMarket.displayName
        )
    }

    private func addGenericSearchItem() {
        guard canAddGenericSearchItem else { return }

        cartStore.addItem(genericSearchItem)
        dismiss()
    }

    private func addItem(_ item: ShoppingCartItem) {
        cartStore.addItem(
            ShoppingCartItem(
                name: item.name,
                unit: item.unit,
                displayQuantity: item.displayQuantity,
                category: item.category,
                price: item.price,
                storeName: item.storeName,
                imageName: item.imageName,
                notes: item.notes
            )
        )
        dismiss()
    }

    private func searchRank(for item: ShoppingCartItem) -> Int {
        let isCatalogBacked = SampleShoppingIngredientCatalog.byNormalizedName[item.normalizedName] != nil

        guard !normalizedSearchText.isEmpty else {
            return isCatalogBacked ? 0 : 1
        }

        if item.normalizedName == normalizedSearchText {
            return isCatalogBacked ? 0 : 1
        }

        if item.normalizedName.hasPrefix(normalizedSearchText) {
            return isCatalogBacked ? 2 : 3
        }

        if item.normalizedName.contains(normalizedSearchText) {
            return isCatalogBacked ? 4 : 5
        }

        return isCatalogBacked ? 6 : 7
    }

    private func normalized(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: #"[^\p{L}\p{N}]+"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview {
    AddShoppingItemSheet()
        .environmentObject(ShoppingCartStore.shared)
}
