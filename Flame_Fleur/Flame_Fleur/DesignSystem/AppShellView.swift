import SwiftUI

struct AppShellView: View {
    @State private var selectedTab: AppTab = .home
    @State private var previousTab: AppTab = .home
    @State private var lastNonPlannerTab: AppTab = .home
    @State private var pendingExploreLaunchContext: ExploreLaunchContext?
    @State private var plannerRecipeSelectionContext: PlannerRecipeSelectionContext?
    @State private var pendingSharedMealPlanImport: SharedMealPlanPayload?
    @State private var sharedMealPlanImportError: String?
    @State private var pendingSharedCartImport: SharedCartPayload?
    @State private var isSharedCartImportPresented = false
    @State private var sharedCartImportError: String?
    @StateObject private var shoppingCartStore = ShoppingCartStore.shared
    @StateObject private var mealPlannerStore = MealPlannerStore.shared
    @StateObject private var userRecipeStore = UserRecipeStore.shared
    @StateObject private var userProfileStore = UserProfileStore.shared
    @StateObject private var appSettingsStore = AppSettingsStore.shared
    @StateObject private var favoritesStore = FavoritesStore.shared
    @StateObject private var usageTrackingStore = UsageTrackingStore.shared
    @StateObject private var onboardingStore = OnboardingPreferencesStore.shared

