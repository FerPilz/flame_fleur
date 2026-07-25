import SwiftUI

struct AppScreen<Header: View, Content: View>: View {
    let contentSpacing: CGFloat
    let headerTopPadding: CGFloat
    let contentHorizontalPadding: CGFloat
    let contentTopPadding: CGFloat
    let contentBottomPadding: CGFloat
    let backgroundColor: Color
    let header: Header
    let content: Content

    init(
        contentSpacing: CGFloat = AppSpacing.section,
        headerTopPadding: CGFloat = AppSpacing.screenTop,
        contentHorizontalPadding: CGFloat = AppSpacing.screenHorizontal,
        contentTopPadding: CGFloat = AppSpacing.sm,
        contentBottomPadding: CGFloat = AppSpacing.bottomTabClearance,
        backgroundColor: Color = AppColors.appBackground,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        self.contentSpacing = contentSpacing
        self.headerTopPadding = headerTopPadding
        self.contentHorizontalPadding = contentHorizontalPadding
        self.contentTopPadding = contentTopPadding
        self.contentBottomPadding = contentBottomPadding
        self.backgroundColor = backgroundColor
        self.header = header()
        self.content = content()
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: AppSpacing.xs) {
                    header
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, headerTopPadding)
                .background(backgroundColor)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: contentSpacing) {
                        content
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, contentHorizontalPadding)
                    .padding(.top, contentTopPadding)
                    .padding(.bottom, contentBottomPadding)
                }
            }
        }
    }
}

#Preview {
    AppScreen {
        AppHeader(
            leadingActions: [AppHeaderAction(systemName: "line.3.horizontal", accessibilityLabel: "Menu")],
            trailingActions: [AppHeaderAction(systemName: "cart", accessibilityLabel: "Cart")]
        )
    } content: {
        SurfaceCard {
            Text("Screen content stays inside shared margins.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)
        }
    }
}
