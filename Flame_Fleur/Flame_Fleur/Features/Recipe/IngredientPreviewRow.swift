import SwiftUI

struct IngredientPreviewRow: View {
    let ingredient: String

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Circle()
                .fill(AppColors.softOlive)
                .frame(width: AppSpacing.lg, height: AppSpacing.lg)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(AppTypography.tabLabel)
                        .foregroundStyle(AppColors.olive)
                )

            Text(ingredient.capitalized)
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer(minLength: AppSpacing.sm)
        }
    }
}

#Preview {
    IngredientPreviewRow(ingredient: "fresh basil")
        .padding()
        .background(AppColors.appBackground)
}
