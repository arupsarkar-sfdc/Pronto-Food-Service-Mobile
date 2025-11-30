# Pronto Food Delivery App

> **Modern iOS food delivery application with Salesforce Data Cloud and AI-powered personalization**

---

## 🎯 Business Overview

**Pronto** is a next-generation food delivery platform that leverages **Salesforce Data Cloud** and **real-time personalization** to deliver individualized experiences across all channels. Whether a user browses on the web or mobile app, their preferences and behaviors are unified in real-time, enabling intelligent recommendations that drive engagement and conversion.

### **The Problem We Solve**

Traditional food delivery apps treat each channel (web, mobile, tablet) as isolated silos. A user who clicks "Sushi" 6 times on the website still sees generic "Pizza" recommendations when they open the mobile app. This disconnect leads to:
- ❌ Poor user experience (irrelevant recommendations)
- ❌ Lost revenue (lower conversion rates)
- ❌ Wasted engineering effort (complex custom logic per channel)

### **Our Solution**

Pronto uses **Salesforce Data Cloud** for omni-channel identity resolution and **Pro Code Personalization** to deliver context-aware recommendations:
- ✅ **Real-time data sync** (<300ms from web click to mobile update)
- ✅ **Cross-channel identity resolution** (automatic device linking)
- ✅ **AI-driven personalization** (no custom ranking logic needed)
- ✅ **Developer-friendly SDK** (single API call replaces 500+ lines of code)

**Result:** Users see "Sushi" recommendations on mobile because the system knows they prefer it from their web behavior—automatically, in real-time, with zero custom logic.

---

## 🚀 Key Features

### **1. Omni-Channel Personalization**
- **Pro Code SDK Integration**: One SDK call fetches personalized content based on unified user profiles
- **Real-Time Decision Engine**: Data Cloud evaluates rules server-side and returns optimal content
- **Cross-Platform Context**: Web clicks instantly influence mobile recommendations (<300ms)
- **Dynamic Content Rendering**: "Sushi" vs "Pizza" decided by actual user engagement, not static rules

### **2. Intelligent User Engagement Tracking**
- **Automatic Identity Resolution**: Links browser sessions to mobile devices via Unified Individual profiles
- **Comprehensive Event Tracking**: Cart, catalog, favorites, orders, searches—all tracked automatically
- **Privacy-First Consent Management**: GDPR-compliant opt-in/opt-out with full transparency
- **Location-Aware Personalization**: GPS tracking for hyper-local restaurant recommendations

### **3. Modern iOS Architecture**
- **SwiftUI + MVVM**: Declarative UI with clean separation of concerns
- **Async/Await**: Modern concurrency for smooth, responsive UX
- **Type-Safe Networking**: Strongly-typed API layer with Combine support
- **Modular Codebase**: Feature-based organization for scalability

### **4. Salesforce Data Cloud Integration**
- **Customer Data Platform (CDP)**: Unified customer profiles across all touchpoints
- **Real-Time Event Streaming**: Engagement data ingested in <300ms
- **Data Graph API Access**: Query user behavior and preferences on-demand
- **Mobile Connector**: Native iOS SDK for seamless Data Cloud communication

---

## 💻 Engineering Highlights

### **Why Pro Code Personalization is a Game-Changer**

Traditional personalization requires developers to:
1. Fetch all content options from an API
2. Fetch user engagement data from another API
3. Write custom scoring/ranking algorithms
4. Handle identity resolution across devices
5. Maintain complex rule engines

**With Salesforce Personalization SDK**, this entire flow collapses into **a single SDK call**:

#### **Traditional Approach (Multiple APIs + Custom Logic)**
```swift
// ❌ Old Way: 500+ lines of code
let allOptions = try await fetchPersonalizationOptions()
let engagements = try await fetchUserEngagements()
let deviceLinks = try await linkDeviceIdentities()
let winner = customScoringAlgorithm(allOptions, engagements, deviceLinks)
renderContent(winner)
```

#### **Pro Code SDK Approach (Single Call)**
```swift
// ✅ New Way: 3 lines of code
let response = try await PersonalizationModule.fetchDecisions(
    personalizationPointNames: ["Pronto"]
)
renderContent(response.personalizations["Pronto"])  // Done!
```

