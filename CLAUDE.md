# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Pronto** is a modern iOS food delivery app built with SwiftUI that demonstrates **Salesforce Data Cloud** integration with AI-powered personalization. The app showcases real-time cross-channel identity resolution and Pro Code Personalization, enabling personalized experiences based on unified user behavior across web and mobile.

### Key Technologies
- **SwiftUI + MVVM**: Declarative UI with clean separation of concerns
- **Swift 5.7+, iOS 15.0+**: Modern concurrency (async/await)
- **Salesforce Data Cloud SDK**: Customer Data Platform integration via local XCFrameworks
- **Pro Code Personalization**: Server-side decision evaluation for dynamic content
- **SwiftData**: Local persistence

## Build and Development Commands

### Building the Project
```bash
# Open in Xcode (recommended - SPM dependencies auto-resolve)
open ProntoFoodDeliveryApp.xcodeproj

# Build from command line (requires full Xcode installation, not just CLI tools)
xcodebuild -project ProntoFoodDeliveryApp.xcodeproj \
           -scheme ProntoFoodDeliveryApp \
           -configuration Debug \
           -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### Development Tools Setup
```bash
# Install SwiftLint and SwiftFormat
./Scripts/setup.sh

# Run linter
./Scripts/lint.sh
# Or directly: swiftlint

# Format code
./Scripts/format.sh
```

### Testing
The project uses Xcode's native test runner. Tests are located in:
- `Tests/UnitTests/` - Logic tests
- `ProntoFoodDeliveryAppTests/` - Integration tests
- `ProntoFoodDeliveryAppUITests/` - UI tests

Run tests in Xcode: `⌘ + U`

## Architecture Overview

### MVVM Pattern
The codebase follows **Model-View-ViewModel** architecture:

```
View (SwiftUI) 
  ↓ observes @Published properties
ViewModel (ObservableObject)
  ↓ uses services
Service Layer (Business Logic)
  ↓ communicates with
Salesforce Data Cloud
```

### Directory Structure

**Sources/App/** - App entry point
- `ProntoFoodDeliveryAppApp.swift` - SwiftUI app entry, SDK initialization, credential management

**Sources/Core/** - Shared business logic and services
- **Services/Salesforce/DataCloud/** - Event tracking, identity management
  - `DataCloudService.swift` - Main SDK wrapper
  - `EngagementTrackingService.swift` - Cart, catalog, favorites, order events
  - `ProfileDataService.swift` - Anonymous → Known user transitions
  - `ConsentService.swift` - GDPR-compliant opt-in/opt-out
  - `DataGraphQueryService.swift` - Real-time unified profile queries
  - `LocationTrackingService.swift` - GPS tracking with permissions
  - `DataCloudConfiguration.swift` - SDK config (appId, endpoint stored via CredentialsManager)
- **Services/Salesforce/Personalization/**
  - `PersonalizationService.swift` - Pro Code SDK for server-side decision evaluation
- **Models/** - Business entities (Product, PersonalizationDecisionRecord, etc.)
- **Networking/** - API layer
- **Persistence/** - Local storage
- **Utilities/** - Helpers

**Sources/Features/** - Feature modules (MVVM)
- Each feature has `Views/`, `ViewModels/`, and optionally `Models/`
- Features: Home, Profile, Cart, Order, Search, Restaurant, Menu, Chat, Authentication, Tracking

**Sources/Shared/** - Reusable components
- **UI/Components/** - Reusable SwiftUI views
- **UI/Modifiers/** - Custom view modifiers (e.g., `.trackScreen()`, `.locationAware()`)
- **Protocols/** - Shared interfaces
- **Coordinators/** - Navigation coordination
- **Managers/** - Cross-cutting concerns

**Frameworks/** - Salesforce SDK XCFrameworks
- `Cdp.xcframework` (3.0.1) - Data Cloud Platform module
- `Personalization.xcframework` (2.0.0) - Pro Code personalization
- `SFMCSDK.xcframework` (4.0.1) - Marketing Cloud SDK core

These are **local XCFrameworks** (not SPM), manually integrated. See `Documentation/API/SFMC_SDK_INTEGRATION.md` for integration details.

## Salesforce Data Cloud Integration

### SDK Configuration Flow
1. **App Launch** (`ProntoFoodDeliveryAppApp.swift`):
   - Checks if credentials configured via `DataCloudConfiguration.isConfigured`
   - Retrieves `appId` and `endpoint` from `CredentialsManager` (UserDefaults-based storage)
   - Configures `DataCloudService.shared.configure(with:)`
   - Listens for `CredentialsUpdated` notification to reconfigure SDK dynamically

2. **Credentials Management**:
   - Users configure credentials via Profile → Settings UI
   - Stored in `CredentialsManager.shared` (UserDefaults)
   - If not configured, app shows setup prompt in Profile view

### Identity Resolution Pattern
```swift
// Anonymous user (app launch)
ProfileDataService.shared.setAnonymousProfile()

