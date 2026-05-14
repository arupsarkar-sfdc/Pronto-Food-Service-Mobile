import SwiftUI
import Personalization

// MARK: - Home View
struct HomeView: View {
    @State private var selectedCuisine: String? = nil

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 0) {
                        HomeHeaderView()

                        HomeCuisineFilterBar(selectedCuisine: $selectedCuisine)
                            .padding(.top, 24)
                            .padding(.bottom, 24)

                        ContentZone(
                            name: "Promo_Card",
                            allowedComponents: [PromoCard()],
                            loading: { ProgressView() },
                            failed: { error in
                                HomePromoCardView()
                            }
                        )
                        .padding(.top, 24)
                        .padding(.bottom, 10)

                        ContentZone(
                            name: "Product_Recommendations",
                            allowedComponents: [ProductRecommendations()],
                            loading: { ProgressView() },
                            failed: { error in
                                
                            }
                        )
                        .padding(.top, 32)
                        .padding(.top, 10)

                        HomeRestaurantGrid(selectedCuisine: selectedCuisine)
                        .padding(.top, 32)
                        .padding(.top, 10)
                        
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .refreshable {
            print("refreshing...")
        }
    }

}
