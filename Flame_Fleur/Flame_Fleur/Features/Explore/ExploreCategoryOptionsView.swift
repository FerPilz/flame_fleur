import SwiftUI

struct ExploreCategoryOptionsView: View {
    let group: ExploreCategoryGroup
    let onSubcategorySelected: (ExploreSubcategory) -> Void
    let onCartSelected: () -> Void
    let onProfileSelected: () -> Void
    let onSettingsSelected: () -> Void

    @EnvironmentObject private var shoppingCartStore: ShoppingCartStore
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedSubcategoryID: String?

    init(
        group: ExploreCategoryGroup,
        onSubcategorySelected: @escaping (ExploreSubcategory) -> Void = { _ in },
        onCartSelected: @escaping () -> Void = {},
        onProfileSelected: @escaping () -> Void = {},
        onSettingsSelected: @escaping () -> Void = {}
    ) {
        self.group = group
        self.onSubcategorySelected = onSubcategorySelected
        self.onCartSelected = onCartSelected
        self.onProfileSelected = onProfileSelected
        self.onSettingsSelected = onSettingsSelected
    }

    var body: some View {
        AppScreen(
            contentSpacing: AppSpacing.lg,
            headerTopPadding: AppSpacing.xs,
            contentBottomPadding: AppSpacing.xxxl + AppSpacing.xxl
        ) {
            AppHeader(
                leadingActions: [
                    AppHeaderAction(systemName: "chevron.left", accessibilityLabel: "Back") {
                        dismiss()
                    }
                ],
                trailingActions: [
                    AppHeaderAction(systemName: "cart", accessibilityLabel: "Shopping cart", badgeValue: shoppingCartStore.totalItemCount) {
                        onCartSelected()
                    }
                ]
            )
        } content: {
            titleBlock
            searchBar

            if filteredSubcategories.isEmpty {
                emptySearchState
            } else {
                LazyVGrid(columns: categoryColumns, spacing: AppSpacing.lg) {
                    ForEach(filteredSubcategories) { subcategory in
                        CategoryCircleCard(
                            title: subcategory.title,
                            imageName: subcategory.imageName,
                            diameter: ExploreCategoryOptionsLayoutMetrics.subcategoryCircleDiameter,
                            titleFont: AppTypography.exploreSubcategoryCircleLabel,
                            isSelected: selectedSubcategoryID == subcategory.id
                        ) {
                            if selectedSubcategoryID == subcategory.id {
                                selectedSubcategoryID = nil
                            } else {
                                selectedSubcategoryID = subcategory.id
                            }

                            onSubcategorySelected(subcategory)
                        }
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var titleBlock: some View {
        VStack(spacing: AppSpacing.xxs) {
            Text(group.title)
                .font(AppTypography.screenTitle)
                .foregroundStyle(AppColors.olive)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .accessibilityAddTraits(.isHeader)

            Text(group.subtitle)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpacing.xs)
    }

    private var searchBar: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.tertiaryText)

            TextField(
                "",
                text: $searchText,
                prompt: Text("Search cuisines")
                    .foregroundStyle(AppColors.tertiaryText)
            )
            .font(AppTypography.callout)
            .foregroundStyle(AppColors.primaryText)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        }
        .padding(.horizontal, AppSpacing.sm)
        .frame(height: 36)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                .fill(AppColors.elevatedCardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                .stroke(AppColors.warmBorder, lineWidth: 1)
        )
    }

    private var emptySearchState: some View {
        SurfaceCard(cornerRadius: AppRadius.large, contentPadding: AppSpacing.sm) {
            Text("No options match this search yet.")
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.secondaryText)
        }
    }

    private var categoryColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: AppSpacing.sm), count: 3)
    }

    private var filteredSubcategories: [ExploreSubcategory] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedSearch.isEmpty else {
            return group.subcategories
        }

        return group.subcategories.filter { subcategory in
            subcategory.title.localizedCaseInsensitiveContains(trimmedSearch)
            || subcategory.category?.title.localizedCaseInsensitiveContains(trimmedSearch) == true
        }
    }
}

private enum ExploreCategoryOptionsLayoutMetrics {
    static let subcategoryCircleDiameter: CGFloat = 112.2
}

#Preview {
    ExploreCategoryOptionsView(group: SampleExploreCategories.groups[0])
        .environmentObject(ShoppingCartStore.shared)
}
