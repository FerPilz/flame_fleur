import SwiftUI

struct ChefPilotCard: View {
    @Binding var isEnabled: Bool

    var body: some View {
        SurfaceCard(
            //backgroundColor: AppColors.basil2.opacity(0.17),
            backgroundColor: Color(
                red: 220 / 255,
                green: 207 / 255,
                blue: 194 / 255
            ).opacity(0.3),
            borderColor: .clear,
            cornerRadius: AppRadius.extraLarge,
            contentPadding: 0,
            showsShadow: false
        ) {
            HStack(spacing: AppSpacing.sm) {
                icon

                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("Chef Pilot")
                        .font(.system(size: 18, weight: .semibold, design: .serif))
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(1)

                    Text("Tap to have this recipe read and coach hands-free.")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Toggle("Chef Pilot", isOn: $isEnabled)
                    .labelsHidden()
                    .tint(AppColors.basil)
                    .accessibilityLabel("Chef Pilot")
                    .accessibilityValue(isEnabled ? "On" : "Off")
                    .accessibilityHint("Turns the Chef Pilot display on or off.")
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.xs)
            .frame(minHeight: 50)
        }
        .accessibilityElement(children: .contain)
    }

    private var icon: some View {
        Circle()
            .fill(AppColors.basil)
            .frame(width: 45, height: 45)
            .overlay {
                Image(systemName: "mic.fill")
                    .font(.system(size: 25, weight: .medium))
                    .foregroundStyle(AppColors.elevatedCardBackground)
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    ChefPilotCard(isEnabled: .constant(false))
        .padding()
        .background(AppColors.appBackground)
}
