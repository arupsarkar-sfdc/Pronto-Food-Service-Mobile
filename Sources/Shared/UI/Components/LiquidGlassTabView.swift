import SwiftUI

// MARK: - Liquid Glass Tab View (Native iOS TabView with Glass styling)
struct LiquidGlassTabView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("", systemImage: "house", value: 0) {
                HomeView()
            }
            
            Tab("", systemImage: "magnifyingglass", value: 1) {
                SearchView()
            }
            
            Tab("", systemImage: "heart", value: 2) {
                FavoritesView()
            }
            
            Tab("", systemImage: "person", value: 3) {
                ProfileView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}
