import SwiftUI

struct OnboardingReadyView: View {
    let heroRecipeImageName: String?
    let ingredientImageNames: [String]
    let onStartExploring: () -> Void
    let onPlanFirstMeal: () -> Void
    let onSkip: () -> Void

    var body: some View {
        OnboardingScaffold(currentStep: 4, onSkip: onSkip) {
            VStack(spacing: AppSpacing.sm) {
                Text("You’re ready.")
                    .font(.system(size: 28, weight: .semibold, design: .serif))
                    .foregroundStyle(AppColors.deepBasil)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)

                Text("Save recipes, plan your meals,\nand turn your plan into a grocery cart.")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(AppColors.secondaryText)
                    .lineSpacing(4)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: AppSpacing.sm) {
                readyCard(
                    title: "Save recipes",
                    detail: "Bookmark your favorites and keep them all in one place."
                ) {
                    OnboardingFeatureSnapshot(
                        kind: .favorites,
                        recipeImageName: heroRecipeImageName,
                        ingredientImageNames: ingredientImageNames
                    )
                }

                readyCard(
                    title: "Plan your meals",
                    detail: "Build your week with easy meal planning."
                ) {
                    OnboardingFeatureSnapshot(
                        kind: .planner,
                        recipeImageName: heroRecipeImageName,
                        ingredientImageNames: ingredientImageNames
                    )
                }

                readyCard(
                    title: "Get your groceries",
                    detail: "We’ll turn your plan into a smart grocery cart—grouped by aisle."
                ) {
                    OnboardingFeatureSnapshot(
                        kind: .cart,
                        recipeImageName: heroRecipeImageName,
                        ingredientImageNames: ingredientImageNames
                    )
                }
            }
        } footer: {
            VStack(spacing: AppSpacing.xs) {
                OnboardingPrimaryButton(title: "Start Exploring", action: onStartExploring)
                OnboardingSecondaryTextButton(title: "Plan My First Meal", action: onPlanFirstMeal)
            }
        }
    }

    private func readyCard<Preview: View>(
        title: String,
        detail: String,
        @ViewBuilder preview: () -> Preview
    ) -> some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            borderColor: AppColors.warmBorder,
            cornerRadius: AppRadius.extraLarge,
            contentPadding: AppSpacing.md
        ) {
            HStack(alignment: .top, spacing: AppSpacing.md) {
                preview()
                    .frame(width: 92, height: 92)

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(title)
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColors.primaryText)

                    Text(detail)
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

}
