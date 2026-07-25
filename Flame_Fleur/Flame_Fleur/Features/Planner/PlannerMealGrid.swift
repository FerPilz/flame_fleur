import SwiftUI

struct PlannerMealGrid: View {
    @ObservedObject var plannerStore: MealPlannerStore

    let onDayTap: (Date) -> Void
    let onEmptySlotTap: (Date, MealSlot) -> Void
    let onMealTap: (PlannedMeal) -> Void
    let onRemoveMeal: (Date, MealSlot) -> Void

    private let calendar = Calendar.current

    var body: some View {
        GeometryReader { geometry in
            let mealCellWidth = PlannerGridMetrics.mealCellWidth(containerWidth: geometry.size.width)

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                ForEach([plannerStore.selectedDate], id: \.self) { date in
                    dayCard(for: date, mealCellWidth: mealCellWidth)
                }
            }
        }
        .frame(height: PlannerGridMetrics.selectedDayCardHeight)
    }

    private func dayCard(for date: Date, mealCellWidth: CGFloat) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: plannerStore.selectedDate)

        return SurfaceCard(
            backgroundColor: isSelected ? AppColors.softOlive.opacity(0.72) : AppColors.elevatedCardBackground,
            borderColor: isSelected ? AppColors.basilGreen.opacity(0.38) : AppColors.warmBorder,
            cornerRadius: AppRadius.large,
            contentPadding: 0
        ) {
            HStack(alignment: .top, spacing: 0) {
                Button {
                    onDayTap(date)
                } label: {
                    Rectangle()
                        .fill(isSelected ? AppColors.basilGreen : AppColors.cardBackground)
                        .frame(width: PlannerGridMetrics.dayIndicatorWidth)
                        .frame(maxHeight: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack(alignment: .firstTextBaseline, spacing: AppSpacing.xs) {
                        Text(date.formatted(.dateTime.weekday(.wide)))
                            .font(AppTypography.cardTitle)
                            .foregroundStyle(AppColors.primaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)

                        Text(date.formatted(.dateTime.month(.abbreviated).day()))
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.secondaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)

                        Spacer(minLength: 0)

                        Text(dayCalorieText(for: date))
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.secondaryText)
                            .padding(.horizontal, AppSpacing.xs)
                            .frame(height: 24)
                            .background(Capsule(style: .continuous).fill(AppColors.cardBackground))
                            .overlay(Capsule(style: .continuous).stroke(AppColors.warmBorder, lineWidth: 1))
                    }

                    HStack(alignment: .top, spacing: PlannerGridMetrics.cellSpacing) {
                        ForEach(MealSlot.allCases, id: \.self) { slot in
                            let meal = plannerStore.meal(for: date, slot: slot)

                            PlannerMealSlotCell(
                                slot: slot,
                                meal: meal,
                                isSelectedDay: isSelected,
                                width: mealCellWidth,
                                onTap: {
                                    if let meal {
                                        onMealTap(meal)
                                    } else {
                                        onEmptySlotTap(date, slot)
                                    }
                                },
                                onRemove: meal == nil ? nil : {
                                    onRemoveMeal(date, slot)
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, PlannerGridMetrics.sidePadding)
                .padding(.vertical, AppSpacing.xs)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
        }
    }

    private func dayCalorieText(for date: Date) -> String {
        let calories = plannerStore.totalCalories(for: date)
        return "\(calories) cal"
    }
}

private enum PlannerGridMetrics {
    static let dayIndicatorWidth: CGFloat = 6
    static let sidePadding: CGFloat = 4
    static let cellSpacing: CGFloat = 2
    static let selectedDayCardHeight: CGFloat = 164

    static func mealCellWidth(containerWidth: CGFloat) -> CGFloat {
        let contentWidth = containerWidth - dayIndicatorWidth - (sidePadding * 2) - (cellSpacing * CGFloat(MealSlot.allCases.count - 1))
        return max(70, floor(contentWidth / CGFloat(MealSlot.allCases.count)))
    }
}

#Preview {
    PlannerMealGrid(
        plannerStore: MealPlannerStore.shared,
        onDayTap: { _ in },
        onEmptySlotTap: { _, _ in },
        onMealTap: { _ in },
        onRemoveMeal: { _, _ in }
    )
    .padding()
    .background(AppColors.appBackground)
}