---

### **Two Killer SDK Capabilities**

#### **1. Automatic Device Identity Resolution**
**Problem:** Users interact with brands across multiple devices. Linking these identities manually requires complex correlation logic.

**Solution:** The SDK handles cross-channel identity resolution seamlessly:
- Web browser session (device ID: `4be44eaae0770cdd`)
- iOS app session (device ID: `D46475B0-B111-4EA0-A6BF-5E1AD8FC4675`)
- **Automatically linked** via `UnifiedIndividual` (`9ea2aa85ce5b5a1e15498c204306aa76`)

**Developer Impact:** Zero lines of identity stitching code. The SDK correlates devices automatically using email, cookies, device IDs, and more.

---

#### **2. Server-Side Decision Evaluation**
**Problem:** REST APIs return raw data, forcing apps to implement custom scoring, ranking, and rule evaluation.

**Solution:** The SDK evaluates personalization rules **in Data Cloud** and returns the **optimal decision**:
- User clicks "Sushi" 6 times on web + "Pizza" 4 times → SDK returns "Sushi"
- No client-side logic needed
- Rules managed centrally in Data Cloud (no app updates required)

**Developer Impact:** No conditional logic, no scoring algorithms, no rule engines. Just render the result.

---

### **Real-World Demo Flow**

```
1. Web Interaction
   User clicks "Sushi" (6x) and "Pizza" (4x) on website
   ↓
2. Data Cloud Ingestion (<300ms)
   Events streamed → Identity resolved → Profile updated
   ↓
3. Mobile App Launch
   iOS app calls: fetchDecisions("Pronto")
   ↓
4. Smart Response
   SDK returns "Sushi" (higher engagement) automatically
   ↓
5. Instant Render
   App displays personalized "Sushi" content—no custom logic
```

**Key Insight:** What would typically require 500+ lines of identity resolution, engagement tracking, scoring logic, and rule evaluation is reduced to **a single SDK call**.

---

## 🏗️ Technical Architecture

### **Architecture Pattern: MVVM (Model-View-ViewModel)**

```
┌─────────────────────────────────────────────────────┐
│                      SwiftUI Views                   │
│  (Declarative UI, @StateObject, @ObservedObject)    │
└──────────────────────┬──────────────────────────────┘
                       │
                       │ Observes @Published properties
                       │
┌──────────────────────▼──────────────────────────────┐
│                    ViewModels                        │
│  (Business Logic, State Management, ObservableObject)│
└──────────────────────┬──────────────────────────────┘
                       │
                       │ Uses Services
                       │
┌──────────────────────▼──────────────────────────────┐
│                  Service Layer                       │
│ • PersonalizationService (Pro Code SDK)             │
│ • DataCloudService (Event Tracking)                 │
│ • DataGraphQueryService (Real-Time Data)            │
│ • ProfileDataService (Identity Management)          │
│ • ConsentService (Privacy Controls)                 │
└──────────────────────┬──────────────────────────────┘
                       │
                       │ Communicates with
                       │
┌──────────────────────▼──────────────────────────────┐
│              Salesforce Data Cloud                   │
│ • Customer Data Platform (CDP)                       │
│ • Personalization Engine                             │
│ • Data Graph API                                     │
│ • Identity Resolution                                │
└──────────────────────────────────────────────────────┘
```

---

### **Core Services**

| Service | Purpose | Key Features |
|---------|---------|--------------|
| **PersonalizationService** | Fetch AI-driven content decisions | • Single SDK call<br>• Server-side rule evaluation<br>• Cross-channel context |
| **DataCloudService** | Track user engagement events | • Cart, catalog, favorites<br>• Automatic batching<br>• Real-time streaming |
| **DataGraphQueryService** | Query user behavior on-demand | • Direct API access<br>• JWT token management<br>• Unified profile data |
| **ProfileDataService** | Manage identity lifecycle | • Anonymous → Known transition<br>• Device info capture<br>• Contact attributes |
| **ConsentService** | GDPR-compliant privacy | • Opt-in/opt-out<br>• Persistent storage<br>• Auto event blocking |
| **LocationTrackingService** | GPS-based personalization | • CoreLocation integration<br>• Automatic permission mgmt<br>• 60s expiration |

