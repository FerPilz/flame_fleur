import SwiftUI

struct SmartSuggestionsCarousel: View {
    let recipes: [Recipe]
    let onAdd: (Recipe) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            SectionHeaderView("Smart Suggestions", actionTitle: "See all", style: .compact) {}

            HorizontalCarousel(
                items: recipes,
                visibleItemCount: 1.88,
                cardHeight: 70,
                edgePadding: 1
            ) { recipe in
                suggestionCard(recipe)
            }
        }
    }

    private func suggestionCard(_ recipe: Recipe) -> some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.xs
        ) {
            HStack(spacing: AppSpacing.xs) {
                FoodImagePlaceholder(imageName: recipe.imageName, style: .thumbnail)
                    .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 2) {
                    Text(recipe.title)
                        .font(AppTypography.compactRecipeTitle)
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)

                    Text("\(recipe.caloriesText) · \(recipe.totalTimeText)")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                IconCircleButton(
                    systemName: "plus",
                    accessibilityLabel: "Add \(recipe.title) to planner",
                    size: 26,
                    backgroundColor: AppColors.softOlive,
                    foregroundColor: AppColors.olive,
                    action: { onAdd(recipe) }
                )
            }
        }
    }
}

#Preview {
    SmartSuggestionsCarousel(recipes: Array(RecipeRepository.shared.aiRecommendedRecipes.prefix(5))) { _ in }
        .padding()
        .background(AppColors.appBackground)
}
