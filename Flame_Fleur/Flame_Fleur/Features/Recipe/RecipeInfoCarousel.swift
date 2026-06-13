import SwiftUI

struct RecipeInfoCarousel: View {
    let recipe: Recipe

    var body: some View {
        HorizontalCarousel(
            items: metrics,
            visibleItemCount: 2.74,
            itemSpacing: AppSpacing.xs,
            cardHeight: 68,
            edgePadding: AppSpacing.xxs
        ) { metric in
            SurfaceCard(
                backgroundColor: AppColors.elevatedCardBackground,
                borderColor: AppColors.warmBorder,
                cornerRadius: AppRadius.large,
                contentPadding: AppSpacing.xs,
                showsShadow: false
            ) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: metric.systemImage)
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.olive)

                        Text(metric.title)
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.secondaryText)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }

                    Text(metric.value)
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
        }
    }

    private var metrics: [RecipeInfoMetric] {
        [
            RecipeInfoMetric(title: "Total Time", value: recipe.totalTimeText, systemImage: "timer"),
            RecipeInfoMetric(title: "Prep", value: recipe.prepTimeText, systemImage: "leaf"),
            RecipeInfoMetric(title: "Cook", value: recipe.cookingTimeText, systemImage: "flame"),
            RecipeInfoMetric(title: "Calories", value: recipe.caloriesText, systemImage: "chart.bar"),
            RecipeInfoMetric(title: "Protein", value: "\(recipe.nutrition.proteinGrams) g", systemImage: "fork.knife"),
            RecipeInfoMetric(title: "Carbs", value: "\(recipe.nutrition.carbsGrams) g", systemImage: "chart.pie"),
            RecipeInfoMetric(title: "Fat", value: "\(recipe.nutrition.fatGrams) g", systemImage: "drop"),
            RecipeInfoMetric(title: "Servings", value: recipe.servingsText, systemImage: "person.2"),
            RecipeInfoMetric(title: "Difficulty", value: recipe.difficulty.title, systemImage: "gauge.with.dots.needle.33percent")
        ]
    }
}

private struct RecipeInfoMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let systemImage: String
}

#Preview {
    RecipeInfoCarousel(recipe: RecipeRepository.shared.allRecipes[0])
        .padding()
        .background(AppColors.appBackground)
}
