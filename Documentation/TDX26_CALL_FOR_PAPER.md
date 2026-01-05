# TDX26 Call for Paper Submission

> **Submission Type:** Breakout Session  
> **Track:** Developer / Architecture  
> **Level:** Intermediate to Advanced

---

## Session Title

**The Intelligent Channel: Real-Time Cross-Channel Personalization with Data Cloud, Personalization SDK & Agentforce**

*Building Adaptive Customer Experiences Across Web, Mobile & Conversational AI*

---

## Abstract

The promise of omni-channel personalization has long been fragmented—web knows one customer, mobile knows another, and agents start conversations from scratch. This session shatters those silos.

We'll demonstrate a fully functional food delivery application (web + iOS) where customer behavior on one channel instantly influences the experience on another. Click on Pizza three times on the website? Open the mobile app and see Pizza recommendations front-and-center. Engage with Agentforce? The agent already knows your preferences and offers a personalized 15% discount.

This isn't future-state architecture—it's working code you can build today.

**What you'll learn:**
- How to implement real-time event streaming from Web SDK and Mobile SDK into Data Cloud
- Building a unified customer profile that spans all digital touchpoints
- Fetching personalization decisions via the Personalization SDK (both low-code and pro-code approaches)
- Connecting Agentforce to the same unified profile for context-aware conversations
- The complete technical architecture enabling sub-second cross-channel personalization

Walk away with patterns, code samples, and a reference implementation for delivering the "white-glove digital experience" that modern customers expect.

---

## Agenda

1. **The Cross-Channel Personalization Problem** – Why current approaches fall short
2. **The Agentic Web Framework** – Unified architecture for adaptive experiences  
3. **Live Demo: Web → Mobile → Agentforce** – See real-time personalization in action
4. **Implementation Patterns & Code** – Payload parity, decision fetching, SDK integration
5. **Best Practices for Cross-Channel Personalization** – Lessons learned
6. **Considerations & Performance** – What to watch for at scale
7. **Q&A** – Audience questions

---

## Session Timebox (40 minutes total)

| # | Section | Duration | Type | Content |
|---|---------|----------|------|---------|
| I | **The Problem** | 5 min | Slides | Channel silos, fragmented personalization, the opportunity |
| II | **Architecture Deep Dive** | 10 min | Slides + Diagram | Unified data layer, component breakdown, technical stack |
| III | **Live Demo** | 15 min | Live Demo | Web clicks → Mobile personalization → Agentforce conversation |
| IV | **Implementation Patterns** | 10 min | Code Walkthrough | Payload parity, decision fetching, low-code vs pro-code |
| V | **Agentforce Integration** | 5 min | Slides + Code | How agent accesses unified profile, response flow |
| VI | **Takeaways & Q&A** | 5 min | Slides | Checklist, resources, audience questions |

```
┌────────────────────────────────────────────────────────────────────────────┐
│                         SESSION TIMELINE (40 min)                          │
├────────────────────────────────────────────────────────────────────────────┤
│  0    5    10   15   20   25   30   35   40                                │
│  ├────┼────┼────┼────┼────┼────┼────┼────┤                                │
│  │ I  │   II   │      III       │   IV   │V  │VI │                        │
│  │Prob│  Arch  │   LIVE DEMO    │Patterns│AF │Q&A│                        │
│  └────┴────────┴────────────────┴────────┴───┴───┘                        │
│                                                                            │
│  Legend: I=Problem, II=Architecture, III=Demo, IV=Patterns, V=Agent, VI=QA│
└────────────────────────────────────────────────────────────────────────────┘
```

---

## Session Outline

### I. The Cross-Channel Personalization Problem (5 min)

**The Gap:**
- Current "hyper-personalization" is channel-siloed
- Web analytics don't inform mobile experiences
- Chat agents lack customer journey context
- Customers feel like strangers on each touchpoint

**The Opportunity:**
- Unified Data Cloud as single source of truth
- Real-time event streaming across channels
- Personalization SDK for instant recommendations
- Agentforce with full journey awareness

---

### II. Architecture Deep Dive (10 min)

**The Unified Data Layer:**

