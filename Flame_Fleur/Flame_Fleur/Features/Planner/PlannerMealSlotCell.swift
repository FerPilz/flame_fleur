import SwiftUI

struct PlannerMealSlotCell: View {
    let slot: MealSlot
    let meal: PlannedMeal?
    let isSelectedDay: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: AppSpacing.xxs) {
                if let meal {
                    FoodImagePlaceholder(imageName: meal.imageName, style: .thumbnail)
                        .frame(width: 32, height: 22)

                    Text(meal.title)
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.68)
                } else {
                    Image(systemName: "plus")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.olive)
                        .frame(width: 18, height: 18)
                        .background(Circle().fill(AppColors.softOlive))

                    Text("Add Item")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                }
            }
            .padding(.horizontal, AppSpacing.xxs)
            .frame(width: PlannerMealSlotCellMetrics.width, height: PlannerMealSlotCellMetrics.height)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .fill(meal == nil ? AppColors.cardBackground.opacity(0.42) : AppColors.elevatedCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .stroke(isSelectedDay ? AppColors.olive.opacity(0.46) : AppColors.warmBorder.opacity(0.72), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(meal?.title ?? "Add \(slot.title)"))
    }
}

private enum PlannerMealSlotCellMetrics {
    static let width: CGFloat = 66
    static let height: CGFloat = 60
}

#Preview {
    HStack {
        PlannerMealSlotCell(
            slot: .breakfast,
            meal: SampleMealPlan.meals.first,
            isSelectedDay: true,
            onTap: {}
        )

        PlannerMealSlotCell(
            slot: .lunch,
            meal: nil,
            isSelectedDay: false,
            onTap: {}
        )
    }
    .padding()
    .background(AppColors.appBackground)
}
