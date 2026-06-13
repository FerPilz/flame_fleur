import SwiftUI

struct PlannerBottomActionBar: View {
    let didAddPlanToCart: Bool
    let didSavePlan: Bool
    let onAddPlanToCart: () -> Void
    let onSavePlan: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Button(action: onAddPlanToCart) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: didAddPlanToCart ? "checkmark" : "basket")
                        .font(AppTypography.caption)

                    Text(didAddPlanToCart ? "Added" : "Add plan to cart")
                        .font(AppTypography.smallButton)
                        .lineLimit(1)
                }
                .foregroundStyle(AppColors.olive)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Capsule(style: .continuous).fill(AppColors.elevatedCardBackground))
                .overlay(Capsule(style: .continuous).stroke(AppColors.warmBorder, lineWidth: 1))
            }
            .buttonStyle(.plain)

            PrimaryButton(
                didSavePlan ? "Saved" : "Save Plan",
                systemImage: didSavePlan ? "checkmark" : nil,
                style: .recipe,
                isFullWidth: true,
                height: 40,
                horizontalPadding: AppSpacing.md,
                action: onSavePlan
            )
        }
        .padding(AppSpacing.xs)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous)
                .fill(AppColors.elevatedCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous)
                        .stroke(AppColors.warmBorder, lineWidth: 1)
                )
        )
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, AppSpacing.xxs)
        .padding(.bottom, AppSpacing.xxs)
        .background(AppColors.appBackground.opacity(0.96))
    }
}

#Preview {
    PlannerBottomActionBar(
        didAddPlanToCart: false,
        didSavePlan: false,
        onAddPlanToCart: {},
        onSavePlan: {}
    )
        .background(AppColors.appBackground)
}
