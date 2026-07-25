import SwiftUI

struct ChefPilotCard: View {
    let state: ChefPilotController.State
    let currentStepIndex: Int?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            SurfaceCard(
                backgroundColor: cardBackgroundColor,
                borderColor: cardBorderColor,
                cornerRadius: AppRadius.large,
                contentPadding: AppSpacing.xs,
                showsShadow: false
            ) {
                HStack(spacing: AppSpacing.xs) {
                    Circle()
                        .fill(iconBackgroundColor)
                        .frame(width: AppSpacing.xxl - AppSpacing.xxs, height: AppSpacing.xxl - AppSpacing.xxs)
                        .overlay(
                            Image(systemName: iconName)
                                .font(AppTypography.caption)
                                .foregroundStyle(iconForegroundColor)
                        )

                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        HStack(spacing: AppSpacing.xs) {
                            Text("Chef Pilot")
                                .font(AppTypography.bodyEmphasis)
                                .foregroundStyle(AppColors.primaryText)
                                .lineLimit(1)

                            Text(stateBadgeTitle)
                                .font(AppTypography.metadata)
                                .foregroundStyle(stateBadgeTextColor)
                                .padding(.horizontal, AppSpacing.xs)
                                .frame(height: 22)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(stateBadgeBackgroundColor)
                                )
                        }

                        Text(statusText)
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.secondaryText)
                            .lineLimit(2)
                            .truncationMode(.tail)
                    }

                    Spacer(minLength: AppSpacing.sm)

                    Image(systemName: state == .idle ? "power" : "stop.fill")
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.olive)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var cardBackgroundColor: Color {
        switch state {
        case .idle:
            AppColors.elevatedCardBackground
        case .announcing:
            AppColors.softOrange.opacity(0.52)
        case .listening:
            AppColors.softOlive
        case .speaking:
            AppColors.softOrange.opacity(0.34)
        }
    }

    private var cardBorderColor: Color {
        switch state {
        case .idle:
            AppColors.warmBorder
        case .announcing:
            AppColors.burntOrange.opacity(0.30)
        case .listening:
            AppColors.olive.opacity(0.26)
        case .speaking:
            AppColors.burntOrange.opacity(0.26)
        }
    }

    private var iconBackgroundColor: Color {
        switch state {
        case .idle:
            AppColors.softOlive
        case .announcing:
            AppColors.burntOrange
        case .listening:
            AppColors.olive
        case .speaking:
            AppColors.burntOrange
        }
    }

    private var iconForegroundColor: Color {
        switch state {
        case .idle:
            AppColors.olive
        case .announcing, .listening, .speaking:
            AppColors.elevatedCardBackground
        }
    }

    private var iconName: String {
        switch state {
        case .idle:
            "mic"
        case .announcing:
            "speaker.wave.2.fill"
        case .listening:
            "waveform"
        case .speaking:
            "text.bubble.fill"
        }
    }

    private var stateBadgeTitle: String {
        switch state {
        case .idle:
            "Off"
        case .announcing:
            "Ready"
        case .listening:
            "Listening"
        case .speaking:
            "Speaking"
        }
    }

    private var stateBadgeBackgroundColor: Color {
        switch state {
        case .idle:
            AppColors.cardBackground
        case .announcing:
            AppColors.softOrange
        case .listening:
            AppColors.softOlive
        case .speaking:
            AppColors.softOrange
        }
    }

    private var stateBadgeTextColor: Color {
        switch state {
        case .idle:
            AppColors.secondaryText
        case .announcing:
            AppColors.burntOrange
        case .listening:
            AppColors.darkOlive
        case .speaking:
            AppColors.burntOrange
        }
    }

    private var statusText: String {
        switch state {
        case .idle:
            "Hands-free recipe reader"
        case .announcing:
            "Chef Pilot is introducing the available voice commands."
        case .listening:
            "Listening for start, next, repeat, or stop."
        case .speaking:
            if let currentStepIndex {
                "Reading step \(currentStepIndex + 1) aloud."
            } else {
                "Reading the recipe aloud."
            }
        }
    }
}

#Preview {
    ChefPilotCard(state: .listening, currentStepIndex: 0, action: {})
        .padding()
        .background(AppColors.appBackground)
}
