import SwiftUI

struct IngredientSearchScreen: View {
    let availableIngredients: [ShoppingIngredientCatalogItem]
    @Binding var draftSelection: [String]
    @Binding var ingredientSearchText: String
    let matchingRecipes: [Recipe]
    let onDismiss: () -> Void
    let onApply: () -> Void

    @FocusState private var isSearchFocused: Bool
    @State private var recipeNavigationPath: [Recipe.ID] = []

    var body: some View {
        NavigationStack(path: $recipeNavigationPath) {
            AppScreen(
                contentSpacing: 0,
                headerTopPadding: AppSpacing.xs,
                contentHorizontalPadding: AppSpacing.md,
                contentTopPadding: 6,
                contentBottomPadding: 0,
                scrollsContent: false
            ) {
                AppHeader(
                    leadingActions: [
                        AppHeaderAction(systemName: "chevron.left", accessibilityLabel: "Cancel ingredient filters", action: onDismiss)
                    ]
                )
            } content: {
                ingredientSearchField

                IngredientSearchView(
                    availableIngredients: availableIngredients,
                    draftSelection: $draftSelection,
                    ingredientSearchText: $ingredientSearchText,
                    recipeSearchText: "",
                    matchingRecipes: matchingRecipes,
                    onRecipeSelected: { recipeNavigationPath.append($0) }
                )
                .padding(.top, 7)
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                actionBar
            }
            .navigationDestination(for: Recipe.ID.self) { recipeID in
                RecipeDetailView(
                    recipeID: recipeID,
                    onBack: { recipeNavigationPath.removeLast() }
                )
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var ingredientSearchField: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.tertiaryText)

            TextField(
                "",
                text: $ingredientSearchText,
                prompt: Text("Search ingredients").foregroundStyle(AppColors.tertiaryText)
            )
            .font(AppTypography.callout)
            .foregroundStyle(AppColors.primaryText)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($isSearchFocused)

            if !ingredientSearchText.isEmpty {
                Button {
                    ingredientSearchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.tertiaryText)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear ingredient search")
            }
        }
        .padding(.horizontal, 11)
        .frame(height: 42)
        .background(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous).fill(AppColors.elevatedCardBackground))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                .stroke(isSearchFocused ? AppColors.deepBasil : AppColors.warmBorder, lineWidth: 1)
        )
    }

    private var actionBar: some View {
        HStack(spacing: 10) {
            actionButton("Clear all", isPrimary: false) {
                draftSelection.removeAll()
                ingredientSearchText = ""
            }
            .accessibilityLabel("Clear all ingredient filters")

            actionButton("Show results (\(matchingRecipes.count))", isPrimary: true, action: onApply)
                .disabled(!canApply)
                .opacity(canApply ? 1 : 0.48)
                .accessibilityLabel("Apply \(draftSelection.count) ingredient filters and show \(matchingRecipes.count) results")
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.xs)
        .background(AppColors.appBackground)
        .overlay(alignment: .top) {
            Rectangle().fill(AppColors.warmBorder).frame(height: 1)
        }
    }

    private var canApply: Bool {
        !draftSelection.isEmpty && !matchingRecipes.isEmpty
    }

    private func actionButton(
        _ title: String,
        isPrimary: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.ingredientActionButton)
                .foregroundStyle(isPrimary ? AppColors.elevatedCardBackground : AppColors.olive)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .allowsTightening(true)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(Capsule(style: .continuous).fill(isPrimary ? AppColors.darkOlive : AppColors.elevatedCardBackground))
        .overlay(Capsule(style: .continuous).stroke(isPrimary ? AppColors.darkOlive : AppColors.warmBorder, lineWidth: 1))
        .buttonStyle(.plain)
    }
}
