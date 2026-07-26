import SwiftUI

struct ExpandableRecipeStepRow: View {
    let stepNumber: Int
    let title: String
    let detail: String
    let durationText: String
    let isExpanded: Bool
    let showsTopConnector: Bool
    let showsBottomConnector: Bool
    let onTap: () -> Void

    init(
        stepNumber: Int,
        title: String,
        detail: String,
        durationText: String,
        isExpanded: Bool,
        showsTopConnector: Bool = false,
        showsBottomConnector: Bool = false,
        onTap: @escaping () -> Void
    ) {
        self.stepNumber = stepNumber
        self.title = title
        self.detail = detail
        self.durationText = durationText
        self.isExpanded = isExpanded
        self.showsTopConnector = showsTopConnector
        self.showsBottomConnector = showsBottomConnector
        self.onTap = onTap
    }

    var body: some View {
        HStack(alignment: isExpanded ? .top : .center, spacing: AppSpacing.sm) {
            stepIndicator
            stepCard
        }
    }

    private var stepIndicator: some View {
        GeometryReader { proxy in
            ZStack(alignment: isExpanded ? .top : .center) {
                connector(height: proxy.size.height)

                Text("\(stepNumber)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isExpanded ? AppColors.elevatedCardBackground : .black)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(isExpanded ? AppColors.basil : Color(red: 184 / 255, green: 168 / 255, blue: 154 / 255).opacity(0.30))
                    )
            }
        }
        .frame(width: 36)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var stepCard: some View {
        Button(action: onTap) {
            if isExpanded {
                expandedCard
            } else {
                collapsedCard
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var collapsedCard: some View {
        let bubbleShape = RecipeStepBubbleShape(tailCenterY: 28)

        return HStack(spacing: AppSpacing.sm) {
            Text(title)
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer(minLength: AppSpacing.sm)

            Image(systemName: "chevron.down")
                .font(.system(size: 15, weight: .semibold,))
                .foregroundStyle(AppColors.basil)
                .foregroundStyle(AppColors.secondaryText)
                .padding(.trailing, 15)
        }
        .padding(.leading, 25)
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(bubbleShape.fill(Color(red: 184 / 255, green: 168 / 255, blue: 154 / 255).opacity(0.20)))
        .overlay(bubbleShape.stroke(.clear, lineWidth: 0))
        .contentShape(bubbleShape)
    }

    private var expandedCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: AppSpacing.sm) {
                Text(title)
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(2)

                Spacer(minLength: AppSpacing.xs)

                Label(durationText, systemImage: "timer")
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.basil)
                    .lineLimit(2)
                    .padding(.horizontal, AppSpacing.xs)
                    .frame(height: 24)
                    .background(Capsule(style: .continuous).fill(AppColors.softOlive))
            }

            Text(detail)
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
                .transition(.opacity.combined(with: .move(edge: .top)))

            HStack {
                Image(systemName: "waveform")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppColors.olive.opacity(0.72))
                    .accessibilityHidden(true)

                Spacer()

                Text("Play step")
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.olive)
                    .padding(.horizontal, AppSpacing.sm)
                    .frame(height: 28)
                    .background(Capsule(style: .continuous).fill(AppColors.softOlive))
            }
        }
        .padding(.top, AppSpacing.sm)
        .padding(.bottom, AppSpacing.sm)
        .padding(.leading, AppSpacing.lg)
        .padding(.trailing, AppSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RecipeStepBubbleShape().fill(AppColors.elevatedCardBackground))
        .overlay(RecipeStepBubbleShape().stroke(AppColors.basil, lineWidth: 2))
        .contentShape(RecipeStepBubbleShape())
    }

    private func connector(height: CGFloat) -> some View {
        Path { path in
            let centerX: CGFloat = 18
            let circleCenterY = isExpanded ? 18 : height / 2

            if showsTopConnector {
                path.move(to: CGPoint(x: centerX, y: -AppSpacing.xs))
                path.addLine(to: CGPoint(x: centerX, y: circleCenterY))
            }

            if showsBottomConnector {
                path.move(to: CGPoint(x: centerX, y: circleCenterY))
                path.addLine(to: CGPoint(x: centerX, y: height + AppSpacing.xs))
            }
        }
        .stroke(
            AppColors.olive.opacity(0.24),
            style: StrokeStyle(lineWidth: 1, dash: [2, 3])
        )
    }
}

private struct RecipeStepBubbleShape: Shape {
    private let tailWidth: CGFloat = 8
    private let tailHeight: CGFloat = 12
    private let cornerRadius: CGFloat = AppRadius.large
    private let tailCenterY: CGFloat?

    init(tailCenterY: CGFloat? = nil) {
        self.tailCenterY = tailCenterY
    }

    func path(in rect: CGRect) -> Path {
        let preferredTailCenterY = tailCenterY ?? 26
        let tailCenterY = min(
            max(preferredTailCenterY, cornerRadius + tailHeight / 2),
            rect.height - cornerRadius - tailHeight / 2
        )
        let bodyMinX = rect.minX + tailWidth
        let radius = min(cornerRadius, rect.height / 2, (rect.width - tailWidth) / 2)
        var path = Path()

        path.move(to: CGPoint(x: bodyMinX + radius, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + radius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - radius, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: bodyMinX + radius, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: bodyMinX, y: rect.maxY - radius),
            control: CGPoint(x: bodyMinX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: bodyMinX, y: tailCenterY + tailHeight / 2))
        path.addLine(to: CGPoint(x: rect.minX, y: tailCenterY))
        path.addLine(to: CGPoint(x: bodyMinX, y: tailCenterY - tailHeight / 2))
        path.addLine(to: CGPoint(x: bodyMinX, y: rect.minY + radius))
        path.addQuadCurve(
            to: CGPoint(x: bodyMinX + radius, y: rect.minY),
            control: CGPoint(x: bodyMinX, y: rect.minY)
        )
        path.closeSubpath()

        return path
    }
}

#Preview {
    ExpandableRecipeStepRow(
        stepNumber: 2,
        title: "Cook Tomatoes",
        detail: "Add the cherry tomatoes to the pan and cook until they begin to burst.",
        durationText: "8 min",
        isExpanded: true,
        showsTopConnector: true,
        showsBottomConnector: true,
        onTap: {}
    )
    .padding()
    .background(AppColors.appBackground)
}
