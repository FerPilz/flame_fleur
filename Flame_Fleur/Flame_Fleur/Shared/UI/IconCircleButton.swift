import SwiftUI

enum AppTopActionMetrics {
    static let buttonSize: CGFloat = 34
    static let compactButtonSize: CGFloat = 32
    static let actionGroupWidth: CGFloat = 96
    static let centeredTitleInset: CGFloat = 104
    static let minimumTopOffset: CGFloat = 44
}

struct IconCircleButton: View {
    let systemName: String
    let accessibilityLabel: String
    let badgeValue: Int?
    let size: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    let action: () -> Void

    init(
        systemName: String,
        accessibilityLabel: String,
        badgeValue: Int? = nil,
        size: CGFloat = 34,
        backgroundColor: Color = AppColors.elevatedCardBackground,
        foregroundColor: Color = AppColors.darkOlive,
        action: @escaping () -> Void
    ) {
        self.systemName = systemName
        self.accessibilityLabel = accessibilityLabel
        self.badgeValue = badgeValue
        self.size = size
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(backgroundColor)
                    .overlay(
                        Circle()
                            .stroke(AppColors.warmBorder.opacity(0.78), lineWidth: 1)
                    )
                    .frame(width: size, height: size)

                icon
                    .frame(width: size, height: size)

                if let badgeValue, badgeValue > 0 {
                    Text("\(badgeValue)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(AppColors.elevatedCardBackground)
                        .frame(width: 15, height: 15)
                        .background(Circle().fill(AppColors.burntOrange))
                        .offset(x: 3, y: -3)
                    }
            }
        }
        .buttonStyle(.plain)
        .frame(width: max(size, 44), height: max(size, 44), alignment: .center)
        .contentShape(Circle())
        .accessibilityLabel(Text(accessibilityLabel))
    }

    @ViewBuilder
    private var icon: some View {
        if systemName == "line.3.horizontal" {
            VStack(spacing: size * 0.08) {
                ForEach(0..<3, id: \.self) { _ in
                    Capsule(style: .continuous)
                        .fill(foregroundColor)
                        .frame(width: size * 0.38, height: max(1.3, size * 0.045))
                }
            }
        } else {
            Image(systemName: systemName)
                .font(.system(size: size * 0.42, weight: .medium))
                .foregroundStyle(foregroundColor)
        }
    }
}

#Preview {
    HStack {
        IconCircleButton(systemName: "line.3.horizontal", accessibilityLabel: "Menu") {}
        IconCircleButton(systemName: "basket", accessibilityLabel: "Shopping basket", badgeValue: 4) {}
    }
    .padding()
    .background(AppColors.appBackground)
}
