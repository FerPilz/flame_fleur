import SwiftUI

struct PrimaryButton: View {
    enum Style {
        case recipe
        case olive

        var backgroundColor: Color {
            switch self {
            case .recipe:
                return AppColors.burntOrange
            case .olive:
                return AppColors.darkOlive
            }
        }
    }

    let title: String
    let systemImage: String?
    let backgroundColor: Color
    let foregroundColor: Color
    let isFullWidth: Bool
    let height: CGFloat?
    let font: Font
    let horizontalPadding: CGFloat
    let action: () -> Void

    init(
        _ title: String,
        systemImage: String? = nil,
        style: Style = .olive,
        backgroundColor: Color? = nil,
        foregroundColor: Color = AppColors.elevatedCardBackground,
        isFullWidth: Bool = true,
        height: CGFloat? = 48,
        font: Font = AppTypography.button,
        horizontalPadding: CGFloat = AppSpacing.lg,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.backgroundColor = backgroundColor ?? style.backgroundColor
        self.foregroundColor = foregroundColor
        self.isFullWidth = isFullWidth
        self.height = height
        self.font = font
        self.horizontalPadding = horizontalPadding
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.headline)
                }

                Text(title)
                    .font(font)
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: isFullWidth ? .infinity : nil, minHeight: height)
            .padding(.horizontal, horizontalPadding)
            .background(
                Capsule(style: .continuous)
                    .fill(backgroundColor)
            )
            .shadow(color: AppShadow.buttonColor, radius: AppShadow.buttonRadius, x: 0, y: AppShadow.buttonYOffset)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
    }
}

#Preview {
    PrimaryButton("View Recipe", systemImage: "flame.fill", style: .recipe) {}
        .padding()
        .background(AppColors.appBackground)
}
