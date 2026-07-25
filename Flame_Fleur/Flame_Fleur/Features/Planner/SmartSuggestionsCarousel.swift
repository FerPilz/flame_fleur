import SwiftUI

struct SmartSuggestionsCarousel: View {
    let recipes: [Recipe]
    let onAdd: (Recipe) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            SectionHeaderView("Smart Suggestions", actionTitle: "See all", style: .compact) {}

            HorizontalCarousel(
                items: recipes,
                visibleItemCount: 3,
                cardHeight: 180,
                edgePadding: 1
            ) { recipe in
                suggestionCard(recipe)
            }
        }
    }

    private func suggestionCard(_ recipe: Recipe) -> some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.medium,
            contentPadding: 0
        ) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    FoodImagePlaceholder(imageName: recipe.imageName, style: .card)
                        .frame(maxWidth: .infinity)
                        .frame(height: 114)
                        .clipped()

                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text(recipe.title)
                            .font(AppTypography.compactRecipeTitle)
                            .foregroundStyle(AppColors.primaryText)
                            .lineLimit(2)
                            .truncationMode(.tail)

                        HStack(spacing: AppSpacing.xxs) {
                            Image(systemName: "clock")
                                .font(AppTypography.metadata)

                            Text("\(recipe.cookingTimeText)  \(recipe.caloriesText)")
                                .font(AppTypography.metadata)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .minimumScaleFactor(0.76)
                        }
                        .foregroundStyle(AppColors.tertiaryText)
                    }
                    .padding(.horizontal, AppSpacing.xs)
                    .padding(.bottom, AppSpacing.xs)
                }

                IconCircleButton(
                    systemName: "plus",
                    accessibilityLabel: "Add \(recipe.title) to planner",
                    size: 24,
                    backgroundColor: AppColors.softOlive,
                    foregroundColor: AppColors.olive,
                    action: { onAdd(recipe) }
                )
                .padding(5)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                .fill(AppColors.elevatedCardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                .stroke(AppColors.warmBorder, lineWidth: 1)
        )
    }
}

#Preview {
    SmartSuggestionsCarousel(recipes: Array(RecipeRepository.shared.aiRecommendedRecipes.prefix(5))) { _ in }
        .padding()
        .background(AppColors.appBackground)
}
