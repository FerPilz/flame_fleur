import SwiftUI

struct IngredientChecklistRow: View {
    let ingredient: RecipeIngredient
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: AppSpacing.sm) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(isSelected ? AppColors.olive : AppColors.tertiaryText)
                    .frame(width: AppSpacing.lg)
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

                Spacer(minLength: AppSpacing.xs)
            }
            .padding(.vertical, AppSpacing.xs)
            .padding(.horizontal, AppSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .fill(isSelected ? AppColors.softOlive.opacity(0.36) : AppColors.elevatedCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .stroke(AppColors.warmBorder.opacity(0.72), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    IngredientChecklistRow(
        ingredient: RecipeIngredient(
            name: "Fresh basil",
            quantity: 1,
            unit: "bunch",
            category: "Produce",
            displayQuantity: "1 bunch"
        ),
        isSelected: true,
        onTap: {}
    )
    .padding()
    .background(AppColors.appBackground)
}
