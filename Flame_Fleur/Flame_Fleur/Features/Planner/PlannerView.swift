import SwiftUI

struct PlannerView: View {
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    SectionHeaderView(
                        "Planner",
                        subtitle: "A calm weekly cooking plan will live here."
                    )

                    SurfaceCard {
                        Text("Plan dinners, save prep notes, and shape a grocery flow without adding noise to the kitchen.")
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
            .navigationTitle("Planner")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    PlannerView()
}
