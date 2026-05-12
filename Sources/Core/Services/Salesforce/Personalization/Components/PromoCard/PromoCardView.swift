import SwiftUI

// MARK: - Home Promo Card View
struct HomePromoCardView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.green.opacity(0.8),
                            Color.green,
                            Color.green.opacity(0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text("New Year Offer")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("30% OFF")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("16 - 31 Dec")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Button("Get Now") {
                        // Handle promo action
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.green)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.white, in: Capsule())
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
                
                Spacer()
                
                Text("🍕")
                    .font(.system(size: 64))
                    .rotationEffect(.degrees(15))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 28)
        }
        .frame(height: 160)
        .shadow(color: .green.opacity(0.2), radius: 12, x: 0, y: 6)
    }
}
