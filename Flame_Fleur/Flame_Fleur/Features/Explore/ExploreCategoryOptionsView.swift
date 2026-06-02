import SwiftUI

struct ExploreCategoryOptionsView: View {
    let group: ExploreCategoryGroup

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedSubcategoryID: String?

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
                    AppHeaderAction(systemName: "cart", accessibilityLabel: "Shopping cart", badgeValue: 1),
                    AppHeaderAction(systemName: "person.crop.circle", accessibilityLabel: "Open profile")
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
                            isSelected: selectedSubcategoryID == subcategory.id
                        ) {
                            selectedSubcategoryID = selectedSubcategoryID == subcategory.id ? nil : subcategory.id
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

#Preview {
    ExploreCategoryOptionsView(group: SampleExploreCategories.groups[0])
}