---

## 📊 Salesforce Integration Deep Dive

### **1. Data Cloud Event Tracking**

**Every user action is tracked and streamed to Data Cloud in real-time:**

| User Action | Event Type | Data Captured |
|-------------|------------|---------------|
| Browse menu | `catalog` | Product ID, category, timestamp |
| Add to favorites | `addToFavorite` | Product ID, name, price |
| Add to cart | `cart` + `cartItem` | Quantity, price, currency, session |
| Place order | `order` + `orderItem` | Order ID, items, total, address |
| Update profile | `identity` | Name, email, phone |
| Screen navigation | `appEvents` | Screen name, duration |
| Consent changes | `consentLog` | Status, purpose, timestamp |

**Example: Add to Cart**
```swift
engagementService.trackAddToCart(
    productId: "pizza-123",
    productName: "Margherita Pizza",
    quantity: 1,
    price: 11.88,
    currency: "USD"
)
```

This automatically includes:
- ✅ Device ID
- ✅ Session ID
- ✅ Timestamp (ISO 8601)
- ✅ User identity (if known)
- ✅ Location (if enabled)

---

### **2. Pro Code Personalization Flow**

**Step 1: User Browses (Web)**
```
User clicks "Sushi" 6x on website
   ↓
Event: { productId: "sushi", channel: "web" }
   ↓
Data Cloud: Streamed + Ingested (<300ms)
   ↓
Individual Profile: Updated with engagement
```

**Step 2: User Opens Mobile App**
```swift
// iOS App calls Personalization SDK
let response = try await PersonalizationModule.fetchDecisions(
    personalizationPointNames: ["Pronto"]
)
```

**Step 3: Data Cloud Evaluates Rules**
```
Data Cloud:
  1. Identifies user via UnifiedIndividual
  2. Queries ProductBrowseEngagement events
  3. Aggregates clicks: { Sushi: 6, Pizza: 4 }
  4. Evaluates personalization rules
  5. Returns winning decision: "Sushi"
```

**Step 4: App Renders Content**
```swift
// SDK response contains winning decision
let winner = response.personalizations["Pronto"]
// Display: Sushi background image, CTA, etc.
```

**Key Insight:** The app **never writes custom logic** to determine what to show. Data Cloud does the heavy lifting.

---

### **3. Identity Resolution**

**Anonymous → Known User Journey**

```swift
// 1. App Launch (Anonymous)
ProfileDataService.shared.setAnonymousProfile()
// → SDK generates anonymous ID
// → All events tagged with anonymous ID

// 2. User Signs Up / Logs In
ProfileDataService.shared.setKnownProfile(
    firstName: "Leander",
    lastName: "Paes",
    email: "leander.paes@example.com"
)
// → Profile transitions to "known"
// → ALL past anonymous events linked to known user
// → Identity attributes propagated to future events

// 3. Update Contact Info
ProfileDataService.shared.updateContactInformation(
    phone: "+1-555-123-4567",
    address: Address(...)
)
// → Contact attributes sent to Data Cloud
// → Future events include phone + address
```

**Why This Matters:**
- No manual event migration needed
- Historical behavior preserved
- Single unified profile across all channels

---

### **4. Data Graph API**

**Direct access to unified customer data:**

```swift
let result = try await DataGraphQueryService.shared.queryDataGraph(
    dataGraphName: "C360_Contact_RT",
    dmoName: "UnifiedLinkssotIndividualI1__dlm",
    fieldName: "UnifiedRecordId__c",
    value: "9ea2aa85ce5b5a1e15498c204306aa76"
)
```

**Returns:**
```json
{
  "data": [{
    "ssot__FirstName__c": "Leander",
    "ssot__LastName__c": "Paes",
    "ssot__ProductBrowseEngagement__dlm": [
      { "ssot__ProductId__c": "Sushi", "ssot__CreatedDate__c": "..." },
      { "ssot__ProductId__c": "Pizza", "ssot__CreatedDate__c": "..." }
    ]
  }]
}
```

