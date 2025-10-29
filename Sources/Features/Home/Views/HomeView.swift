import SwiftUI

// MARK: - Home View
struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // Header
                        HomeHeaderView()
                        
                        // Category Bar
                        HomeCategoryBarView()
                            .padding(.top, 24)
                        
                        // Promo Card
                        HomePromoCardView()
                            .padding(.top, 32)
                        
                        // Best Sellers Section
                        HomeBestSellersSection()
                            .padding(.top, 32)
                        
                        // Bottom spacing for tab bar
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
}
