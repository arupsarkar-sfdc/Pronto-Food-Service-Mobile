import SwiftUI


//https://developer.salesforce.com/docs/data/data-cloud-ref/guide/c360a-api-engagement-mobile-sdk.html

// MARK: - Main App Entry Point
struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        LiquidGlassTabView(selectedTab: $selectedTab)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
