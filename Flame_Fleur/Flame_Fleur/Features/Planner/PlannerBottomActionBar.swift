import SwiftUI

struct PlannerBottomActionBar: View {
    let didAddPlanToCart: Bool
    let onSharePlan: () -> Void
    let onAddPlanToCart: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            plannerActionButton(
                title: "Share Plan",
                systemImage: "square.and.arrow.up",
                foregroundColor: AppColors.basilGreen,
                backgroundColor: AppColors.elevatedCardBackground,
                borderColor: AppColors.basilGreen,
                action: onSharePlan
            )

            plannerActionButton(
                title: didAddPlanToCart ? "Added" : "Add plan to cart",
                systemImage: didAddPlanToCart ? "checkmark" : "basket",
                foregroundColor: AppColors.elevatedCardBackground,
                backgroundColor: AppColors.basilGreen,
                borderColor: AppColors.basilGreen,
                action: onAddPlanToCart
            )
        }
        .padding(.vertical, AppSpacing.xs)
        .padding(.horizontal, AppSpacing.xs)
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

    private func plannerActionButton(
        title: String,
        systemImage: String,
        foregroundColor: Color,
        backgroundColor: Color,
        borderColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: systemImage)
                    .font(AppTypography.caption)

                Text(title)
                    .font(AppTypography.smallButton)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .padding(.horizontal, AppSpacing.sm)
            .background(Capsule(style: .continuous).fill(backgroundColor))
            .overlay(Capsule(style: .continuous).stroke(borderColor, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PlannerBottomActionBar(
        didAddPlanToCart: false,
        onSharePlan: {},
        onAddPlanToCart: {}
    )
        .background(AppColors.appBackground)
}
