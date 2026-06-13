import SwiftUI

struct IngredientChecklistRow: View {
    let ingredient: String
    let amountText: String
    let unitText: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(isSelected ? AppColors.olive : AppColors.tertiaryText)
                    .frame(width: AppSpacing.lg)

                Text(amountText)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)
                    .frame(width: 36, alignment: .leading)
                    .lineLimit(1)

                Text(unitText)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.tertiaryText)
                    .frame(width: 48, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(ingredient.capitalized)
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .truncationMode(.tail)

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
        ingredient: "Fresh basil",
        amountText: "1/2",
        unitText: "cup",
        isSelected: true,
        onTap: {}
    )
    .padding()
    .background(AppColors.appBackground)
}
