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

                        ContentZone(
                            name: "Promo_Card",
                            allowedComponents: [Banner(), PromoCard()],
                            loading: { ProgressView() },
                            failed: { error in
                                HomePromoCardView()
                            }
                        )
                        .padding(.top, 24)

                        HomeRestaurantGrid(selectedCuisine: selectedCuisine)
                            .padding(.top, 32)

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