```
┌─────────────────────────────────────────────────────────────────┐
│                        DATA CLOUD                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │   Profile    │  │  Engagement  │  │   Personalization    │  │
│  │    DMOs      │  │    Events    │  │      Decisions       │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
         ▲                   ▲                      │
         │                   │                      ▼
    ┌────┴────┐         ┌────┴────┐         ┌──────────────┐
    │ Identity │         │ Catalog │         │Personalization│
    │  Events  │         │ Events  │         │   Decisions   │
    └────┬────┘         └────┬────┘         └──────┬───────┘
         │                   │                      │
    ┌────┴───────────────────┴──────────────────────┴────┐
    │                                                     │
┌───┴───┐           ┌───────────┐           ┌────────────┴───┐
│  WEB  │           │  MOBILE   │           │   AGENTFORCE   │
│  SDK  │           │   SDK     │           │     AGENT      │
└───────┘           └───────────┘           └────────────────┘
    │                     │                         │
    ▼                     ▼                         ▼
┌───────────────────────────────────────────────────────────┐
│              PRONTO FOOD DELIVERY EXPERIENCE              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐   │
│  │   Web App   │  │  iOS App    │  │  Agentforce     │   │
│  │   (React)   │  │  (SwiftUI)  │  │  (Conversational│   │
│  └─────────────┘  └─────────────┘  └─────────────────┘   │
└───────────────────────────────────────────────────────────┘
```

**Key Technical Components:**

| Component | Technology | Purpose |
|-----------|------------|---------|
| Web SDK | Salesforce Data Cloud Web SDK | Track web engagement events |
| Mobile SDK | SFMC SDK + CDP Module | Track mobile engagement events |
| Personalization SDK | Salesforce Personalization iOS SDK | Fetch real-time decisions |
| Agentforce | SMIClientCore/SMIClientUI | Conversational AI with context |
| Data Cloud | Salesforce Data Cloud | Unified profile & event storage |

---

### III. Live Demo: The Cross-Channel Journey (15 min)

**Demo Scenario:**

**Step 1: Web Browsing Behavior**
```
User visits Pronto website → Clicks "Pizza" category 3 times → Events stream to Data Cloud
```

**Step 2: Mobile App Personalization**
```
User opens iOS app → Navigates to Favorites tab → 
PersonalizationService.fetchDecisions("Pronto") →
"🏆 Recommended for You: Pizza" appears instantly
```

**Step 3: Agentforce Context-Aware Conversation**
```
User: "What do you recommend?"
Agent: "I noticed you've shown consistent interest in our pizza selection. 
        We'd love to offer you a 15% discount on any pizza! 🍕"
```

**Code Walkthrough - Event Tracking (Mobile):**

```swift
// EngagementTrackingService.swift
EngagementTrackingService.shared.trackEvent(
    type: .catalog(.view),
    attributes: [
        "catalogObjectId": "Pizza",           // Human-readable ID
        "type": "Category",                   // Catalog object type
        "interactionName": "View Category Pizza",  // Descriptive name
        "name": "Pizza"
    ]
)
```

**Code Walkthrough - Fetching Personalization:**

```swift
// PersonalizationViewModel.swift
let result = try await personalizationService.fetchDecisions(
    personalizationPointNames: ["Pronto"],
    context: nil,
    timeoutSeconds: 10
)

// Winner selection based on engagement data
let winner = selectWinner(decisions: result.decisions, clickCounts: counts)

// Display personalized content
self.winningDecision = winner  // Shows Pizza with custom image, CTA
```

**Code Walkthrough - Agentforce Integration:**

```swift
// AgentforceView.swift
let config = UIConfiguration(
    url: configURL,           // Points to Salesforce SCRT endpoint
    conversationId: conversationID  // Persistent for session continuity
)

// Agent has access to same unified profile via Data Cloud
// Can reference engagement history in responses
```

---

### IV. Technical Implementation Patterns (10 min)

**Pattern 1: Payload Parity Across Channels**

Ensure web and mobile send identical event structures:

