import SwiftUI

struct SectionHeaderView: View {
    enum Style {
        case standard
        case compact

        var titleFont: Font {
            switch self {
            case .standard:
                return AppTypography.sectionTitle
            case .compact:
                return AppTypography.recipeTitle
            }
        }

        var actionFont: Font {
            switch self {
            case .standard:
                return AppTypography.caption
            case .compact:
                return AppTypography.recipeTitle
            }
        }
    }

    let title: String
    let subtitle: String?
    let actionTitle: String?
    let action: (() -> Void)?
    let style: Style

    init(
        _ title: String,
        subtitle: String? = nil,
        actionTitle: String? = nil,
        style: Style = .standard,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
        self.style = style
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(style.titleFont)
                    .foregroundStyle(AppColors.primaryText)

                if let subtitle {
                    Text(subtitle)
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.tertiaryText)
                }
            }

            Spacer(minLength: AppSpacing.md)

            if let actionTitle, let action {
                Button(action: action) {
                    HStack(spacing: AppSpacing.xxs) {
                        Text(actionTitle)
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.semibold))
                    }
                    .font(style.actionFont)
                    .foregroundStyle(AppColors.secondaryText)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    SectionHeaderView("A little inspiration", subtitle: "Small ideas for a beautiful meal.")
        .padding()
        .background(AppColors.appBackground)
}
