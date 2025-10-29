import SwiftUI

// MARK: - Liquid Glass Tab Bar Component
struct LiquidGlassTabBar: View {
    @Binding var selectedTab: Int
    @Namespace private var tabIndicator
    
    private let tabs = [
        TabItem(id: 0, title: "Home", icon: "house.fill", inactiveIcon: "house"),
        TabItem(id: 1, title: "Search", icon: "magnifyingglass", inactiveIcon: "magnifyingglass"),
        TabItem(id: 2, title: "Favorites", icon: "heart.fill", inactiveIcon: "heart"),
        TabItem(id: 3, title: "Profile", icon: "person.fill", inactiveIcon: "person")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.id) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab.id,
                    namespace: tabIndicator
                ) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedTab = tab.id
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            // Liquid glass effect
            ZStack {
                // Primary blur background
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                // Subtle border
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.clear,
                                Color.black.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
                
                // Inner shadow for depth
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.02),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        )
        .shadow(
            color: Color.black.opacity(0.08),
            radius: 20,
            x: 0,
            y: 8
        )
        .shadow(
            color: Color.black.opacity(0.04),
            radius: 1,
            x: 0,
            y: 1
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
}
