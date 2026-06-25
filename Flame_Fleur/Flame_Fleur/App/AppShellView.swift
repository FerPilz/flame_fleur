import SwiftUI

struct AppShellView: View {
    @State private var selectedTab: AppTab = .home
    @State private var previousTab: AppTab = .home
    @State private var lastNonPlannerTab: AppTab = .home
    @State private var pendingExploreLaunchContext: ExploreLaunchContext?
    @StateObject private var shoppingCartStore = ShoppingCartStore.shared
    @StateObject private var mealPlannerStore = MealPlannerStore.shared
    @StateObject private var userRecipeStore = UserRecipeStore.shared
    @StateObject private var userProfileStore = UserProfileStore.shared
    @StateObject private var appSettingsStore = AppSettingsStore.shared
    @StateObject private var favoritesStore = FavoritesStore.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(openExplore: openExplore)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppTab.home)

            ExploreView(launchContext: $pendingExploreLaunchContext)
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
                .tag(AppTab.explore)

            PlannerView {
                selectedTab = lastNonPlannerTab
            }
                .toolbar(.hidden, for: .tabBar)
                .tabItem {
                    Label("Planner", systemImage: "calendar")
                }
                .tag(AppTab.planner)

            FavoritesView {
                goBackFromMainTab(.favorites)
            }
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
                .tag(AppTab.favorites)

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
        .environmentObject(shoppingCartStore)
        .environmentObject(mealPlannerStore)
        .environmentObject(userRecipeStore)
        .environmentObject(userProfileStore)
        .environmentObject(appSettingsStore)
        .environmentObject(favoritesStore)
        .onChange(of: selectedTab) { oldTab, newTab in
            if newTab != .planner {
                previousTab = oldTab == .planner ? lastNonPlannerTab : oldTab
                lastNonPlannerTab = newTab
            }
        }
    }

    private func openExplore(_ context: ExploreLaunchContext) {
        pendingExploreLaunchContext = context
        selectedTab = .explore
    }

    private func goBackFromMainTab(_ tab: AppTab) {
        selectedTab = (previousTab == tab || previousTab == .planner) ? .home : previousTab
    }
}

private enum AppTab: Hashable {
    case home
    case explore
    case planner
    case favorites
    case profile
}

#Preview {
    AppShellView()
}