**Use Cases:**
- Display user's order history
- Show favorite products
- Calculate engagement metrics
- Personalize content in real-time

---

## 🛠️ Getting Started

### **Prerequisites**

- **iOS 15.0+**
- **Xcode 14.0+**
- **Swift 5.7+**
- **Salesforce Data Cloud Tenant** (with Mobile Connector configured)
- **SPM (Swift Package Manager)** for dependencies

---

### **Installation**

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/ProntoFoodDeliveryApp.git
   cd ProntoFoodDeliveryApp
   ```

2. **Open in Xcode**
   ```bash
   open ProntoFoodDeliveryApp.xcodeproj
   ```

3. **Configure Salesforce Credentials**

   Update `Sources/Core/Services/Salesforce/DataCloud/DataCloudConfiguration.swift`:

   ```swift
   static var development: DataCloudConfiguration {
       DataCloudConfiguration(
           appId: "YOUR_DEV_APP_ID",        // From Mobile Connector
           endpoint: "YOUR_DEV_ENDPOINT",    // From Mobile Connector
           enableLogging: true
       )
   }
   ```

4. **Install Dependencies**

   Xcode will automatically resolve SPM dependencies on first build:
   - Salesforce Marketing Cloud SDK
   - CDP Module
   - Personalization Module

5. **Build and Run**
   ```
   ⌘ + R  (or click the Play button)
   ```

---

### **Salesforce Data Cloud Setup**

1. **Create Mobile Connector**
   - Navigate to Data Cloud → Mobile & Web
   - Create a new Mobile Connector
   - Copy `appId` and `endpoint`

2. **Configure Personalization Point**
   - Navigate to Personalization → Points
   - Create "Pronto" personalization point
   - Add decision records: "Pizza", "Sushi"
   - Define attributes: `BackgroundImageUrl`, `CallToActionText`, `CallToActionUrl`

3. **Set Up Identity Resolution**
   - Configure reconciliation rules (email, device ID)
   - Map data sources (Web, Mobile)
   - Enable real-time identity resolution

4. **Test Integration**
   - Run the app
   - Check Xcode console for SDK initialization logs
   - Verify events in Data Cloud → Engagement Streams

---

## 📁 Project Structure

```
ProntoFoodDeliveryApp/
├── README.md                                 # This file
├── Package.swift                             # SPM dependencies
├── Sources/
│   ├── App/
│   │   └── ProntoFoodDeliveryAppApp.swift   # App entry point & SDK init
│   │
│   ├── Core/
│   │   ├── Models/
│   │   │   ├── Product.swift                # Business entities
│   │   │   └── PersonalizationDecisionRecord.swift  # Pro Code models
│   │   │
│   │   ├── Services/
│   │   │   └── Salesforce/
│   │   │       ├── DataCloud/               # Event tracking services
│   │   │       │   ├── DataCloudService.swift
│   │   │       │   ├── EngagementTrackingService.swift
│   │   │       │   ├── ProfileDataService.swift
│   │   │       │   ├── ConsentService.swift
│   │   │       │   ├── LocationTrackingService.swift
│   │   │       │   └── DataGraphQueryService.swift
│   │   │       │
│   │   │       └── Personalization/         # Pro Code SDK
│   │   │           └── PersonalizationService.swift
│   │   │
│   │   ├── Networking/                      # API layer
│   │   ├── Persistence/                     # Local storage
│   │   └── Utilities/                       # Helpers
│   │
│   ├── Features/                            # MVVM feature modules
│   │   ├── Home/
│   │   │   ├── Views/
│   │   │   │   └── HomeView.swift
│   │   │   └── ViewModels/
│   │   │       └── HomeViewModel.swift
│   │   │
│   │   ├── Profile/
│   │   │   ├── Views/
│   │   │   │   └── FavoritesView.swift      # Pro Code Personalization UI
│   │   │   └── ViewModels/
│   │   │       └── PersonalizationViewModel.swift  # Decision logic
│   │   │
│   │   ├── Cart/                            # Shopping cart
│   │   ├── Order/                           # Order management
│   │   └── Search/                          # Restaurant search
│   │
│   └── Shared/
│       ├── UI/
│       │   ├── Components/                  # Reusable SwiftUI views
│       │   └── Modifiers/                   # Custom view modifiers
│       └── Protocols/                       # Shared interfaces
│
├── Tests/
│   ├── UnitTests/                           # Logic tests
│   ├── IntegrationTests/                    # Service tests
│   └── UITests/                             # End-to-end tests
│
├── Resources/
│   ├── Images/                              # App assets
│   ├── Configuration/                       # Environment configs
│   └── Localizations/                       # i18n strings
│
└── Documentation/
    ├── API/                                 # Service docs
    └── Architecture/                        # Design docs
