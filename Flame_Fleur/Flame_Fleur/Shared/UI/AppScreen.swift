import SwiftUI

struct AppScreen<Header: View, Content: View>: View {
    let contentSpacing: CGFloat
    let headerTopPadding: CGFloat
    let contentBottomPadding: CGFloat
    let header: Header
    let content: Content

    init(
        contentSpacing: CGFloat = AppSpacing.section,
        headerTopPadding: CGFloat = AppSpacing.screenTop,
        contentBottomPadding: CGFloat = AppSpacing.bottomTabClearance,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        self.contentSpacing = contentSpacing
        self.headerTopPadding = headerTopPadding
        self.contentBottomPadding = contentBottomPadding
        self.header = header()
        self.content = content()
    }

    var body: some View {
        ZStack {
            AppColors.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: AppSpacing.xs) {
                    header
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, headerTopPadding)
                .background(AppColors.appBackground)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: contentSpacing) {
                        content
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.sm)
                    .padding(.bottom, contentBottomPadding)
                }
            }
        }
    }
}

#Preview {
    AppScreen {
        AppHeader(
            title: "Flame & Fleur",
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
