import SwiftUI

// MARK: - Liquid Glass Tab Bar Component
struct LiquidGlassTabBar: View {
    @Binding var selectedTab: Int
    @Namespace private var tabIndicator
    @State private var isExpanded = false
    
    private let tabs = [
        TabItem(id: 0, title: "Home", icon: "house.fill", inactiveIcon: "house"),
        TabItem(id: 1, title: "Search", icon: "magnifyingglass", inactiveIcon: "magnifyingglass"),
        TabItem(id: 2, title: "Favorites", icon: "heart.fill", inactiveIcon: "heart"),
        TabItem(id: 3, title: "Profile", icon: "person.fill", inactiveIcon: "person")
    ]
    
    var body: some View {
        HStack(spacing: isExpanded ? 20 : 0) {  // Collapsible spacing
            // Home button - always visible (triggers expansion)
            TabBarButton(
                tab: tabs[0],
                isSelected: selectedTab == 0,
                namespace: tabIndicator
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    if selectedTab == 0 {
                        // If already on Home, toggle expansion
                        isExpanded.toggle()
                    } else {
                        // Navigate to Home and expand
                        selectedTab = 0
                        isExpanded = true
                    }
                }
            }
            
            
            // Other tabs - shown only when expanded
            if isExpanded {
                ForEach(tabs.dropFirst(), id: \.id) { tab in
                    TabBarButton(
                        tab: tab,
                        isSelected: selectedTab == tab.id,
                        namespace: tabIndicator
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab.id
                        }
                    }
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    .padding(.horizontal,10)
                    
                }
            }
        }
//        .padding(.horizontal, 12)
//        .padding(.vertical, 6)
//        .background(.ultraThinMaterial)
//        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
//        .shadow(color: .black.opacity(0.07), radius: 4, x: 0, y: 1)
//        .padding(.bottom, 16)
        .glassEffect()
    }
}