| Field | Web SDK | Mobile SDK |
|-------|---------|------------|
| `catalogObjectId` | "Pizza" | "Pizza" |
| `catalogObjectType` | "Category" | Mapped from `CatalogObject.type` |
| `interactionName` | "View Category Pizza" | Passed via `attributes` dictionary |
| Auto-generated | sessionId, deviceId, dateTime | Same (SDK handles) |

**Pattern 2: Real-Time Decision Fetching**

```
Mobile App Launch
       │
       ▼
┌─────────────────────────────────┐
│  PersonalizationModule          │
│  .fetchDecisions(["Pronto"])    │
└─────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────┐
│  Data Cloud Evaluates:          │
│  - Unified Profile              │
│  - Web + Mobile Engagement      │
│  - Personalization Rules        │
└─────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────┐
│  Returns Decision:              │
│  - Pizza (highest engagement)   │
│  - With image, CTA, subheader   │
└─────────────────────────────────┘
```

**Pattern 3: Low-Code vs Pro-Code Personalization**

| Approach | When to Use | Implementation |
|----------|-------------|----------------|
| **Low-Code** | Rapid deployment, marketing-owned | Native Personalization SDK container |
| **Pro-Code** | Custom UI, complex logic | `PersonalizationModule.fetchDecisions()` + custom SwiftUI |

**Pro-Code Example (Custom SwiftUI):**

```swift
// Display winning decision in custom card
if let winner = viewModel.winningDecision {
    VStack {
        Text(winner.emoji)  // 🍕
        Text(winner.name)   // "Pizza"
        
        if let ctaUrl = winner.callToActionUrl {
            Link(winner.callToActionText, destination: URL(string: ctaUrl)!)
        }
    }
}
```

---

### V. Agentforce Integration Deep Dive (5 min)

**How Agentforce Accesses Unified Profile:**

1. User initiates conversation via `SMIClientUI.Interface`
2. Agent receives `deviceId` / `memberId` from conversation context
3. Agent queries Data Cloud for engagement history
4. Agent crafts personalized response based on:
   - Product browse engagement (Pizza clicks)
   - Purchase history
   - Channel preferences

**Example Agent Response Flow:**

```
┌────────────────────────────────────────────────────────────┐
│ User: "0892eb4d9bdc2aa2" (deviceId shared with agent)      │
└────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────┐
│ Agent Queries Data Cloud:                                  │
│ SELECT ProductId, COUNT(*) FROM ProductBrowseEngagement    │
│ WHERE deviceId = '0892eb4d9bdc2aa2'                        │
│ GROUP BY ProductId ORDER BY COUNT(*) DESC                  │
└────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────┐
│ Result: Pizza = 5 clicks, Sushi = 2 clicks                 │
└────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────┐
│ Agent Response:                                            │
│ "I noticed you've shown consistent interest in our pizza   │
│  selection. We'd love to offer you a 15% discount! 🍕"     │
└────────────────────────────────────────────────────────────┘
```

---

### V-A. Best Practices for Cross-Channel Personalization

*(Included in Agentforce section timing)*

**1. Start Simple**
- Begin with one event type (catalog views) before expanding
- Validate data flows end-to-end before adding complexity

**2. Ensure Payload Parity**
- Web and Mobile SDKs should send identical event structures
- Use human-readable `catalogObjectId` values (e.g., "Pizza" not "prod_001")
- Include `interactionName` for debugging and analytics

**3. Design Clear Personalization Points**
- Name personalization points descriptively (e.g., "Pronto_Home_Hero")
- Keep decision logic simple; let Data Cloud do the heavy lifting

**4. Test Across Channels**
- Use Testing Center to validate personalization rules
- Test on real devices, not just simulators

**5. Monitor and Iterate**
- Track decision performance metrics
- A/B test personalization strategies

**6. Fail Safely**
- Always provide fallback content if personalization fails
- Handle SDK initialization delays gracefully

---

### V-B. Considerations for Production

**Performance:**
- Mobile SDK events are batched; expect slight delays
- Personalization decisions are cached; set appropriate TTL
- Consider network latency for real-time requirements

**Identity Resolution:**
- `deviceId` alone creates anonymous profiles
- Prompt users to share `memberId` for richer personalization
- Identity linking happens automatically in Data Cloud

