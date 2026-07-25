import SwiftUI

struct RecipeIntroView: View {
    let recipe: Recipe
    let onBack: () -> Void
    let onStartCooking: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                FoodImagePlaceholder(imageName: recipe.imageName, style: .hero)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea()

                LinearGradient(
                    colors: [
                        AppColors.shadow.opacity(0.42),
                        .clear,
                        AppColors.shadow.opacity(0.28)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    topBar

                    Spacer(minLength: 0)

                    bottomAction
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, max(proxy.safeAreaInsets.top + AppSpacing.xxs, AppTopActionMetrics.minimumTopOffset))
                .padding(.bottom, proxy.safeAreaInsets.bottom + AppSpacing.sm)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .background(AppColors.appBackground.ignoresSafeArea())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.appBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }

    private var topBar: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            IconCircleButton(
                systemName: "chevron.left",
                accessibilityLabel: "Back",
                size: AppTopActionMetrics.buttonSize,
                backgroundColor: AppColors.elevatedCardBackground.opacity(0.94),
                foregroundColor: AppColors.darkOlive,
                action: onBack
            )

            Spacer(minLength: 0)

            Text(recipe.title)
                .font(AppTypography.recipeDetailTitle)
                .foregroundStyle(AppColors.elevatedCardBackground)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xxs)
                .background(
                    Capsule(style: .continuous)
                        .fill(AppColors.shadow.opacity(0.25))
                )

            Spacer(minLength: 0)

            Color.clear
                .frame(width: AppTopActionMetrics.buttonSize, height: AppTopActionMetrics.buttonSize)
        }
    }

    private var bottomAction: some View {
        Button(action: onStartCooking) {
            HStack(spacing: AppSpacing.xxs) {
                Text("Let’s cook it")
                    .font(AppTypography.button)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(AppColors.elevatedCardBackground)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.hero, style: .continuous)
                    .fill(AppColors.deepBasil)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.hero, style: .continuous)
                    .stroke(AppColors.elevatedCardBackground.opacity(0.18), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RecipeIntroView(
        recipe: RecipeRepository.shared.featuredRecipes[0],
        onBack: {},
        onStartCooking: {}
    )
}
