import SwiftUI

struct IngredientChip: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xxs) {
                Text(title)
                    .font(AppTypography.caption)
                    .lineLimit(1)

                Image(systemName: "xmark")
                    .font(AppTypography.metadata)
            }
            .foregroundStyle(AppColors.elevatedCardBackground)
            .padding(.horizontal, AppSpacing.sm)
            .frame(height: 30)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .fill(AppColors.basilGreen)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .stroke(AppColors.deepBasil, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Remove \(title) filter")
    }
}

#Preview {
    IngredientChip(title: "Tomatoes") {}
        .padding()
        .background(AppColors.appBackground)
}