**Agentforce Specifics:**
- Agents query Data Cloud via prompt templates (not direct SOQL)
- Response latency depends on LLM inference time
- Use ground rules to constrain agent behavior

**Scalability:**
- Data Cloud handles high event volumes natively
- Personalization SDK is optimized for mobile performance
- Monitor API limits during peak traffic

---

### VI. Key Takeaways & Next Steps (5 min)

**What Makes This Work:**

1. **Unified Identity**: Same profile across web, mobile, and agent
2. **Real-Time Events**: Sub-second streaming to Data Cloud
3. **Intelligent Decisions**: Personalization SDK evaluates engagement
4. **Agentic Intelligence**: Agentforce with full journey context

**Architecture Checklist:**

- [ ] Web SDK configured with correct dataspace
- [ ] Mobile SDK (SFMCSDK + CDP Module) initialized
- [ ] Personalization SDK integrated
- [ ] Personalization Points configured in Data Cloud
- [ ] Agentforce deployment with Data Cloud access
- [ ] Payload parity between Web and Mobile

**Resources:**

| Resource | Link |
|----------|------|
| Mobile SDK Documentation | [developer.salesforce.com](https://developer.salesforce.com/docs/data/data-cloud-engagement-mobile-sdk) |
| Personalization SDK | [developer.salesforce.com](https://developer.salesforce.com/docs/marketing/personalization/references/personalization-ios-sdk) |
| Agentforce Developer Guide | [sforce.co/tdx25-agentforce-dev-guide](https://sforce.co/tdx25-agentforce-dev-guide) |
| Reference Implementation | GitHub (Pronto Food Delivery App) |

---

## Speaker Information

| Field | Details |
|-------|---------|
| **Speaker Name** | [Your Name] |
| **Title** | [Your Title, e.g., Principal Developer Advocate] |
| **Company** | Salesforce |
| **Email** | [Your Email] |
| **LinkedIn** | [Your LinkedIn Profile] |
| **Trailblazer Profile** | [Your Trailhead Profile URL] |

### Speaker Bio (50-75 words)

[Your bio highlighting relevant experience. Example format:]

*[Name] is a [Title] at Salesforce specializing in mobile development, Data Cloud integrations, and AI-powered customer experiences. With [X] years of experience building enterprise applications, [he/she/they] has helped organizations implement cross-channel personalization strategies using Salesforce's latest technologies. [Name] is passionate about bridging the gap between theoretical architectures and practical, production-ready implementations.*

### Speaker Qualifications

- [ ] Certified Salesforce Developer
- [ ] Experience with Data Cloud implementations
- [ ] Mobile SDK development experience (iOS/Android)
- [ ] Previous TDX/Dreamforce speaker (if applicable)

---

## Session Format & Categorization

| Attribute | Value |
|-----------|-------|
| **Session Type** | Breakout Session |
| **Duration** | 40 minutes (including 5 min Q&A) |
| **Format** | Live Demo + Architecture Deep Dive |
| **Level** | Intermediate to Advanced |
| **Track** | Developer / AI & Data |
| **Products** | Data Cloud, Personalization, Agentforce, Mobile SDK |

### Target Audience

| Audience | Why This Session Matters |
|----------|-------------------------|
| **Developers** | Working code patterns for immediate implementation |
| **Architects** | Blueprint for cross-channel personalization architecture |
| **Technical Decision Makers** | Proof-of-concept for investment decisions |
| **Mobile Developers** | iOS-specific SDK integration guidance |
| **AI/ML Engineers** | Agentforce integration with real-time data |

---

## Technical Requirements

- Live demo environment with:
  - Pronto Food Delivery Web App
  - Pronto Food Delivery iOS App (Xcode Simulator or device)
  - Salesforce org with Data Cloud, Personalization, Agentforce
- Screen sharing capability
- Stable internet connection for real-time Data Cloud integration

---

## Why This Session Matters for TDX26

This session directly demonstrates the **Agentic Web Framework** vision:

1. **Decipher True Customer Intent** → Real-time engagement tracking across channels
2. **Curate the Next Best Experience** → Personalization SDK selects optimal content
3. **Unify the Experience** → Seamless handoff from web to mobile to agent

Attendees leave with:
- Working code patterns
- Architecture blueprints
- Understanding of the complete Salesforce ecosystem working together
- Confidence to implement cross-channel personalization in their own projects

---

## Demo Backup Plan

In case of live demo issues:
- Pre-recorded video walkthrough (3 minutes)
- Screenshots of key flows embedded in slides
- Code snippets in presentation as fallback

---

## Session Outcomes

Attendees will leave with:

| Outcome | Deliverable |
|---------|-------------|
| **Architecture Blueprint** | Reusable diagram for cross-channel personalization |
| **Code Patterns** | Event tracking, decision fetching, Agentforce integration |
| **Implementation Checklist** | Step-by-step guide to replicate the solution |
| **Reference App** | GitHub repository link for Pronto Food Delivery App |
| **Best Practices** | Lessons learned from production implementation |

---

## Learning Resources

> **Scan QR code or visit links to access learning resources for this demo.**

| Resource | Access |
|----------|--------|
| **Agentforce Developer Guide** | [sforce.co/tdx25-agentforce-dev-guide](https://sforce.co/tdx25-agentforce-dev-guide) |
| **Data Cloud Mobile SDK** | [developer.salesforce.com/docs/data/data-cloud-engagement-mobile-sdk](https://developer.salesforce.com/docs/data/data-cloud-engagement-mobile-sdk) |
| **Personalization SDK (iOS)** | [developer.salesforce.com/docs/marketing/personalization/references/personalization-ios-sdk](https://developer.salesforce.com/docs/marketing/personalization/references/personalization-ios-sdk) |
| **Reference Implementation** | GitHub: Pronto Food Delivery App (iOS + Web) |

---

## Why This Session Should Be Selected

### Alignment with TDX26 Themes

This session directly addresses the **Agentic Web** paradigm shift:

| TDX Theme | How This Session Addresses It |
|-----------|------------------------------|
| **Agentic AI** | Agentforce integration with real-time context awareness |
| **Customer 360** | Unified profile spanning web, mobile, and conversational AI |
| **Developer Productivity** | Working code patterns, not theoretical concepts |
| **Real-World Implementation** | Functional demo app, not slides-only presentation |

### The Three Pillars of Intelligent Curation

From the Agentic Web Framework:

1. **Decipher True Customer Intent**
   - Real-time engagement tracking across web and mobile
   - Beyond clicks: understanding browsing patterns and preferences

2. **Curate the Next Best Experience**
   - Personalization SDK dynamically selects optimal content
   - Mobile app adapts instantly to web behavior

3. **Unify the Experience**
   - Seamless handoff from web to mobile to Agentforce
   - Customer never feels like a stranger on any channel

### Differentiation from Other Sessions

| Typical Session | This Session |
|-----------------|--------------|
| Slides and architecture diagrams | **Live demo with working code** |
| Single-channel focus | **True cross-channel implementation** |
| Future-state vision | **Code you can build today** |
| Generic examples | **Real food delivery app context** |
| Theory-heavy | **Pattern-heavy with reusable code** |

---

## Speaker Commitment

- Prepared slide deck following Salesforce Brand Voice guidelines
- Live demo environment tested and stable
- Backup plans for technical issues
- Post-session resources ready for attendee access
- Available for Q&A and follow-up discussions

---

## Appendix: Key Code Files in Reference Implementation

| File | Purpose |
|------|---------|
| `EngagementTrackingService.swift` | Centralized event tracking with payload parity |
| `PersonalizationViewModel.swift` | Decision fetching and winner selection logic |
| `DataCloudService.swift` | SFMC SDK initialization and configuration |
| `AgentforceView.swift` | Messaging for In-App SDK integration |
| `FavoritesView.swift` | Displays personalization decisions with Data Graph verification |
| `HomeCategoryBarView.swift` | Category tap tracking with correct catalogObjectId |

---

*Submitted for TrailblazerDX 2026 Call for Papers*

---

> **Forward-Looking Statement:** This submission describes a reference implementation using current Salesforce technologies. Product features mentioned may evolve. Implementation details should be validated against current documentation at time of development.

