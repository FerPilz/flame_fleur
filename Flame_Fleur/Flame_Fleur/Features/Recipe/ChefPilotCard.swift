import SwiftUI

struct ChefPilotCard: View {
    @Binding var isEnabled: Bool

    var body: some View {
        SurfaceCard(
            backgroundColor: isEnabled ? AppColors.softOlive : AppColors.elevatedCardBackground,
            borderColor: isEnabled ? AppColors.olive.opacity(0.26) : AppColors.warmBorder,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.xs,
            showsShadow: false
        ) {
            HStack(spacing: AppSpacing.xs) {
                Circle()
                    .fill(isEnabled ? AppColors.olive : AppColors.softOlive)
                    .frame(width: AppSpacing.xxl - AppSpacing.xxs, height: AppSpacing.xxl - AppSpacing.xxs)
                    .overlay(
                        Image(systemName: "waveform")
                            .font(AppTypography.caption)
                            .foregroundStyle(isEnabled ? AppColors.elevatedCardBackground : AppColors.olive)
                    )

                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("Chef Pilot")
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(1)

                    Text(isEnabled ? "Guidance preview on" : "Hands-free guidance preview")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }

                Spacer(minLength: AppSpacing.sm)

                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .tint(AppColors.olive)
                    .scaleEffect(0.88)
            }
        }
    }
}

#Preview {
    ChefPilotCard(isEnabled: .constant(true))
        .padding()
        .background(AppColors.appBackground)
}
