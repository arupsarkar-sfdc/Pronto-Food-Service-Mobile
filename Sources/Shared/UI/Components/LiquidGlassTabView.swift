import SwiftUI

// MARK: - Liquid Glass Tab View
struct LiquidGlassTabView: View {
    @Binding var selectedTab: Int
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.secondarySystemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Main Content Area
                Group {
                    switch selectedTab {
                    case 0:
                        HomeView()
                    case 1:
                        SearchView()
                    case 2:
                        FavoritesView()
                    case 3:
                        ProfileView()
                    default:
                        HomeView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Custom Liquid Glass Tab Bar
                LiquidGlassTabBar(selectedTab: $selectedTab)
            }
        }
    }
}