// User signs up/logs in
ProfileDataService.shared.setKnownProfile(
    firstName: "Leander",
    lastName: "Paes", 
    email: "leander.paes@example.com"
)
// → All past anonymous events auto-linked to known user via Unified Individual
```

### Event Tracking Pattern
All event tracking goes through `EngagementTrackingService`:

```swift
// Add to cart
engagementService.trackAddToCart(
    productId: "pizza-123",
    productName: "Margherita Pizza",
    quantity: 1,
    price: 11.88,
    currency: "USD"
)

// Browse product
engagementService.trackCatalogView(
    productId: "sushi-456",
    productName: "Sushi Roll",
    category: "Japanese"
)
```

Services automatically:
- Check consent status (`ConsentService`)
- Attach device ID, session ID, timestamp
- Include location if enabled (`LocationTrackingService`)
- Stream events to Data Cloud in real-time

### Pro Code Personalization Pattern
**Key Insight**: The SDK evaluates rules **server-side** in Data Cloud and returns the optimal decision. No client-side scoring logic needed.

```swift
// Fetch decisions from SDK
let result = try await PersonalizationService.shared.fetchDecisions(
    personalizationPointNames: ["Pronto"]
)

// Parse decision records
let decisions = parseAllDecisionRecords(from: result)

// Query user engagement from Data Graph API
let clickCounts = try await DataGraphQueryService.shared.queryDataGraph(
    dataGraphName: "C360_Contact_RT",
    dmoName: "UnifiedLinkssotIndividualI1__dlm",
    fieldName: "UnifiedRecordId__c",
    value: "9ea2aa85ce5b5a1e15498c204306aa76"
)

// Select winner based on click counts
let winner = selectWinner(decisions: decisions, clickCounts: clickCounts)
```

See `PersonalizationViewModel` in `Sources/Features/Profile/ViewModels/` for full implementation.

### Data Graph API Queries
Direct access to unified customer profiles:

```swift
let result = try await DataGraphQueryService.shared.queryDataGraph(
    dataGraphName: "C360_Contact_RT",          // Data graph name in Data Cloud
    dmoName: "UnifiedLinkssotIndividualI1__dlm", // Data model object
    fieldName: "UnifiedRecordId__c",            // Field to query
    value: "user-unified-id"                    // Unified Individual ID
)
```

Returns JSON with user behavior, engagement events, and profile data. Requires JWT token from `TokenService`.

## SwiftUI View Modifiers

The app provides custom modifiers for automatic tracking:

```swift
struct MyView: View {
    var body: some View {
        VStack {
            // Content
        }
        .trackScreen("MyScreen")        // Automatic screen tracking
        .locationAware()                 // Automatic location updates
    }
}
```

These modifiers handle consent checks and SDK calls automatically.

## Code Style and Conventions

### SwiftLint Configuration
- Line length: 120 chars (warning), 150 chars (error)
- Function body: 50 lines (warning), 100 lines (error)
- File length: 400 lines (warning), 500 lines (error)
- See `.swiftlint.yml` for full rules

### Naming Conventions
- **ViewModels**: Suffix with `ViewModel` (e.g., `HomeViewModel`)
- **Services**: Suffix with `Service` (e.g., `PersonalizationService`)
- **Protocols**: Suffix with `Protocol` for service protocols (e.g., `PersonalizationServiceProtocol`)
- **Views**: Descriptive names (e.g., `HomeBestSellersSection`)

### Dependency Injection
Always inject services via protocols for testability:

```swift
final class MyViewModel: ObservableObject {
    private let personalizationService: PersonalizationServiceProtocol
    