```

---

## 🎨 Code Examples

### **1. ViewModel with Personalization**

```swift
import Foundation
import Combine

@MainActor
final class PersonalizationViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var winningDecision: PersonalizationDecisionRecord?
    @Published var allDecisionRecords: [PersonalizationDecisionRecord] = []
    @Published var isLoading = false
    @Published var error: String?
    
    // MARK: - Services
    
    private let personalizationService: PersonalizationServiceProtocol
    private let dataGraphService: DataGraphQueryServiceProtocol
    
    // MARK: - Initialization
    
    init(
        personalizationService: PersonalizationServiceProtocol = PersonalizationService.shared,
        dataGraphService: DataGraphQueryServiceProtocol = DataGraphQueryService.shared
    ) {
        self.personalizationService = personalizationService
        self.dataGraphService = dataGraphService
    }
    
    // MARK: - Fetch Personalization with Winner Selection
    
    func fetchPersonalizationWithWinner() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Step 1: Fetch all decision records from SDK
            let result = try await personalizationService.fetchDecisions(
                personalizationPointNames: ["Pronto"]
            )
            
            // Step 2: Parse decision records
            let decisions = parseAllDecisionRecords(from: result)
            self.allDecisionRecords = decisions
            
            // Step 3: Fetch click counts from Data Graph
            let clickCounts = try await fetchClickCountsFromDataGraph()
            
            // Step 4: Select winner based on clicks
            let winner = selectWinner(decisions: decisions, clickCounts: clickCounts)
            self.winningDecision = winner
            
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    // MARK: - Parse Decision Records
    
    private func parseAllDecisionRecords(
        from result: PersonalizationDecisionsResult
    ) -> [PersonalizationDecisionRecord] {
        guard let prontoDecision = result.personalizations["Pronto"] else {
            return []
        }
        
        var records: [PersonalizationDecisionRecord] = []
        
        // Parse from attributes (single decision)
        if let header = prontoDecision.attributes["Header"] as? String {
            let record = PersonalizationDecisionRecord(
                id: prontoDecision.personalizationId,
                name: header,
                backgroundImageUrl: prontoDecision.attributes["BackgroundImageUrl"] as? String,
                callToActionText: prontoDecision.attributes["CallToActionText"] as? String,
                callToActionUrl: prontoDecision.attributes["CallToActionUrl"] as? String,
                header: prontoDecision.attributes["Header"] as? String,
                subheader: prontoDecision.attributes["Subheader"] as? String
            )
            records.append(record)
        }
        
        // Parse from contentObjects (multiple decisions)
        for contentObject in prontoDecision.contentObjects {
            if let name = contentObject.data["name"] as? String ?? contentObject.data["Header"] as? String {
                let record = PersonalizationDecisionRecord(
                    id: contentObject.personalizationContentId,
                    name: name,
                    backgroundImageUrl: contentObject.data["BackgroundImageUrl"] as? String,
                    callToActionText: contentObject.data["CallToActionText"] as? String,
                    callToActionUrl: contentObject.data["CallToActionUrl"] as? String,
                    header: contentObject.data["Header"] as? String,
                    subheader: contentObject.data["Subheader"] as? String
                )
                records.append(record)
            }
        }
        
        return records
    }
    
    // MARK: - Fetch Click Counts from Data Graph
    
    private func fetchClickCountsFromDataGraph() async throws -> [String: Int] {
        let result = try await dataGraphService.queryDataGraph(
            dataGraphName: "C360_Contact_RT",
            dmoName: "UnifiedLinkssotIndividualI1__dlm",
            fieldName: "UnifiedRecordId__c",
            value: "9ea2aa85ce5b5a1e15498c204306aa76"
        )
        
        var counts: [String: Int] = [:]
        
        // Parse ProductBrowseEngagement events
        if let dataArray = result["data"] as? [[String: Any]],
           let firstData = dataArray.first,
           let jsonBlobString = firstData["json_blob__c"] as? String,
           let jsonBlobData = jsonBlobString.data(using: .utf8),
           let jsonBlob = try? JSONSerialization.jsonObject(with: jsonBlobData) as? [String: Any],
           let unifiedLinks = jsonBlob["UnifiedLinkssotIndividualI1__dlm"] as? [[String: Any]] {
            
            for link in unifiedLinks {
                if let individuals = link["ssot__Individual__dlm"] as? [[String: Any]],
                   let individual = individuals.first,
                   let engagements = individual["ssot__ProductBrowseEngagement__dlm"] as? [[String: Any]] {
                    
                    for engagement in engagements {
                        if let productId = engagement["ssot__ProductId__c"] as? String {
                            // Normalize product name
                            let normalized = productId.prefix(1).uppercased() + productId.dropFirst().lowercased()
                            counts[normalized, default: 0] += 1
                        }
                    }
                }
            }
        }
        
        return counts
    }
    
    // MARK: - Select Winner (Case-Insensitive)
    
    private func selectWinner(
        decisions: [PersonalizationDecisionRecord],
        clickCounts: [String: Int]
    ) -> PersonalizationDecisionRecord? {
        guard !decisions.isEmpty else { return nil }
        
        // Merge click counts (case-insensitive)
        var decisionsWithCounts = decisions.map { decision in
            var d = decision
            for (key, count) in clickCounts {
                if key.lowercased() == decision.name.lowercased() {
                    d.clickCount = count
                    break
                }
            }
            return d
        }
        
        // Sort by click count (descending)
        decisionsWithCounts.sort { $0.clickCount > $1.clickCount }
        
        return decisionsWithCounts.first
    }
}
```

---

### **2. SwiftUI View with Pro Code Personalization**

```swift
struct FavoritesView: View {
    @StateObject private var viewModel = PersonalizationViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Pro Code Personalization Section
                proCodePersonalizationCard
                
