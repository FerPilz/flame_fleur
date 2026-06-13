import SwiftUI

struct PlannerMealGrid: View {
    @ObservedObject var plannerStore: MealPlannerStore

    let onDayTap: (Date) -> Void
    let onEmptySlotTap: (Date, MealSlot) -> Void
    let onMealTap: (PlannedMeal) -> Void

    private let calendar = Calendar.current

    var body: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.xxs
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            headerRow

                            ForEach(plannerStore.weekDates, id: \.self) { date in
                                dayRow(for: date)
                                    .id(date)

                                if date != plannerStore.weekDates.last {
                                    Rectangle()
                                        .fill(AppColors.warmBorder.opacity(0.62))
                                        .frame(height: 1)
                                        .padding(.leading, PlannerGridMetrics.dayRailWidth + AppSpacing.xs)
                                }
                            }
                        }
                    }
                    .scrollClipDisabled()
                    .onChange(of: plannerStore.selectedDate) { _, selectedDate in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            proxy.scrollTo(selectedDate, anchor: .center)
                        }
                    }
                }
            }
        }
    }

    private var headerRow: some View {
        HStack(spacing: AppSpacing.xs) {
            Color.clear
                .frame(width: PlannerGridMetrics.dayRailWidth, alignment: .leading)

            ForEach(MealSlot.allCases) { slot in
                VStack(spacing: 1) {
                    Image(systemName: slot.systemImage)
                        .font(AppTypography.metadata)
                    Text(slot.shortTitle)
                        .font(AppTypography.metadata)
                        .lineLimit(1)
                }
                .foregroundStyle(AppColors.secondaryText)
                .frame(width: PlannerGridMetrics.cellWidth)
            }
        }
        .padding(.bottom, AppSpacing.xxs)
    }

    private func dayRow(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: plannerStore.selectedDate)

        return HStack(alignment: .center, spacing: AppSpacing.xs) {
            dayRail(for: date, isSelected: isSelected)

            ForEach(MealSlot.allCases) { slot in
                let meal = plannerStore.meal(for: date, slot: slot)

                PlannerMealSlotCell(
                    slot: slot,
                    meal: meal,
                    isSelectedDay: isSelected,
                    onTap: {
                        if let meal {
                            onMealTap(meal)
                        } else {
                            onEmptySlotTap(date, slot)
                        }
                    }
                )
            }
        }
        .padding(.vertical, AppSpacing.xxs)
    }

    private func dayRail(for date: Date, isSelected: Bool) -> some View {
        Button {
            onDayTap(date)
        } label: {
            VStack(spacing: 1) {
                Text(date.formatted(.dateTime.weekday(.short)))
                    .font(AppTypography.metadata)
                    .foregroundStyle(isSelected ? AppColors.elevatedCardBackground : AppColors.secondaryText)

                Text("\(calendar.component(.day, from: date))")
                    .font(AppTypography.caption)
                    .foregroundStyle(isSelected ? AppColors.elevatedCardBackground : AppColors.primaryText)

                Text(dayCalorieText(for: date))
                    .font(AppTypography.metadata)
                    .foregroundStyle(isSelected ? AppColors.elevatedCardBackground.opacity(0.86) : AppColors.olive)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }
            .frame(width: PlannerGridMetrics.dayRailWidth, height: PlannerGridMetrics.cellHeight)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .fill(isSelected ? AppColors.olive : AppColors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .stroke(isSelected ? AppColors.olive : AppColors.warmBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func dayCalorieText(for date: Date) -> String {
        let calories = plannerStore.totalCalories(for: date)

        guard calories >= 1_000 else {
            return "\(calories) kcal"
        }

        return String(format: "%.1fk", Double(calories) / 1_000)
    }
}

private enum PlannerGridMetrics {
    static let dayRailWidth: CGFloat = 46
    static let cellWidth: CGFloat = 66
    static let cellHeight: CGFloat = 60
}

#Preview {
    PlannerMealGrid(
        plannerStore: MealPlannerStore.shared,
        onDayTap: { _ in },
        onEmptySlotTap: { _, _ in },
        onMealTap: { _ in }
    )
    .padding()
    .background(AppColors.appBackground)
}
