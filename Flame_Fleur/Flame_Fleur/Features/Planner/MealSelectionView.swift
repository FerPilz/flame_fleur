import SwiftUI

struct MealSelectionView: View {
    let date: Date
    let slot: MealSlot
    let recipes: [Recipe]
    let onSelect: (Recipe) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filteredRecipes: [Recipe] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return recipes
        }

        return recipes.filter { recipe in
            recipe.title.localizedCaseInsensitiveContains(query)
            || recipe.subtitle.localizedCaseInsensitiveContains(query)
            || recipe.tags.contains { $0.localizedCaseInsensitiveContains(query) }
            || recipe.ingredients.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                header
                searchField

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: AppSpacing.xs) {
                        ForEach(filteredRecipes) { recipe in
                            MealSelectionRecipeRow(recipe: recipe) {
                                onSelect(recipe)
                                dismiss()
                            }
                        }
                    }
                    .padding(.bottom, AppSpacing.lg)
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.lg)
            .background(AppColors.appBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            IconCircleButton(
                systemName: "chevron.left",
                accessibilityLabel: "Close meal picker",
                size: AppTopActionMetrics.buttonSize,
                action: { dismiss() }
            )

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text("Add \(slot.title)")
                    .font(AppTypography.heroTitle)
                    .foregroundStyle(AppColors.primaryText)

                Text(date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.secondaryText)
            }

            Spacer()
        }
    }

    private var searchField: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)

            TextField("Search recipes", text: $searchText)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)
                .tint(AppColors.olive)
        }
        .padding(.horizontal, AppSpacing.sm)
        .frame(height: 42)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                .fill(AppColors.elevatedCardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                .stroke(AppColors.warmBorder, lineWidth: 1)
        )
    }
}

private struct MealSelectionRecipeRow: View {
    let recipe: Recipe
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            SurfaceCard(
                backgroundColor: AppColors.elevatedCardBackground,
                cornerRadius: AppRadius.large,
                contentPadding: AppSpacing.xs
            ) {
                HStack(spacing: AppSpacing.sm) {
                    FoodImagePlaceholder(imageName: recipe.imageName, style: .thumbnail)
                        .frame(width: 52, height: 46)

                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text(recipe.title)
                            .font(AppTypography.cardTitle)
                            .foregroundStyle(AppColors.primaryText)
                            .lineLimit(1)

                        Text("\(recipe.caloriesText) · \(recipe.totalTimeText) · \(recipe.difficulty.title)")
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.secondaryText)
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: "plus")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.olive)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(AppColors.softOlive))
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Add \(recipe.title)"))
    }
}

#Preview {
    MealSelectionView(
        date: Date(),
        slot: .dinner,
        recipes: RecipeRepository.shared.allRecipes,
        onSelect: { _ in }
    )
}
