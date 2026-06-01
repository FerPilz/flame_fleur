import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    SectionHeaderView(
                        "Profile",
                        subtitle: "Personal tastes, preferences, and kitchen rituals will live here."
                    )

                    SurfaceCard {
                        Text("A future home for dietary preferences, saved notes, favorite cuisines, and the details that make recommendations feel personal.")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textSecondary)
                            .lineSpacing(3)
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.xl)
                .padding(.bottom, AppSpacing.xxxl)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ProfileView()
}
