import SwiftUI

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let tab: TabItem
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    // Selection background
                    if isSelected {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.blue.opacity(0.8),
                                        Color.blue
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 40, height: 40)
                            .shadow(
                                color: Color.blue.opacity(0.3),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                            .matchedGeometryEffect(id: "selectedTab", in: namespace)
                    }
                    
                    // Icon
                    Image(systemName: isSelected ? tab.icon : tab.inactiveIcon)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(
                            isSelected ? .white : .secondary
                        )
                        .scaleEffect(isPressed ? 0.9 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: isPressed)
                }
                
                // Label
                Text(tab.title)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(
                        isSelected ? .primary : .secondary
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { isPressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = isPressing
            }
        } perform: {}
    }
}
