import SwiftUI
import Personalization

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
                        
                        // Content Zone for Personalized Promo Card
                        ContentZone(
                            name: "Promo_Card",
                            allowedComponents: [Banner()],
                            loading: { ProgressView() },
                            failed: { error in
                                HomePromoCardView()
                            }
                        )
                        .padding(.top, 32)
                        
                        // Content Zone for Personalized Product Recommendations
                        ContentZone(
                            name: "Product_Recommendations",
                            allowedComponents: [Recommendations()],
                            loading: { ProgressView() },
                            failed: { error in
                                HomeBestSellersSection()
                            }
                        )
                        .padding(.top, 32)
                        
                        // Best Sellers Section

                        
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
