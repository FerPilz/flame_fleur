import SwiftUI

struct OnboardingFeatureSnapshot: View {
    enum Kind {
        case favorites
        case planner
        case cart
    }

    let kind: Kind
    let recipeImageName: String?
    let ingredientImageNames: [String]

    var body: some View {
        SurfaceCard(
            backgroundColor: AppColors.porcelainCream,
            borderColor: AppColors.warmBorder.opacity(0.8),
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.xs
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                snapshotHeader

                switch kind {
                case .favorites:
                    favoritesSnapshot
                case .planner:
                    plannerSnapshot
                case .cart:
                    cartSnapshot
                }
            }
        }
    }

    private var snapshotHeader: some View {
        HStack(spacing: AppSpacing.xxs) {
            Image(systemName: headerIcon)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(AppColors.basilGreen)

            Text(headerTitle)
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(AppColors.deepBasil)

            Spacer(minLength: 0)
        }
    }

    private var favoritesSnapshot: some View {
        ZStack(alignment: .bottomTrailing) {
            FoodImagePlaceholder(imageName: recipeImageName, style: .card)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Image(systemName: "heart.fill")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(AppColors.elevatedCardBackground)
                .padding(6)
                .background(Circle().fill(AppColors.basilGreen))
                .padding(AppSpacing.xxs)
        }
    }

    private var plannerSnapshot: some View {
        VStack(spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.xxs) {
                ForEach(["M", "T", "W"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(AppColors.secondaryText)
                        .frame(maxWidth: .infinity)
                }
            }

            HStack(spacing: AppSpacing.xxs) {
                ForEach(0..<3, id: \.self) { _ in
                    FoodImagePlaceholder(imageName: recipeImageName, style: .thumbnail)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }

    private var cartSnapshot: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            ForEach(Array(ingredientImageNames.prefix(3).enumerated()), id: \.offset) { _, imageName in
                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(AppColors.basilGreen)

                    FoodImagePlaceholder(imageName: imageName, style: .circle)
                        .frame(width: 16, height: 16)

                    Capsule(style: .continuous)
                        .fill(AppColors.warmBorder)
                        .frame(height: 6)
                }
            }
        }
    }

    private var headerTitle: String {
        switch kind {
        case .favorites:
            return "Favorites"
        case .planner:
            return "Meal Planner"
        case .cart:
            return "Shopping List"
        }
    }

    private var headerIcon: String {
        switch kind {
        case .favorites:
            return "heart.fill"
        case .planner:
            return "calendar"
        case .cart:
            return "cart.fill"
        }
    }
}