    var body: some View {
        Group {
            if onboardingStore.hasCompletedOnboarding {
                TabView(selection: $selectedTab) {
                    HomeView(openExplore: openExplore)
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(AppTab.home)

                    ExploreView(
                        launchContext: $pendingExploreLaunchContext,
                        plannerSelectionContext: $plannerRecipeSelectionContext,
                        onPlannerRecipeSelectionCancelled: {
                            plannerRecipeSelectionContext = nil
                            selectedTab = .planner
                        },
                        onPlannerRecipeSelectionCompleted: {
                            plannerRecipeSelectionContext = nil
                            selectedTab = .planner
                        }
                    )
                        .tabItem {
                            Label("Explore", systemImage: "magnifyingglass")
                        }
                        .tag(AppTab.explore)

                    PlannerView(
                        onExit: {
                            selectedTab = lastNonPlannerTab
                        },
                        onOpenExploreForRecipeSelection: { context in
                            pendingExploreLaunchContext = nil
                            plannerRecipeSelectionContext = context
                            selectedTab = .explore
                        },
                        pendingSharedMealPlanImport: $pendingSharedMealPlanImport,
                        sharedMealPlanImportError: $sharedMealPlanImportError
                    )
                        .toolbar(.hidden, for: .tabBar)
                        .tabItem {
                            Label("Planner", systemImage: "calendar")
                        }
                        .tag(AppTab.planner)

                    AnalyticsView {
                        goBackFromMainTab(.analytics)
                    }
                        .tabItem {
                            Label("Analytics", systemImage: "chart.pie.fill")
                        }
                        .tag(AppTab.analytics)

                    ProfileView {
                        goBackFromMainTab(.profile)
                    }
                        .tabItem {
                            Label("Profile", systemImage: "person.crop.circle")
                        }
                        .tag(AppTab.profile)
                }
                .tint(AppColors.olive)
                .toolbarBackground(AppColors.surface, for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
                .sheet(isPresented: $isSharedCartImportPresented, onDismiss: {
                    pendingSharedCartImport = nil
                }) {
                    ShoppingCartView(
                        onClose: {
                            isSharedCartImportPresented = false
                        },
                        pendingSharedCartImport: $pendingSharedCartImport,
                        sharedCartImportError: $sharedCartImportError
                    )
                    .environmentObject(shoppingCartStore)
                    .environmentObject(appSettingsStore)
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(AppRadius.hero)
                }
                .alert(
                    "Couldn’t Import Cart",
                    isPresented: Binding(
                        get: { sharedCartImportError != nil },
                        set: { if !$0 { sharedCartImportError = nil } }
                    )
                ) {
                    Button("OK", role: .cancel) {
                        sharedCartImportError = nil
                    }
                } message: {
                    Text(sharedCartImportError ?? "The selected file could not be imported.")
                }
                .onChange(of: selectedTab) { oldTab, newTab in
                    if newTab != .planner {
                        previousTab = oldTab == .planner ? lastNonPlannerTab : oldTab
                        lastNonPlannerTab = newTab
                    }

                    if newTab != .explore {
                        plannerRecipeSelectionContext = nil
                    }
                }
            } else {
                OnboardingView(
                    initialCuisines: onboardingStore.preferences.selectedCuisines,
                    initialGoals: onboardingStore.preferences.selectedGoals,
                    onUpdateCuisines: onboardingStore.setSelectedCuisines(_:),
                    onUpdateGoals: onboardingStore.setSelectedGoals(_:),
                    onComplete: completeOnboarding,
                    onSkip: skipOnboarding
                )
            }
        }
        .environmentObject(shoppingCartStore)
        .environmentObject(mealPlannerStore)
        .environmentObject(userRecipeStore)
        .environmentObject(userProfileStore)
        .environmentObject(appSettingsStore)
        .environmentObject(favoritesStore)
        .environmentObject(usageTrackingStore)
        .environmentObject(onboardingStore)
        .onOpenURL { url in
            handleIncomingSharedImport(url: url)
        }
    }

    private func openExplore(_ context: ExploreLaunchContext) {
        pendingExploreLaunchContext = context
        selectedTab = .explore
    }

    private func goBackFromMainTab(_ tab: AppTab) {
        selectedTab = (previousTab == tab || previousTab == .planner) ? .home : previousTab
    }

    private func completeOnboarding(
        destination: OnboardingCompletionDestination,
        cuisines: [String],
        goals: [String]
    ) {
        applyOnboardingSelections(cuisines: cuisines, goals: goals)
        selectedTab = destination == .planner ? .planner : .home
        onboardingStore.completeOnboarding()
    }

    private func skipOnboarding(cuisines: [String], goals: [String]) {
        applyOnboardingSelections(cuisines: cuisines, goals: goals)
        selectedTab = .home
        onboardingStore.skipOnboarding()
    }

    private func applyOnboardingSelections(cuisines: [String], goals: [String]) {
        onboardingStore.setSelectedCuisines(cuisines)
        onboardingStore.setSelectedGoals(goals)
        appSettingsStore.applyOnboardingSelections(cuisines: cuisines, goals: goals)
        userProfileStore.applyOnboardingSelections(cuisines: cuisines, goals: goals)
    }

    private func handleIncomingSharedImport(url: URL) {
        guard url.isFileURL else {
            return
        }

        if let mealPlanPayload = try? MealPlanSharingService.decodePayload(from: url) {
            pendingSharedMealPlanImport = nil
            pendingSharedMealPlanImport = mealPlanPayload
            sharedMealPlanImportError = nil
            selectedTab = .planner
            return
        }

        if let cartPayload = try? CartSharingService.decodePayload(from: url) {
            pendingSharedCartImport = cartPayload
            isSharedCartImportPresented = true
            sharedCartImportError = nil
            return
        }

        sharedMealPlanImportError = "That shared plan could not be imported."
        sharedCartImportError = "That shared cart could not be imported."
    }

    private func handleIncomingSharedMealPlan(url: URL) {
        guard url.isFileURL else {
            return
        }

        do {
            let payload = try MealPlanSharingService.decodePayload(from: url)
            pendingSharedMealPlanImport = nil
            pendingSharedMealPlanImport = payload
            sharedMealPlanImportError = nil
            selectedTab = .planner
        } catch {
            sharedMealPlanImportError = "That shared plan could not be imported."
            selectedTab = .planner
        }
    }
}

private enum AppTab: Hashable {
    case home
    case explore
    case planner
    case analytics
    case profile
}

#Preview {
    AppShellView()
}