    init(personalizationService: PersonalizationServiceProtocol = PersonalizationService.shared) {
        self.personalizationService = personalizationService
    }
}
```

## Important Implementation Details

### Frameworks Architecture
- **XCFrameworks** (not SPM): The Salesforce SDKs are manually integrated as XCFrameworks in `Frameworks/` directory
- These support both simulator and device architectures
- Previous attempt with `.framework` files failed due to missing simulator slices
- Do NOT attempt to add via SPM - the app uses local XCFrameworks

### Credentials Management
- Credentials (appId, endpoint) are **NOT hardcoded**
- Managed via `CredentialsManager` (UserDefaults-based)
- Users configure via Profile → Settings UI
- SDK reconfigures dynamically when credentials updated via `CredentialsUpdated` notification

### Consent and Privacy
- All event tracking respects consent status via `ConsentService`
- Default is `optOut` - users must explicitly opt in
- Services automatically check consent before tracking events
- Never bypass consent checks by calling SDK directly

### Location Tracking
- Requires explicit user permission via `LocationTrackingService`
- Location expires after configurable interval (default 60s)
- Auto-requests permissions when tracking starts
- Location automatically attached to events if enabled

### Authentication Flow
- App starts with anonymous profile (`ProfileDataService.setAnonymousProfile()`)
- On login/signup, call `setKnownProfile()` to link anonymous history to known user
- Identity resolution happens automatically in Data Cloud via Unified Individual
- Always transition anonymous → known, never skip anonymous phase

## Common Development Tasks

### Adding a New Feature
1. Create feature directory under `Sources/Features/NewFeature/`
2. Add subdirectories: `Views/`, `ViewModels/`, `Models/` (if needed)
3. Create ViewModel conforming to `ObservableObject`
4. Inject services via protocol-based DI
5. Use `.trackScreen()` modifier on main view
6. Add navigation in `ContentView` or via Coordinator

### Adding Event Tracking
1. Use existing methods in `EngagementTrackingService` if applicable
2. If new event type needed:
   - Add method to `EngagementTrackingService`
   - Check consent via `ConsentService.shared.status`
   - Build event with `DataCloudEvent.Builder`
   - Call `DataCloudService.shared.track(event:)`

### Debugging Data Cloud Integration
```swift
// Enable debug logging (already enabled in Debug builds)
// Check Xcode console for SDK status

// Print comprehensive SDK status
DataCloudLoggingService.shared.printSdkStatus()

// Output shows:
// - SDK state (operational/not configured)
// - CDP module status
// - Consent status
// - Configuration details
```

### Testing Personalization
1. Ensure credentials configured in Profile → Settings
2. Create personalization point "Pronto" in Data Cloud
3. Add decision records with attributes: `Header`, `BackgroundImageUrl`, `CallToActionText`, `CallToActionUrl`
4. Generate engagement events (click products on web or mobile)
5. Call `PersonalizationService.shared.fetchDecisions()`
6. Verify winning decision matches click data

## Git Workflow

- **Main branch**: `main`
- **Current branch**: `cnx2026` (feature branch)
- Recent commits focus on replacing SPM frameworks with local XCFrameworks
- Follow conventional commits format
- Test on both simulator and device before committing

## Additional Documentation

Detailed documentation in `Documentation/`:
- `API/SFMC_SDK_INTEGRATION.md` - SDK setup and troubleshooting
- `API/SALESFORCE_DATA_CLOUD_TRACKING.md` - Event tracking reference
- `API/PERSONALIZATION_SDK_IMPLEMENTATION.md` - Pro Code personalization deep dive
- `API/IDENTITY_MODAL_USAGE.md` - Identity resolution guide
- `Architecture/MVVM.md` - Architecture patterns
- `Setup/Salesforce.md` - Salesforce Data Cloud setup

## Known Issues and Considerations

1. **XCFrameworks Required**: Do not attempt to replace with SPM - local XCFrameworks are intentional
2. **Simulator Testing**: XCFrameworks support both simulator and device (unlike previous `.framework` files)
3. **Credentials Setup**: First-time users must configure credentials via Profile → Settings
4. **Location Permissions**: Location tracking requires explicit runtime permission
5. **Consent Default**: Default consent is `optOut` - test flows must handle this
