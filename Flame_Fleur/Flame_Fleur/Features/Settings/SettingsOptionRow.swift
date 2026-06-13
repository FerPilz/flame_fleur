import SwiftUI

struct SettingsOptionRow<Trailing: View>: View {
    let systemImage: String
    let iconBackground: Color
    let iconForeground: Color
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
    let trailing: Trailing

    init(
        systemImage: String,
        iconBackground: Color = AppColors.softOlive,
        iconForeground: Color = AppColors.olive,
        title: String,
        subtitle: String? = nil,
        action: (() -> Void)? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.systemImage = systemImage
        self.iconBackground = iconBackground
        self.iconForeground = iconForeground
        self.title = title
        self.subtitle = subtitle
        self.action = action
        self.trailing = trailing()
    }

    var body: some View {
        Group {
            if let action {
                Button(action: action) {
                    rowContent
                }
                .buttonStyle(.plain)
            } else {
                rowContent
            }
        }
    }

    private var rowContent: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: systemImage)
                .font(AppTypography.metadata)
                .foregroundStyle(iconForeground)
                .frame(width: 28, height: 28)
                .background(Circle().fill(iconBackground))

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(title)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)

                if let subtitle {
                    Text(subtitle)
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                }
            }

            Spacer(minLength: AppSpacing.xs)

            trailing
        }
        .frame(minHeight: 50)
        .padding(.horizontal, AppSpacing.sm)
        .contentShape(Rectangle())
    }
}

struct SettingsRowValue: View {
    let text: String
    let badge: String?
    let showsChevron: Bool

    init(
        _ text: String,
        badge: String? = nil,
        showsChevron: Bool = true
    ) {
        self.text = text
        self.badge = badge
        self.showsChevron = showsChevron
    }

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            if let badge {
                Text(badge)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.premiumGold)
                    .padding(.horizontal, AppSpacing.xs)
                    .frame(height: 20)
                    .background(Capsule(style: .continuous).fill(AppColors.premiumGold.opacity(0.14)))
            }

            Text(text)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.tertiaryText)
            }
        }
    }
}

struct SettingsToggleControl: View {
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: AppRadius.pill, style: .continuous)
                .fill(isOn ? AppColors.olive : AppColors.cardBackground)
                .frame(width: 44, height: 24)
                .overlay(alignment: isOn ? .trailing : .leading) {
                    Circle()
                        .fill(AppColors.elevatedCardBackground)
                        .frame(width: 18, height: 18)
                        .padding(.horizontal, 3)
                        .shadow(color: AppColors.shadow.opacity(0.12), radius: 2, x: 0, y: 1)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.pill, style: .continuous)
                        .stroke(AppColors.warmBorder.opacity(isOn ? 0 : 0.72), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(isOn ? "On" : "Off"))
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}

struct SettingsVisibilityControl: View {
    let isPrivate: Bool
    let onSelect: (Bool) -> Void

    var body: some View {
        HStack(spacing: 2) {
            segment(title: "Public", systemImage: "globe", isSelected: !isPrivate) {
                onSelect(false)
            }

            segment(title: "Private", systemImage: "lock.fill", isSelected: isPrivate) {
                onSelect(true)
            }
        }
        .padding(2)
        .background(Capsule(style: .continuous).fill(AppColors.cardBackground))
        .overlay(Capsule(style: .continuous).stroke(AppColors.warmBorder, lineWidth: 1))
    }

    private func segment(
        title: String,
        systemImage: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xxs) {
                Image(systemName: systemImage)
                    .font(.system(size: 8, weight: .semibold))

                Text(title)
                    .font(AppTypography.metadata)
            }
            .foregroundStyle(isSelected ? AppColors.elevatedCardBackground : AppColors.secondaryText)
            .padding(.horizontal, AppSpacing.xs)
            .frame(height: 22)
            .background(
                Capsule(style: .continuous)
                    .fill(isSelected ? AppColors.olive : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct SettingsRowDivider: View {
    var body: some View {
        Rectangle()
            .fill(AppColors.warmBorder.opacity(0.72))
            .frame(height: 1)
            .padding(.leading, 52)
    }
}

#Preview {
    SettingsSectionCard(title: "Privacy") {
        SettingsOptionRow(
            systemImage: "lock.fill",
            title: "Profile visibility",
            subtitle: "Choose who can see your profile"
        ) {
            SettingsVisibilityControl(isPrivate: true) { _ in }
        }

        SettingsRowDivider()

        SettingsOptionRow(systemImage: "eye.fill", title: "Activity visibility") {
            SettingsToggleControl(isOn: true) {}
        }
    }
    .padding()
    .background(AppColors.appBackground)
}
