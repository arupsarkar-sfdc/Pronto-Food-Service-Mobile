import SwiftUI
import Personalization
import LowCodeMobile

// MARK: - Home Promo Card View
public struct PromoCardView: View {
    let model: PromoCardModel
    let componentContext: ComponentContext
    
    public init(model: PromoCardModel, componentContext: ComponentContext) {
        self.model = model
        self.componentContext = componentContext
    }

    func getColor(from name: String) -> Color {
        switch name.lowercased() {
            case "red": return .red
            case "blue": return .blue
            case "green": return .green
            default: return .gray // Your default fallback
        }
    }
    
    public var body: some View {
        let color = getColor(from: model.backgroundColor ?? "")
        
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            color.opacity(0.8),
                            color,
                            color.opacity(0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            

                VStack(alignment: .leading, spacing: 12) {
                    Text(model.header ?? "")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text(model.subheader ?? "")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text(model.text ?? "")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                    
                    
                    HStack {
                        Button(model.ctaText ?? "") {
                            // Handle promo action
                        }
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(color)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.white, in: Capsule())
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        
                        Spacer()
                        
                        Text(model.imageUrl ?? "")
                            .font(.system(size: 40))
                            .rotationEffect(.degrees(15))
                    }

                }
                .padding(.horizontal, 24)
                .padding(.vertical, 28)

        }
        .frame(height: 160)
        .shadow(color: color.opacity(0.2), radius: 12, x: 0, y: 6)
    }
}
