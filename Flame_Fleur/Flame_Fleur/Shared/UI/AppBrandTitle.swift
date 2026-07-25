import SwiftUI

struct AppBrandTitle: View {
    static let defaultTitle = "ALLSPICED"

    let title: String
    let titleFont: Font

    init(
        title: String = AppBrandTitle.defaultTitle,
        titleFont: Font = AppTypography.allSpicedBrandTitle
    ) {
        self.title = title
        self.titleFont = titleFont
    }

    var body: some View {
        Text(title)
            .font(titleFont)
            .foregroundStyle(AppColors.deepBasil)
            .lineLimit(1)
            .allowsTightening(true)
            .padding(.horizontal, AppTopActionMetrics.centeredTitleInset)
            .frame(maxWidth: .infinity)
            .accessibilityAddTraits(.isHeader)
    }
}