                // Other content...
            }
        }
        .task {
            await viewModel.fetchPersonalizationWithWinner()
        }
    }
    
    private var proCodePersonalizationCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with Dynamic Background
            ZStack(alignment: .topTrailing) {
                if let winner = viewModel.winningDecision,
                   let imageUrl = winner.backgroundImageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: 200)
                            .clipped()
                    } placeholder: {
                        gradientBackground
                    }
                } else {
                    gradientBackground
                }
                
                // "Pro Code" Badge
                HStack(spacing: 8) {
                    Image(systemName: "wand.and.stars")
                    Text("Pro Code")
                        .fontWeight(.semibold)
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.black.opacity(0.6)))
                .padding(12)
            }
            .frame(height: 200)
            
            // Winning Decision Content
            if let winner = viewModel.winningDecision {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("🏆 Top Choice for You")
                            .font(.headline)
                        Spacer()
                        if winner.clickCount > 0 {
                            Text("\(winner.clickCount) clicks")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text(winner.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let cta = winner.callToActionText,
                       let url = winner.callToActionUrl {
                        Link(destination: URL(string: url)!) {
                            HStack {
                                Text(cta)
                                Image(systemName: "arrow.right.circle.fill")
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Capsule().fill(Color.blue))
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 4)
        .padding()
    }
    
    private var gradientBackground: some View {
        LinearGradient(
            colors: [Color.purple.opacity(0.6), Color.pink.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
```

---

## 🎓 Best Practices

### **1. Always Set Identity Early**

```swift
// ✅ GOOD: Set known profile immediately after login
func handleSuccessfulLogin(user: User) {
    ProfileDataService.shared.setKnownProfile(
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email
    )
}
```

### **2. Check Consent Before Tracking**

```swift
// ✅ GOOD: Services automatically check consent
engagementService.trackAddToCart(...)  // Only tracks if user opted in

// ❌ BAD: Direct SDK calls bypass consent
SFMCSdk.track(event: myEvent)  // Don't do this
```

### **3. Use Dependency Injection**

```swift
// ✅ GOOD: Inject services for testability
class MyViewModel: ObservableObject {
    private let personalizationService: PersonalizationServiceProtocol
    
    init(personalizationService: PersonalizationServiceProtocol = PersonalizationService.shared) {
        self.personalizationService = personalizationService
    }
}
```

### **4. Leverage View Modifiers**

```swift
// ✅ GOOD: Automatic screen tracking
struct HomeView: View {
    var body: some View {
        VStack { ... }
            .trackScreen("Home")
            .locationAware()
    }
}
```

### **5. Keep ViewModels Testable**

```swift
// ✅ GOOD: Protocol-based services enable mocking
final class MockPersonalizationService: PersonalizationServiceProtocol {
    var mockResponse: PersonalizationDecisionsResult?
    
    func fetchDecisions(...) async throws -> PersonalizationDecisionsResult {
        return mockResponse ?? .empty
    }
}
```

---

## 🐛 Debugging & Troubleshooting

### **Enable Debug Logging**

```swift
// In DEBUG builds, logging is automatic
#if DEBUG
let config = DataCloudConfiguration.development  // enableLogging: true
#endif
```

### **Check SDK Status**

```swift
// Print comprehensive SDK status
DataCloudLoggingService.shared.printSdkStatus()

// Output:
// ============================================================
// 📊 SFMC SDK Status Report
// ============================================================
// SDK State: operational
// CDP Module Status: operational
// Consent Status: optIn
// ============================================================
```

### **Common Issues**

| Issue | Solution |
|-------|----------|
| Events not appearing in Data Cloud | • Check `appId` and `endpoint` in config<br>• Verify consent is set to `optIn`<br>• Check network connectivity |
| Personalization returning empty | • Verify personalization point "Pronto" exists in Data Cloud<br>• Ensure decision records are published<br>• Check identity resolution is working |
| Identity not linking devices | • Verify email reconciliation is configured<br>• Check that `setKnownProfile()` was called<br>• Ensure web and mobile use same email |
| Location not working | • Request location permission<br>• Call `startTracking()`<br>• Check Info.plist has location usage strings |

---

## 📚 Additional Resources

### **Documentation**
- [Salesforce Data Cloud Developer Guide](https://developer.salesforce.com/docs/data)
- [Mobile SDK Integration Guide](Documentation/API/SFMC_SDK_INTEGRATION.md)
- [Personalization SDK Deep Dive](Documentation/API/PERSONALIZATION_SDK_IMPLEMENTATION.md)
- [Event Tracking Reference](Documentation/API/SALESFORCE_DATA_CLOUD_TRACKING.md)

### **Salesforce Resources**
- [Data Cloud Query API](https://developer.salesforce.com/docs/data/data-cloud-query-guide)
- [C360 Mobile SDK](https://developer.salesforce.com/docs/data/data-cloud-ref/guide/c360a-api-engagement-mobile-sdk.html)
- [Personalization Engine](https://help.salesforce.com/s/articleView?id=sf.c360_a_personalization_overview.htm)

---

## 👥 Contributing

We welcome contributions! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Follow MVVM architecture** and existing code patterns
4. **Write unit tests** for new features
5. **Update documentation** as needed
6. **Commit with meaningful messages**
7. **Push to your branch** (`git push origin feature/amazing-feature`)
8. **Open a Pull Request**

---

## 📄 License

This project is proprietary and confidential. All rights reserved.

---

## 🙏 Acknowledgments

- **Salesforce Data Cloud Team** for the powerful CDP platform
- **Salesforce Mobile SDK Team** for the robust iOS SDK
- **SwiftUI Community** for best practices and inspiration

---

## 📞 Support

For questions or issues:
- **Email**: support@pronto.com
- **Slack**: #pronto-dev-support
- **Internal Wiki**: confluence.pronto.com/ios-app

---

**Built with ❤️ by the Pronto Engineering Team**

**Last Updated:** November 2025  
**Version:** 1.0.0  
**iOS SDK Version:** Salesforce Marketing Cloud 8.0+  
**Minimum iOS:** 15.0+
