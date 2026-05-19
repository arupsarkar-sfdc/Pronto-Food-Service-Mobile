import SwiftUI
import Personalization
import LowCodeMobile

// MARK: - Home View
struct HomeView: View {
    @State private var selectedCuisine: String? = nil

    @State private var promoBannerZoneViewModel = ContentZoneViewModel(
        contentZoneName: "Promo_Card",
        allowedComponents: [PromoCard()]
    )
    
    @State private var productRecsZoneViewModel = ContentZoneViewModel(
        contentZoneName: "Product_Recommendations",
        allowedComponents: [ProductRecommendations()]
    )
    
    
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
                                viewModel: promoBannerZoneViewModel,
                                loading: { ProgressView() },
                                failed: { error in
                                    HomePromoCardView()
                                }
                            )
                            .padding(.top, 24)
                            .padding(.bottom, 10)
                            
                            ContentZone(
                                viewModel: productRecsZoneViewModel,
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
                .navigationBarHidden(true)
                
            }
            
            
            
        }

        .refreshable {
            await promoBannerZoneViewModel.reload()
            await productRecsZoneViewModel.reload()
        }
    }

}
