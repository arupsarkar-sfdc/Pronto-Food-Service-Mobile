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
            VStack(spacing: 3) {  // Tighter spacing: 4 → 3
                // Icon - Smaller and compact
                Image(systemName: isSelected ? tab.icon : tab.inactiveIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)  // Smaller: 24 → 20
                    .foregroundStyle(.primary)
                
                // Label
                Text(tab.title)
                    .font(.system(size: 9, weight: isSelected ? .semibold : .regular))  // Smaller: 10 → 9
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { isPressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = isPressing
            }
        } perform: {}
    }
}
