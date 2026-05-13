import SwiftUI

struct HomeRestaurantGrid: View {
    let selectedCuisine: String?

    @State private var pressedRestaurantId: String? = nil

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var restaurants: [Restaurant] {
        Restaurant.filtered(by: selectedCuisine)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center) {
                Text("Best Sellers")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(.primary)
                    .tracking(-0.5)

                Spacer()

                Button(action: {}) {
                    Text("See All")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 1.0, green: 0.27, blue: 0))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color(red: 1.0, green: 0.27, blue: 0).opacity(0.1))
                        )
                }
            }

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(restaurants) { restaurant in
                    RestaurantCard(
                        restaurant: restaurant,
                        isPressed: pressedRestaurantId == restaurant.id
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            pressedRestaurantId = restaurant.id
                        }
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()

                        trackRestaurantView(restaurant)

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                pressedRestaurantId = nil
                            }
                        }
                    }
                }
            }
        }
    }

    private func trackRestaurantView(_ r: Restaurant) {
        print("🍽️ Restaurant tapped: \(r.name) [\(r.id)]")

        EngagementTrackingService.shared.trackEvent(
            type: .catalog(.view),
            attributes: [
                "catalogObjectId": r.id,
                "type": "Restaurant",
                "interactionName": "View Catalog Object",
                "name": r.name,
                "cuisine": r.cuisine,
                "priceLevel": r.priceLevel,
                "rating": r.rating
            ]
        )
    }
}

struct RestaurantCard: View {
    let restaurant: Restaurant
    let isPressed: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                GeometryReader { geometry in
                    if let url = URL(string: restaurant.imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(.systemGray5), Color(.systemGray4)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(ProgressView().tint(.gray))
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                            case .failure:
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                    .overlay(Text("🍽️").font(.system(size: 48)))
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }
                .frame(height: 160)
                .clipped()

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0))

                    Text(restaurant.formattedRating)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                .padding(10)

                if let badge = restaurant.badge {
                    BadgeView(badge: badge)
                        .padding(10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                }
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .contentShape(Rectangle())

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(restaurant.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Spacer()

                    Text(restaurant.priceLevel)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }

                Text(restaurant.description)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    HStack(spacing: 10) {
                        Label {
                            Text(restaurant.prepTime)
                        } icon: {
                            Image(systemName: "clock")
                        }

                        Label {
                            Text(restaurant.deliveryFee)
                        } icon: {
                            Image(systemName: "bicycle")
                        }
                    }
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                    Spacer()

                    Circle()
                        .fill(Color(red: 0.13, green: 0.70, blue: 0.31))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
                }
                .padding(.top, 4)
            }
            .padding(.all, 12)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(
            color: .black.opacity(0.06),
            radius: isPressed ? 2 : 8,
            x: 0,
            y: isPressed ? 1 : 4
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
        )
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct BadgeView: View {
    let badge: Restaurant.Badge

    var body: some View {
        Text(badge.rawValue)
            .font(.system(size: 10, weight: .heavy, design: .rounded))
            .tracking(0.5)
            .foregroundColor(badge == .chefsPick ? .black : .white)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                Capsule().fill(
                    badge == .chefsPick
                        ? Color(red: 0.78, green: 0.95, blue: 0.32)
                        : Color(red: 0.06, green: 0.20, blue: 0.13)
                )
            )
    }
}

#Preview {
    ScrollView {
        HomeRestaurantGrid(selectedCuisine: nil)
            .padding(20)
    }
    .background(Color(.systemGroupedBackground))
}
