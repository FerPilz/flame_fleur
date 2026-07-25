import SwiftUI

struct PlannerMealSlotCell: View {
    let slot: MealSlot
    let meal: PlannedMeal?
    let isSelectedDay: Bool
    let width: CGFloat
    let onTap: () -> Void
    let onRemove: (() -> Void)?

    init(
        slot: MealSlot,
        meal: PlannedMeal?,
        isSelectedDay: Bool,
        width: CGFloat,
        onTap: @escaping () -> Void,
        onRemove: (() -> Void)? = nil
    ) {
        self.slot = slot
        self.meal = meal
        self.isSelectedDay = isSelectedDay
        self.width = width
        self.onTap = onTap
        self.onRemove = onRemove
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6.5) {
                slotHeader
                mealImageArea
                mealTitleArea
            }
            .padding(.horizontal, 0)
            .padding(.vertical, AppSpacing.xxs)
            .frame(width: width)
            .frame(minHeight: PlannerMealSlotCellMetrics.height)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(meal?.title ?? "Add recipe to \(slot.title)"))
    }

    private var slotHeader: some View {
        HStack(spacing: 4) {
            Image(systemName: slot.plannerSymbol)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppColors.olive)
                .frame(width: 12, height: 12)

            Text(slot.title)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    private var mealImageArea: some View {
        if let meal {
            ZStack(alignment: .topTrailing) {
                FoodImagePlaceholder(imageName: meal.imageName, style: .circle)
                    .frame(width: PlannerMealSlotCellMetrics.imageSize, height: PlannerMealSlotCellMetrics.imageSize)
                    .overlay(
                        Circle()
                            .strokeBorder(AppColors.basilGreen, lineWidth: PlannerMealSlotCellMetrics.outlineWidth)
                    )

                if let onRemove {
                    Button(action: onRemove) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppColors.burntOrange)
                            .padding(4)
                    }
                    .buttonStyle(.plain)
                    .offset(x: 2, y: -2)
                    .accessibilityLabel(Text("Remove \(slot.title)"))
                }
            }
            .frame(width: PlannerMealSlotCellMetrics.imageSize, height: PlannerMealSlotCellMetrics.imageSize)
        } else {
            ZStack {
                Circle()
                    .strokeBorder(AppColors.basilGreen, lineWidth: PlannerMealSlotCellMetrics.outlineWidth)

                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.darkOlive)
            }
            .frame(width: PlannerMealSlotCellMetrics.imageSize, height: PlannerMealSlotCellMetrics.imageSize)
        }
    }

    @ViewBuilder
    private var mealTitleArea: some View {
        if let meal {
            Text(meal.title)
                .font(AppTypography.metadata)
                .foregroundStyle(isSelectedDay ? AppColors.primaryText : AppColors.secondaryText)
                .lineLimit(1)
                .truncationMode(.tail)
                .multilineTextAlignment(.center)
                .frame(height: PlannerMealSlotCellMetrics.titleHeight)
        } else {
            Color.clear
                .frame(height: PlannerMealSlotCellMetrics.titleHeight)
                .accessibilityHidden(true)
        }
    }
}

private enum PlannerMealSlotCellMetrics {
    static let height: CGFloat = 112
    static let imageSize: CGFloat = 70
    static let titleHeight: CGFloat = 16
    static let outlineWidth: CGFloat = 3.4
}

private extension MealSlot {
    var plannerSymbol: String {
        switch self {
        case .breakfast:
            return "cup.and.saucer.fill"
        case .lunch:
            return "bowl.fill"
        case .snack:
            return "apple.logo"
        case .dinner:
            return "fork.knife"
        }
    }
}

#Preview {
    HStack {
        PlannerMealSlotCell(
            slot: .breakfast,
            meal: SampleMealPlan.meals.first,
            isSelectedDay: true,
            width: 70,
            onTap: {}
        )

        PlannerMealSlotCell(
            slot: .lunch,
            meal: nil,
            isSelectedDay: false,
            width: 70,
            onTap: {}
        )
    }
    .padding()
    .background(AppColors.appBackground)
}
