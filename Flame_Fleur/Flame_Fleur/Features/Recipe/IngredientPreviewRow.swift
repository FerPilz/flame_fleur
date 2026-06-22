import SwiftUI

struct IngredientPreviewRow: View {
    let ingredient: RecipeIngredient

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Circle()
                .fill(AppColors.softOlive)
                .frame(width: AppSpacing.lg, height: AppSpacing.lg)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(AppTypography.tabLabel)
                        .foregroundStyle(AppColors.olive)
                )
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.displayLine)
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if !ingredient.category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(ingredient.category)
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: AppSpacing.sm)
        }
    }
}

#Preview {
    IngredientPreviewRow(ingredient: RecipeIngredient(legacyName: "fresh basil"))
        .padding()
        .background(AppColors.appBackground)
}
