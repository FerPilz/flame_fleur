import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum FoodImageKind: String {
    case salmon
    case pasta
    case bowl
    case dessert
    case salad
    case citrus

    init(imageName: String?) {
        guard let imageName, let kind = FoodImageKind(rawValue: imageName) else {
            self = .bowl
            return
        }

        self = kind
    }
}

enum FoodImagePlaceholderStyle {
    case hero
    case card
    case thumbnail
    case circle

    var aspectRatio: CGFloat {
        switch self {
        case .hero:
            return 1.22
        case .card:
            return 1.04
        case .thumbnail:
            return 1
        case .circle:
            return 1
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .hero:
            return AppRadius.extraLarge
        case .card:
            return AppRadius.medium
        case .thumbnail:
            return AppRadius.small
        case .circle:
            return AppRadius.pill
        }
    }
}

struct FoodImagePlaceholder: View {
    let imageName: String?
    let kind: FoodImageKind
    let style: FoodImagePlaceholderStyle

    init(
        kind: FoodImageKind = .salmon,
        style: FoodImagePlaceholderStyle = .card
    ) {
        self.imageName = nil
        self.kind = kind
        self.style = style
    }

    init(
        imageName: String?,
        style: FoodImagePlaceholderStyle = .card
    ) {
        self.imageName = imageName
        self.kind = FoodImageKind(imageName: imageName)
        self.style = style
    }

