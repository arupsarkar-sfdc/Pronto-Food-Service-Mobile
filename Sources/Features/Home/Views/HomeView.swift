import SwiftUI
import Personalization
import LowCodeMobile

// MARK: - Home View
struct HomeView: View {
    @State private var selectedCuisine: String? = nil

    @State private var promoBannerZoneController = ContentZoneController()
    
    @State private var productRecsZoneController = ContentZoneController()
    
    @State private var loyaltyZoneController = ContentZoneController()
    
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
                                name: "Loyalty_Promotion",
                                allowedComponents: [PromotionsAndOffers()],
                                controller: loyaltyZoneController,
                                loading: { ProgressView() }
                            )
                            .padding(.top, 10)
                            .padding(.bottom, 20)
                            
                            ContentZone(
                                name: "Promo_Card",
                                allowedComponents: [PromoCard()],
                                controller: promoBannerZoneController,
                                
                                loading: { ProgressView() },
                                
                                fallback: { error in
                                    HomePromoCardView()
                                }
                            )
                            .padding(.top, 24)
                            .padding(.bottom, 10)
                            
                            ContentZone(
                                name: "Product_Recommendations",
                                allowedComponents: [ProductRecommendations()],
                                controller: productRecsZoneController,
                                loading: {
                                    ProgressView()
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
            /*
            async let promoBannerZoneRefresh = promoBannerZoneController.refresh(withLoadingState: true)
            async let productRecsZoneRefresh = productRecsZoneController.refresh(withLoadingState: true)
            async let loyaltyZoneRefresh =  loyaltyZoneController.refresh(withLoadingState: true)

            let (_, _, _) = await (promoBannerZoneRefresh, productRecsZoneRefresh, loyaltyZoneRefresh)*/
            
            await (
                promoBannerZoneController.refresh(withLoadingState: true),
                productRecsZoneController.refresh(withLoadingState: true),
                loyaltyZoneController.refresh(withLoadingState: true)
            )
        }
    }

}
