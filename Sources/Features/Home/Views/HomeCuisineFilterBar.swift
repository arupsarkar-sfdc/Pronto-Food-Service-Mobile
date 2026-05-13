import SwiftUI

struct HomeCuisineFilterBar: View {
    @Binding var selectedCuisine: String?

    private let cuisines: [String] = Restaurant.allCuisines

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                CuisinePill(
                    label: "All Cuisines",
                    isSelected: selectedCuisine == nil
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCuisine = nil
                    }
                }

                ForEach(cuisines, id: \.self) { cuisine in
                    CuisinePill(
                        label: cuisine,
                        isSelected: selectedCuisine == cuisine
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCuisine = cuisine
                        }
                        trackCuisineSelection(cuisine)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func trackCuisineSelection(_ cuisine: String) {
        print("🍱 Cuisine tapped: \(cuisine)")

        EngagementTrackingService.shared.trackEvent(
            type: .custom("categoryEngagement"),
            attributes: [
                "categoryId": cuisine,
                "interactionName": "View Category"
            ]
        )
    }
}

private struct CuisinePill: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    private let selectedBackground = Color(red: 0.06, green: 0.20, blue: 0.13)

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? selectedBackground : Color(.systemBackground))
                )
                .overlay(
                    Capsule()
                        .stroke(Color(.separator).opacity(isSelected ? 0 : 0.4), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StatefulPreviewWrapper(String?.none) { binding in
        HomeCuisineFilterBar(selectedCuisine: binding)
            .padding(.vertical, 12)
            .background(Color(.systemGroupedBackground))
    }
}

private struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content

    init(_ initial: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        self._value = State(initialValue: initial)
        self.content = content
    }

    var body: some View { content($value) }
}
