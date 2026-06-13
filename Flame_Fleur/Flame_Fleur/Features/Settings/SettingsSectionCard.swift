import SwiftUI

struct SettingsSectionCard<Content: View>: View {
    let title: String
    let content: Content

    init(
        title: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.primaryText)
                .padding(.leading, AppSpacing.xxs)

            SurfaceCard(
                backgroundColor: AppColors.elevatedCardBackground,
                borderColor: AppColors.warmBorder,
                cornerRadius: AppRadius.large,
                contentPadding: 0
            ) {
                VStack(spacing: 0) {
                    content
                }
            }
        }
    }
}

#Preview {
    SettingsSectionCard(title: "Preferences") {
        Text("Grouped settings content")
            .font(AppTypography.body)
            .padding(AppSpacing.md)
    }
    .padding()
    .background(AppColors.appBackground)
}