    var body: some View {
        shapedContent
            .aspectRatio(style.aspectRatio, contentMode: .fill)
            .clipped()
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var shapedContent: some View {
        if case .circle = style {
            content
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(AppColors.warmBorder.opacity(0.70), lineWidth: 1)
                )
        } else {
            content
                .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
                        .stroke(AppColors.warmBorder.opacity(0.70), lineWidth: 1)
                )
        }
    }

    @ViewBuilder
    private var content: some View {
        if let imageName = availableImageName {
            GeometryReader { proxy in
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
            }
        } else {
            placeholderContent
        }
    }

    private var availableImageName: String? {
        guard let imageName = imageName?.trimmingCharacters(in: .whitespacesAndNewlines),
              !imageName.isEmpty,
              AssetImageAvailability.exists(named: imageName) else {
            return nil
        }

        return imageName
    }

    private var placeholderContent: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)

            ZStack {
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(primaryColor.opacity(0.36))
                    .frame(width: size * 1.05, height: size * 1.05)
                    .blur(radius: size * 0.10)
                    .offset(x: size * 0.25, y: size * 0.05)

                Circle()
                    .fill(AppColors.elevatedCardBackground.opacity(0.68))
                    .frame(width: size * 0.88, height: size * 0.88)
                    .blur(radius: size * 0.13)
                    .offset(x: -size * 0.25, y: -size * 0.22)

                garnish(size: size)
                    .frame(width: proxy.size.width, height: proxy.size.height)

                LinearGradient(
                    colors: [
                        AppColors.elevatedCardBackground.opacity(0.16),
                        .clear,
                        AppColors.shadow.opacity(0.13)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .blendMode(.multiply)
            }
        }
    }

    @ViewBuilder
    private func garnish(size: CGFloat) -> some View {
        switch kind {
        case .salmon:
            RoundedRectangle(cornerRadius: size * 0.12, style: .continuous)
                .fill(AppColors.salmon)
                .frame(width: size * 0.66, height: size * 0.30)
                .rotationEffect(.degrees(-12))
                .offset(x: size * 0.18, y: size * 0.04)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.12, style: .continuous)
                        .stroke(AppColors.elevatedCardBackground.opacity(0.34), lineWidth: max(size * 0.035, 2))
                        .rotationEffect(.degrees(-12))
                        .offset(x: size * 0.18, y: size * 0.04)
                )
            herbSprigs(size: size)
                .offset(x: -size * 0.22, y: size * 0.18)
            citrusSlices(size: size)
                .offset(x: -size * 0.18, y: -size * 0.18)

        case .pasta:
            ForEach(0..<7) { index in
                Capsule(style: .continuous)
                    .stroke(AppColors.pasta.opacity(0.94), lineWidth: max(size * 0.045, 3))
                    .frame(width: size * 0.62, height: size * 0.15)
                    .rotationEffect(.degrees(Double(index) * 19 - 42))
                    .offset(x: CGFloat(index - 3) * size * 0.035, y: CGFloat(index % 3) * size * 0.055)
            }
            herbSprigs(size: size)
                .offset(x: size * 0.16, y: size * 0.17)

        case .bowl:
            Circle()
                .fill(AppColors.tomato)
                .frame(width: size * 0.62, height: size * 0.62)
                .offset(x: size * 0.12, y: size * 0.10)
            ForEach(0..<9) { index in
                Circle()
                    .fill(index.isMultiple(of: 2) ? AppColors.lemon : AppColors.basil)
                    .frame(width: size * 0.11, height: size * 0.11)
                    .offset(x: CGFloat(index - 4) * size * 0.088, y: CGFloat((index % 4) - 1) * size * 0.105)
            }

        case .dessert:
            RoundedRectangle(cornerRadius: size * 0.07, style: .continuous)
                .fill(AppColors.cocoa)
                .frame(width: size * 0.54, height: size * 0.40)
                .rotationEffect(.degrees(-4))
                .offset(x: size * 0.12, y: size * 0.11)
            RoundedRectangle(cornerRadius: size * 0.07, style: .continuous)
                .fill(AppColors.cocoa.opacity(0.88))
                .frame(width: size * 0.43, height: size * 0.31)
                .rotationEffect(.degrees(8))
                .offset(x: -size * 0.24, y: -size * 0.11)
            RoundedRectangle(cornerRadius: size * 0.06, style: .continuous)
                .fill(AppColors.berry.opacity(0.52))
                .frame(width: size * 0.33, height: size * 0.24)
                .rotationEffect(.degrees(-10))
                .offset(x: size * 0.34, y: -size * 0.24)

        case .salad:
            ForEach(0..<7) { index in
                Capsule(style: .continuous)
                    .fill(index.isMultiple(of: 2) ? AppColors.basil : AppColors.softOlive)
                    .frame(width: size * 0.44, height: size * 0.17)
                    .rotationEffect(.degrees(Double(index) * 22))
                    .offset(x: CGFloat(index - 3) * size * 0.055, y: CGFloat(index % 3) * size * 0.08)
            }
            citrusSlices(size: size)
                .offset(x: size * 0.20, y: -size * 0.10)

        case .citrus:
            citrusSlices(size: size)
                .offset(x: size * 0.10, y: size * 0.06)
            herbSprigs(size: size)
                .offset(x: -size * 0.22, y: size * 0.16)
        }
    }

    private func herbSprigs(size: CGFloat) -> some View {
        ForEach(0..<5) { index in
            Capsule(style: .continuous)
                .fill(AppColors.basil)
                .frame(width: size * 0.24, height: size * 0.055)
                .rotationEffect(.degrees(Double(index) * 28 - 42))
                .offset(x: CGFloat(index - 2) * size * 0.09, y: CGFloat(index % 2) * size * 0.13 - size * 0.06)
        }
    }

    private func citrusSlices(size: CGFloat) -> some View {
        ForEach(0..<3) { index in
            Circle()
                .fill(AppColors.lemon)
                .frame(width: size * 0.18, height: size * 0.18)
                .overlay(Circle().stroke(AppColors.elevatedCardBackground.opacity(0.56), lineWidth: max(size * 0.02, 2)))
                .offset(x: CGFloat(index - 1) * size * 0.20 - size * 0.05, y: CGFloat(index - 1) * size * 0.075 + size * 0.14)
        }
    }

    private var gradientColors: [Color] {
        switch kind {
        case .salmon:
            return [AppColors.cardBackground, AppColors.lemon.opacity(0.54), AppColors.salmon.opacity(0.42)]
        case .pasta:
            return [AppColors.elevatedCardBackground, AppColors.pasta.opacity(0.72), AppColors.basil.opacity(0.26)]
        case .bowl:
            return [AppColors.warmCream, AppColors.tomato.opacity(0.54), AppColors.basil.opacity(0.34)]
        case .dessert:
            return [AppColors.elevatedCardBackground, AppColors.cocoa.opacity(0.72), AppColors.berry.opacity(0.36)]
        case .salad:
            return [AppColors.elevatedCardBackground, AppColors.basil.opacity(0.58), AppColors.lemon.opacity(0.32)]
        case .citrus:
            return [AppColors.elevatedCardBackground, AppColors.lemon.opacity(0.70), AppColors.softOrange.opacity(0.65)]
        }
    }

    private var primaryColor: Color {
        switch kind {
        case .salmon:
            return AppColors.salmon
        case .pasta, .citrus:
            return AppColors.pasta
        case .bowl:
            return AppColors.tomato
        case .dessert:
            return AppColors.cocoa
        case .salad:
            return AppColors.basil
        }
    }
}

private enum AssetImageAvailability {
    static func exists(named imageName: String) -> Bool {
        #if canImport(UIKit)
        return UIImage(named: imageName) != nil
        #elseif canImport(AppKit)
        return NSImage(named: NSImage.Name(imageName)) != nil
        #else
        return false
        #endif
    }
}

#Preview {
    HStack {
        FoodImagePlaceholder(kind: .salmon, style: .hero)
            .frame(width: 164)
        FoodImagePlaceholder(kind: .pasta, style: .card)
            .frame(width: 104)
        FoodImagePlaceholder(kind: .salad, style: .circle)
            .frame(width: 72)
    }
    .padding()
    .background(AppColors.appBackground)
}
