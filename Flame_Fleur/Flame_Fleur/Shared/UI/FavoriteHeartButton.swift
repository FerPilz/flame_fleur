import SwiftUI

struct FavoriteHeartButton: View {
    let isFavorite: Bool
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    .frame(width: FavoriteHeartButtonMetrics.circleSize, height: FavoriteHeartButtonMetrics.circleSize)

                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: FavoriteHeartButtonMetrics.iconSize, weight: .light))
                    .symbolRenderingMode(.monochrome)
                    .foregroundStyle(Color.white.opacity(isFavorite ? 0.65 : 0.5))
            }
            .frame(width: FavoriteHeartButtonMetrics.circleSize, height: FavoriteHeartButtonMetrics.circleSize)
            .frame(
                width: FavoriteHeartButtonMetrics.hitTargetSize,
                height: FavoriteHeartButtonMetrics.hitTargetSize,
                alignment: .topTrailing
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(Color.clear)
        .frame(width: FavoriteHeartButtonMetrics.hitTargetSize, height: FavoriteHeartButtonMetrics.hitTargetSize)
        .contentShape(Rectangle())
        .accessibilityLabel(Text(accessibilityLabel))
    }
}

private enum FavoriteHeartButtonMetrics {
    static let iconSize: CGFloat = 17
    static let circleSize: CGFloat = 27
    static let hitTargetSize: CGFloat = 44
}

#Preview {
    HStack(spacing: AppSpacing.md) {
        FavoriteHeartButton(isFavorite: false, accessibilityLabel: "Save recipe") {}
        FavoriteHeartButton(isFavorite: true, accessibilityLabel: "Unsave recipe") {}
    }
    .padding()
    .background(AppColors.olive)
}
