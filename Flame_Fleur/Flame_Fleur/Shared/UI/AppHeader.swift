import SwiftUI

struct AppHeaderAction: Identifiable {
    let id = UUID()
    let systemName: String
    let accessibilityLabel: String
    let badgeValue: Int?
    let action: () -> Void

    init(
        systemName: String,
        accessibilityLabel: String,
        badgeValue: Int? = nil,
        action: @escaping () -> Void = {}
    ) {
        self.systemName = systemName
        self.accessibilityLabel = accessibilityLabel
        self.badgeValue = badgeValue
        self.action = action
    }
}

struct AppHeader: View {
    let title: String
    let leadingActions: [AppHeaderAction]
    let trailingActions: [AppHeaderAction]

    init(
        title: String = "Flame & Fleur",
        leadingActions: [AppHeaderAction] = [],
        trailingActions: [AppHeaderAction] = []
    ) {
        self.title = title
        self.leadingActions = leadingActions
        self.trailingActions = trailingActions
    }

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            actionGroup(leadingActions, isLeading: true)

            Spacer(minLength: AppSpacing.xs)

            Text(title)
                .font(AppTypography.brandTitle)
                .foregroundStyle(AppColors.olive)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .allowsTightening(true)
                .frame(maxWidth: .infinity)
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: AppSpacing.xs)

            actionGroup(trailingActions, isLeading: false)
        }
        .frame(height: 34)
    }

    private func actionGroup(_ actions: [AppHeaderAction], isLeading: Bool) -> some View {
        HStack(spacing: AppSpacing.xs) {
            ForEach(actions) { action in
                IconCircleButton(
                    systemName: action.systemName,
                    accessibilityLabel: action.accessibilityLabel,
                    badgeValue: action.badgeValue,
                    size: 30,
                    backgroundColor: AppColors.appBackground,
                    foregroundColor: AppColors.darkOlive,
                    action: action.action
                )
            }
        }
        .frame(width: 68, alignment: isLeading ? .leading : .trailing)
    }
}

#Preview {
    AppHeader(
        leadingActions: [AppHeaderAction(systemName: "line.3.horizontal", accessibilityLabel: "Menu")],
        trailingActions: [
            AppHeaderAction(systemName: "cart", accessibilityLabel: "Cart", badgeValue: 1),
            AppHeaderAction(systemName: "person.crop.circle", accessibilityLabel: "Profile")
        ]
    )
    .padding()
    .background(AppColors.appBackground)
}
