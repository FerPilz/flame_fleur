import SwiftUI

struct ExpandableRecipeStepRow: View {
    let stepNumber: Int
    let title: String
    let detail: String
    let durationText: String
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            SurfaceCard(
                backgroundColor: isExpanded ? AppColors.elevatedCardBackground : AppColors.cardBackground.opacity(0.62),
                borderColor: isExpanded ? AppColors.olive.opacity(0.30) : AppColors.warmBorder,
                cornerRadius: AppRadius.large,
                contentPadding: AppSpacing.sm,
                showsShadow: false
            ) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack(alignment: .center, spacing: AppSpacing.sm) {
                        Text("\(stepNumber)")
                            .font(AppTypography.metadata)
                            .foregroundStyle(isExpanded ? AppColors.elevatedCardBackground : AppColors.olive)
                            .frame(width: AppSpacing.xl, height: AppSpacing.xl)
                            .background(
                                Circle()
                                    .fill(isExpanded ? AppColors.olive : AppColors.softOlive)
                            )

                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            Text(title)
                                .font(AppTypography.bodyEmphasis)
                                .foregroundStyle(AppColors.primaryText)
                                .lineLimit(1)
                                .truncationMode(.tail)

                            if isExpanded {
                                Text(durationText)
                                    .font(AppTypography.metadata)
                                    .foregroundStyle(AppColors.olive)
                                    .lineLimit(1)
                            }
                        }

                        Spacer(minLength: AppSpacing.sm)

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.secondaryText)
                    }

                    if isExpanded {
                        Text(detail)
                            .font(AppTypography.callout)
                            .foregroundStyle(AppColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ExpandableRecipeStepRow(
        stepNumber: 2,
        title: "Cook Tomatoes",
        detail: "Add the cherry tomatoes to the pan and cook until they begin to burst.",
        durationText: "8 min",
        isExpanded: true,
        onTap: {}
    )
    .padding()
    .background(AppColors.appBackground)
}
