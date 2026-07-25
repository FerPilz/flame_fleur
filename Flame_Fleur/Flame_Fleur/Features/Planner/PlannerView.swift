import SwiftUI

struct PlannerView: View {
    @EnvironmentObject private var mealPlannerStore: MealPlannerStore
    @EnvironmentObject private var shoppingCartStore: ShoppingCartStore

    let onExit: () -> Void
    let onOpenExploreForRecipeSelection: (PlannerRecipeSelectionContext) -> Void
    @Binding private var pendingSharedMealPlanImport: SharedMealPlanPayload?
    @Binding private var sharedMealPlanImportError: String?

    @State private var navigationPath: [PlannerRoute] = []
    @State private var isCartPresented = false
    @State private var isCalendarPresented = false
    @State private var isPlannerClearDialogPresented = false
    @State private var isShareSheetPresented = false
    @State private var shareSheetItems: [Any] = []
    @State private var toastMessage: String?
    @State private var didTapAddPlanToCart = false
    @State private var rangeStartDate: Date?
    @State private var rangeEndDate: Date?

    private let calendar = Calendar.current
    private let recipeRepository = RecipeRepository.shared

    init(
        onExit: @escaping () -> Void = {},
        onOpenExploreForRecipeSelection: @escaping (PlannerRecipeSelectionContext) -> Void = { _ in },
        pendingSharedMealPlanImport: Binding<SharedMealPlanPayload?> = .constant(nil),
        sharedMealPlanImportError: Binding<String?> = .constant(nil)
    ) {
        self.onExit = onExit
        self.onOpenExploreForRecipeSelection = onOpenExploreForRecipeSelection
        self._pendingSharedMealPlanImport = pendingSharedMealPlanImport
        self._sharedMealPlanImportError = sharedMealPlanImportError
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .bottom) {
                AppColors.appBackground.ignoresSafeArea()

                AppScreen(
                    contentSpacing: 0,
                    headerTopPadding: AppSpacing.xs,
                    contentHorizontalPadding: 10,
                    contentTopPadding: AppSpacing.xs,
                    contentBottomPadding: AppSpacing.bottomTabClearance
                ) {
                    header
                } content: {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        PlannerDaySelector(
                            selectedDate: mealPlannerStore.selectedDate,
                            visibleMonth: mealPlannerStore.visibleMonth,
                            rangeStartDate: rangeStartDate,
                            rangeEndDate: rangeEndDate,
                            mealCountForDate: { date in
                                mealPlannerStore.meals(for: date).count
                            },
                            onOpenCalendar: { isCalendarPresented = true },
                            onSelectDate: { date in
                                selectDateFromCarousel(date)
                            }
                        )

                        PlannerWeeklySummaryCard(summary: mealPlannerStore.weeklySummary)

                        PlannerMealGrid(
                            plannerStore: mealPlannerStore,
                            onDayTap: { date in
                                mealPlannerStore.selectDate(date)
                            },
                            onEmptySlotTap: { date, slot in
                                openRecipePicker(for: date, slot: slot, mode: .add)
                            },
                            onMealTap: { meal in
                                openRecipePicker(for: meal.date, slot: meal.slot, mode: .replace)
                            },
                            onRemoveMeal: { date, slot in
                                mealPlannerStore.removeMeal(on: date, slot: slot)
                            }
                        )

                        WeeklyMacroBalanceCard(balance: mealPlannerStore.selectedDayMacroBalance)

                        PlannerPremiumInsightsCard(onUpgrade: placeholderUpgrade)

                        SmartSuggestionsCarousel(recipes: smartSuggestionRecipes) { recipe in
                            addSmartSuggestion(recipe)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let toastMessage {
                    plannerToast(toastMessage)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .safeAreaInset(edge: .bottom) {
                PlannerBottomActionBar(
                    didAddPlanToCart: didTapAddPlanToCart,
                    onSharePlan: presentSharePlan,
                    onAddPlanToCart: addPlanToCart
                )
            }
            .confirmationDialog("Clear Planner", isPresented: $isPlannerClearDialogPresented, titleVisibility: .visible) {
                Button("Clear selected day", role: .destructive) {
                    mealPlannerStore.clearPlannerDay(mealPlannerStore.selectedDate)
                }

                Button("Clear entire planner", role: .destructive) {
                    mealPlannerStore.clearPlanner()
                }

                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Choose whether to clear only the selected day or all planned meals.")
            }
            .confirmationDialog(
                "Import shared plan?",
                isPresented: Binding(
                    get: { pendingSharedMealPlanImport != nil },
                    set: { if !$0 { pendingSharedMealPlanImport = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Import") {
                    importSharedPlan()
                }

                Button("Cancel", role: .cancel) {
                    pendingSharedMealPlanImport = nil
                }
            } message: {
                Text("This will replace your current planner for this week.")
            }
            .alert(
                "Couldn’t Import Plan",
                isPresented: Binding(
                    get: { sharedMealPlanImportError != nil },
                    set: { if !$0 { sharedMealPlanImportError = nil } }
                )
            ) {
                Button("OK", role: .cancel) {
                    sharedMealPlanImportError = nil
                }
            } message: {
                Text(sharedMealPlanImportError ?? "The selected file could not be imported.")
            }
            .sheet(isPresented: $isShareSheetPresented, onDismiss: cleanupShareSheet) {
                if !shareSheetItems.isEmpty {
                    ActivityView(activityItems: shareSheetItems)
                }
            }
            .navigationDestination(isPresented: $isCartPresented) {
                ShoppingCartView {
                    isCartPresented = false
                }
                    .toolbar(.hidden, for: .tabBar)
            }
            .navigationDestination(for: PlannerRoute.self) { route in
                switch route {
                case .recipePicker(let context):
                    PlannerRecipePickerView(context: context) { recipeID in
                        navigationPath.append(.recipe(recipeID: recipeID, context: context))
                    }
                case .recipe(let recipeID, let context):
                    if recipeRepository.recipe(id: recipeID) != nil {
                        RecipeDetailView(
                            recipeID: recipeID,
                            onBack: {
                                if !navigationPath.isEmpty {
                                    navigationPath.removeLast()
                                }
                            },
                            onViewIngredients: {
                                navigationPath.append(.ingredients(recipeID))
                            },
                            plannerSelectionContext: context,
                            onAddToPlanner: { recipe in
                                let didAdd = mealPlannerStore.addRecipeToPlannerSlot(
                                    recipeID: recipe.id,
                                    date: context.date,
                                    mealType: context.mealType,
                                    slotID: context.slotID,
                                    mode: context.mode
                                )

                                if didAdd {
                                    navigationPath.removeAll()
                                    showToast(context.mode == .add ? "Added to \(context.mealType.title)" : "Replaced in \(context.mealType.title)")
                                } else {
                                    showToast("Recipe is unavailable")
                                }
                            }
                        )
                    } else {
                        EmptyView()
                    }
                case .ingredients(let recipeID):
                    if recipeRepository.recipe(id: recipeID) != nil {
                        RecipeIngredientsView(
                            recipeID: recipeID,
                            onBack: {
                                if !navigationPath.isEmpty {
                                    navigationPath.removeLast()
                                }
                            }
                        )
                    } else {
                        EmptyView()
                    }
                }
            }
            .sheet(isPresented: $isCalendarPresented) {
                PlannerCalendarPickerSheet(
                    selectedDate: Binding(
                        get: { mealPlannerStore.selectedDate },
                        set: { mealPlannerStore.selectDate($0) }
                    )
                )
                .presentationDetents([.height(430)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(AppRadius.hero)
            }
            .tint(AppColors.basilGreen)
            .toolbar(.hidden, for: .navigationBar)
            .toolbar(.hidden, for: .tabBar)
        }
    }

    private var header: some View {
        AppHeader(
            leadingActions: [
                AppHeaderAction(systemName: "chevron.left", accessibilityLabel: "Exit meal planner") {
                    onExit()
                }
            ],
            trailingActions: [
                AppHeaderAction(systemName: "trash", accessibilityLabel: "Clear planner") {
                    isPlannerClearDialogPresented = true
                },
                AppHeaderAction(systemName: "cart", accessibilityLabel: "Open shopping cart", badgeValue: shoppingCartStore.totalItemCount) {
                    isCartPresented = true
                }
            ]
        )
    }

    private func openRecipePicker(for date: Date, slot: MealSlot, mode: PlannerRecipeSelectionContext.Mode) {
        let normalizedDate = calendar.startOfDay(for: date)
        let context = PlannerRecipeSelectionContext(
            date: normalizedDate,
            dayLabel: dayLabel(for: normalizedDate),
            mealType: slot,
            slotID: slot.id,
            mode: mode
        )

        mealPlannerStore.selectDate(normalizedDate)

        if mode == .add {
            onOpenExploreForRecipeSelection(context)
        } else {
            navigationPath.append(
                .recipePicker(context)
            )
        }
    }

    private func selectDateFromCarousel(_ date: Date) {
        let normalizedDate = calendar.startOfDay(for: date)
        updateRangeSelection(with: normalizedDate)
        mealPlannerStore.selectDate(normalizedDate)
    }

    private func updateRangeSelection(with date: Date) {
        let updatedRange = PlannerDateRangeSelection.updatedRange(
            startDate: rangeStartDate,
            endDate: rangeEndDate,
            selecting: date,
            calendar: calendar
        )
        rangeStartDate = updatedRange.startDate
        rangeEndDate = updatedRange.endDate
    }

    private var smartSuggestionRecipes: [Recipe] {
        var seenIDs = Set<String>()
        let recipes = recipeRepository.aiRecommendedRecipes
            + recipeRepository.topPicksRecipes
            + recipeRepository.allRecipes

        return Array(
            recipes.filter { recipe in
                seenIDs.insert(recipe.id).inserted
            }
            .prefix(8)
        )
    }

    private func placeholderUpgrade() {
        showToast("Premium insights coming soon")
    }

    private func addSmartSuggestion(_ recipe: Recipe) {
        let didAdd = mealPlannerStore.addRecipeToFirstAvailableWeekSlot(
            recipe,
            preferredDate: mealPlannerStore.selectedDate
        )

        showToast(didAdd ? "Added to plan" : "No empty slots this week")
    }

    private func addPlanToCart() {
        var addedItemCount = 0

        for meal in mealPlannerStore.mealsInSelectedWeek {
            guard let recipeID = meal.recipeID,
                  let recipe = recipeRepository.recipe(id: recipeID) else {
                continue
            }

            shoppingCartStore.addRecipeIngredients(
                recipe.structuredIngredients,
                from: recipe,
                shouldRecordUsage: false
            )
            addedItemCount += recipe.structuredIngredients.count
        }

        guard addedItemCount > 0 else {
            showToast("No recipe ingredients to add")
            return
        }

        let weeklyRecipes: [Recipe] = mealPlannerStore.mealsInSelectedWeek.compactMap { meal -> Recipe? in
            guard let recipeID = meal.recipeID else {
                return nil
            }

            return recipeRepository.recipe(id: recipeID)
        }
        let weeklyNutrition = NutritionCalculator.summary(from: weeklyRecipes)

        UsageTrackingStore.shared.record(
            type: .planAddedToCart,
            recipeTitle: "Weekly plan",
            ingredientNames: weeklyRecipes.flatMap { recipe in
                RecipeInsightResolver.normalizedIngredientNames(for: recipe)
            },
            calories: weeklyNutrition.calories,
            proteinGrams: weeklyNutrition.proteinGrams,
            carbGrams: weeklyNutrition.carbohydrateGrams,
            fatGrams: weeklyNutrition.fatGrams
        )

        didTapAddPlanToCart = true
        showToast("Plan added to cart (\(addedItemCount) items)")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            didTapAddPlanToCart = false
        }
    }

    private func presentSharePlan() {
        do {
            let payload = mealPlannerStore.sharedMealPlanPayload()
            let shareURL = try MealPlanSharingService.exportFileURL(for: payload)
            let plannedRecipes: [Recipe] = mealPlannerStore.mealsInSelectedWeek.compactMap { meal -> Recipe? in
                guard let recipeID = meal.recipeID else {
                    return nil
                }

                return recipeRepository.recipe(id: recipeID)
            }
            let plannedNutrition = NutritionCalculator.summary(from: plannedRecipes)

            UsageTrackingStore.shared.record(
                type: .planShared,
                recipeTitle: "Weekly plan",
                ingredientNames: plannedRecipes.flatMap { recipe in
                    RecipeInsightResolver.normalizedIngredientNames(for: recipe)
                },
                calories: plannedNutrition.calories,
                proteinGrams: plannedNutrition.proteinGrams,
                carbGrams: plannedNutrition.carbohydrateGrams,
                fatGrams: plannedNutrition.fatGrams
            )
            shareSheetItems = [shareURL]
            isShareSheetPresented = true
        } catch {
            showToast("Couldn’t prepare share file")
        }
    }

    private func importSharedPlan() {
        guard let payload = pendingSharedMealPlanImport else {
            return
        }

        let summary = mealPlannerStore.replacePlanner(with: payload)
        pendingSharedMealPlanImport = nil

        if summary.unresolvedMealCount > 0 {
            showToast("Imported plan with \(summary.unresolvedMealCount) missing recipe(s)")
        } else {
            showToast("Shared plan imported")
        }
    }

    private func cleanupShareSheet() {
        shareSheetItems = []
    }

    private func plannerToast(_ message: String) -> some View {
        Text(message)
            .font(AppTypography.metadata)
            .foregroundStyle(AppColors.elevatedCardBackground)
            .padding(.horizontal, AppSpacing.md)
            .frame(height: 34)
            .background(Capsule(style: .continuous).fill(AppColors.darkOlive))
            .padding(.bottom, AppSpacing.xl)
    }

    private func showToast(_ message: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            toastMessage = message
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            if toastMessage == message {
                withAnimation(.easeInOut(duration: 0.2)) {
                    toastMessage = nil
                }
            }
        }
    }

    private func dayLabel(for date: Date) -> String {
        date.formatted(.dateTime.weekday(.wide))
    }

}

private enum PlannerRoute: Hashable {
    case recipePicker(PlannerRecipeSelectionContext)
    case recipe(recipeID: String, context: PlannerRecipeSelectionContext)
    case ingredients(String)
}

private enum PlannerDateRangeSelection {
    static func updatedRange(
        startDate: Date?,
        endDate: Date?,
        selecting date: Date,
        calendar: Calendar
    ) -> (startDate: Date?, endDate: Date?) {
        let normalizedDate = calendar.startOfDay(for: date)

        guard let startDate else {
            return (normalizedDate, nil)
        }

        let normalizedStartDate = calendar.startOfDay(for: startDate)

        if endDate != nil {
            return (normalizedDate, nil)
        }

        if normalizedDate < normalizedStartDate {
            return (normalizedDate, normalizedStartDate)
        }

        return (normalizedStartDate, normalizedDate)
    }
}

private struct PlannerMenuSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack(alignment: .top, spacing: AppSpacing.sm) {
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text("Planner Menu")
                            .font(AppTypography.heroTitle)
                            .foregroundStyle(AppColors.primaryText)

                        Text("Planner shortcuts are local placeholders in this build.")
                            .font(AppTypography.callout)
                            .foregroundStyle(AppColors.secondaryText)
                    }

                    Spacer()

                    IconCircleButton(
                        systemName: "xmark",
                        accessibilityLabel: "Close planner menu",
                        size: 30,
                        action: { dismiss() }
                    )
                }

                VStack(spacing: AppSpacing.xs) {
                    menuRow(systemImage: "calendar", title: "This Week", detail: "Current planning week")
                    menuRow(systemImage: "tray.full", title: "Saved Plans", detail: "Local plan names")
                    menuRow(systemImage: "slider.horizontal.3", title: "Planner Preferences", detail: "Coming later")
                }

                Spacer(minLength: AppSpacing.md)

                PrimaryButton("Done", style: .olive, height: 44) {
                    dismiss()
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, AppSpacing.md)
            .background(AppColors.appBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func menuRow(systemImage: String, title: String, detail: String) -> some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.sm
        ) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: systemImage)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.olive)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(AppColors.softOlive))

                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(title)
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColors.primaryText)

                    Text(detail)
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
        }
    }
}

#Preview {
    PlannerView()
        .environmentObject(MealPlannerStore.shared)
        .environmentObject(ShoppingCartStore.shared)
}
