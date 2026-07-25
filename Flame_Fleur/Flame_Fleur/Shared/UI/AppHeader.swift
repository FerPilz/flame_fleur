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
    let titleFont: Font
    let leadingActions: [AppHeaderAction]
    let trailingActions: [AppHeaderAction]

    init(
        title: String = AppBrandTitle.defaultTitle,
        titleFont: Font = AppTypography.allSpicedBrandTitle,
        leadingActions: [AppHeaderAction] = [],
        trailingActions: [AppHeaderAction] = []
    ) {
        self.title = title
        self.titleFont = titleFont
        self.leadingActions = leadingActions
        self.trailingActions = trailingActions
    }

    var body: some View {
        ZStack {
            AppBrandTitle(title: title, titleFont: titleFont)

            HStack(spacing: AppSpacing.sm) {
                actionGroup(leadingActions, isLeading: true)
                Spacer(minLength: 0)
                actionGroup(trailingActions, isLeading: false)
            }
        }
        .frame(height: 44)
    }

    private func actionGroup(_ actions: [AppHeaderAction], isLeading: Bool) -> some View {
        HStack(spacing: AppSpacing.xs) {
            ForEach(actions) { action in
                IconCircleButton(
                    systemName: action.systemName,
                    accessibilityLabel: action.accessibilityLabel,
                    badgeValue: action.badgeValue,
                    size: AppTopActionMetrics.buttonSize,
                    backgroundColor: AppColors.elevatedCardBackground,
                    foregroundColor: AppColors.darkOlive,
                    action: action.action
                )
            }
        }
        .frame(width: AppTopActionMetrics.actionGroupWidth, alignment: isLeading ? .leading : .trailing)
    }
}

#Preview {
    AppHeader(
        leadingActions: [AppHeaderAction(systemName: "line.3.horizontal", accessibilityLabel: "Menu")],
        trailingActions: [
            AppHeaderAction(systemName: "cart", accessibilityLabel: "Cart", badgeValue: 4)
        ]
    )
    .padding()
    .background(AppColors.appBackground)
}
