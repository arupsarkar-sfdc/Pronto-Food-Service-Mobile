# Identity Modal - Usage Guide

## Overview

The Identity Modal is a comprehensive SwiftUI form that collects user information and transitions them from **anonymous** (isAnonymous = "1") to **known** (isAnonymous = "0") profiles in Salesforce Data Cloud.

**Status**: ✅ **Complete & Ready to Use**

---

## Components Created

### 1. IdentityFormViewModel
**File**: `Sources/Features/Profile/ViewModels/IdentityFormViewModel.swift`

**Purpose**: Manages form state, validation, and triggers identity events

**Key Features**:
- Form validation (email regex, required fields)
- Integration with ProfileDataService
- Automatic contact information updates
- Debug logging
- Error handling

### 2. IdentityFormView
**File**: `Sources/Features/Profile/Views/IdentityFormView.swift`

**Purpose**: Beautiful SwiftUI modal with required and optional sections

**Key Features**:
- Required section: First Name, Last Name, Email
- Optional section: Phone, Address, City, State, Postal Code, Country
- Real-time validation
- Submit button with loading state
- Auto-dismiss on success

### 3. ProfileView (Example)
**File**: `Sources/Features/Profile/Views/ProfileView.swift`

**Purpose**: Example implementation showing how to trigger the modal

### 4. LocationPermissionView
**File**: `Sources/Features/Profile/Views/LocationPermissionView.swift`

**Purpose**: Manage location permissions and tracking

---

## How It Works

### Identity Event Flow

```
User Opens Modal
    ↓
Fills Required Fields:
  - First Name
  - Last Name
  - Email (validated)
    ↓
[Optional] Fills Contact Info:
  - Phone
  - Address (Line, City, State, Postal, Country)
    ↓
Clicks "Submit" Button
    ↓
IdentityFormViewModel.submitIdentity() called
    ↓
ProfileDataService.setKnownProfile(firstName, lastName, email)
    ├─> CdpModule.setProfileToKnown()  ← isAnonymous = "0"
    ├─> SFMCSdk.identity.setProfileAttributes()
    └─> captureDeviceInformation()
    ↓
[If optional fields filled]
ProfileDataService.updateContactInformation(phone, address)
    ↓
Modal Dismisses
    ↓
✅ User is now KNOWN (isAnonymous = "0")
    ↓
All future events include identity attributes!
```

---

## Usage Examples

### Basic Usage - Trigger Modal from Any View

```swift
import SwiftUI

struct MyView: View {
    @State private var showingIdentityModal = false
    
    var body: some View {
        VStack {
            Button("Share Your Information") {
                showingIdentityModal = true
            }
        }
        .sheet(isPresented: $showingIdentityModal) {
            IdentityFormView()
        }
    }
}
```

### Usage with Profile Status Check

```swift
import SwiftUI

struct HomeView: View {
    @ObservedObject var profileService = ProfileDataService.shared
    @State private var showingIdentityModal = false
    
    var body: some View {
        VStack {
            if profileService.isKnownUser {
                Text("Welcome back! 👋")
            } else {
                VStack {
                    Text("Get Personalized Recommendations")
                    Button("Share Your Info") {
                        showingIdentityModal = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingIdentityModal) {
            IdentityFormView()
        }
    }
}
```

### Usage in Navigation Flow

```swift
struct ProfileView: View {
    @State private var showingIdentityModal = false
    
    var body: some View {
        NavigationView {
            List {
                Button("Update Your Information") {
                    showingIdentityModal = true
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingIdentityModal) {
                IdentityFormView()
            }
        }
    }
}
```

---

## Event Data Structure

### What Gets Sent to Data Cloud

#### 1. Identity Event (Required Fields)

```json
{
  "event_type": "IdentityChange",
  "profile_state": "known",
  "isAnonymous": "0",  ← USER IS NOW KNOWN
  "attributes": {
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@example.com"
  }
}
```

#### 2. Device Information Event (Automatic)

```json
{
  "event_type": "ProfileAttributeUpdate",
  "attributes": {
    "deviceType": "iPhone",
    "softwareApplicationName": "Pronto Food Delivery",
    "osVersion": "17.0",
    "appVersion": "1.0",
    "advertiserId": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
  }
}
```

#### 3. Contact Information Event (If Provided)

```json
{
  "event_type": "ProfileAttributeUpdate",
  "attributes": {
    "phoneNumber": "+1-555-123-4567",
    "addressLine1": "123 Main Street",
    "city": "San Francisco",
    "stateProvince": "CA",
    "postalCode": "94105",
    "country": "USA"
  }
}
```

---

## Form Validation

### Required Fields

| Field | Validation | Error Message |
|-------|------------|---------------|
| First Name | Not empty | "Please fill in all required fields" |
| Last Name | Not empty | "Please fill in all required fields" |
| Email | Valid email format | "Please fill in valid email" |

### Email Validation Regex

```swift
"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
```

**Valid emails**:
- john.doe@example.com ✅
- user+tag@domain.co.uk ✅
- name_123@test-domain.org ✅

**Invalid emails**:
- notanemail ❌
- @domain.com ❌
- user@.com ❌

### Optional Fields

All optional fields accept any text input:
- Phone (suggests format: +1 (555) 123-4567)
- Address Line
- City
- State
- Postal Code
- Country

---

## UI Features

### Header Section
- Person icon (60pt)
- Title: "Help Us Personalize Your Experience"
- Subtitle explaining benefits

### Required Information Section
- White background with shadow
- Three text fields:
  - First Name (capitalized, given name content type)
  - Last Name (capitalized, family name content type)
  - Email (lowercase, email keyboard, email content type)

### Optional Information Section
- Light gray background
- Expandable address fields
- Phone with phone pad keyboard
- Address fields with appropriate content types
- State/Postal Code in horizontal split layout

### Submit Button
- Full-width blue button
- **Enabled only when form is valid**
- Shows loading spinner when submitting
- Disabled during submission
- Auto-dismisses modal on success

### Navigation Bar
- "Your Information" title
- "Cancel" button (leading)

---

## ViewModel Methods

### submitIdentity()

```swift
func submitIdentity()
```

**What it does**:
1. Validates form (required fields, email format)
2. Cleans/trims input strings
3. Calls `ProfileDataService.setKnownProfile()`
4. Updates contact information if optional fields provided
5. Sets `isSubmitted = true` → triggers modal dismiss
6. Logs all actions for debugging

**When to call**: Automatically called by Submit button

### resetForm()

```swift
func resetForm()
```

**What it does**:
- Clears all form fields
- Resets submission state
- Resets error state

**When to call**: If you want to programmatically reset the form

---

## Observing Identity Changes

### Listen for Profile State Changes

```swift
import Combine

class MyViewModel: ObservableObject {
    @Published var isKnownUser: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Observe profile service
        ProfileDataService.shared.$isKnownUser
            .sink { [weak self] isKnown in
                self?.isKnownUser = isKnown
                if isKnown {
                    print("User became a known profile!")
                }
            }
            .store(in: &cancellables)
    }
}
```

### Listen for Notification

```swift
NotificationCenter.default.addObserver(
    forName: .profileStateChanged,
    object: nil,
    queue: .main
) { notification in
    if let state = notification.userInfo?["state"] as? ProfileState {
        if state == .known {
            print("User is now known (isAnonymous = 0)")
        }
    }
}
```

---

## Console Logging

When the form is submitted, you'll see:

```
🐛 DEBUG: Submitting identity form
🐛 DEBUG:   First Name: John
🐛 DEBUG:   Last Name: Doe
🐛 DEBUG:   Email: john.doe@example.com

👤 ProfileDataService: Profile set to KNOWN
   First Name: John
   Last Name: Doe
   Email: john.doe@example.com
   ✅ Profile attributes sent to Data Cloud

📱 ProfileDataService: Device information captured
   Device Type: iPhone
   App Name: Pronto Food Delivery
   OS Version: 17.0
   App Version: 1.0

🐛 DEBUG: Contact information updated
🐛 DEBUG:   Phone: +1-555-123-4567
🐛 DEBUG:   Address: 123 Main St, San Francisco, CA 94105

✅ Identity form submitted successfully
🐛 DEBUG:   User is now a KNOWN profile (isAnonymous = 0)
```

---

## Best Practices

### 1. Show Modal at Strategic Points

**Good times to show the modal**:
- ✅ After user adds item to cart
- ✅ Before checkout
- ✅ After user favorites multiple items
- ✅ On profile/settings screen
- ✅ After app usage threshold (e.g., 5 screen views)

**Avoid showing**:
- ❌ Immediately on app launch
- ❌ During active browsing
- ❌ Multiple times in same session

### 2. Incentivize Sharing

```swift
VStack {
    Text("🎁 Get 10% off your first order!")
        .font(.headline)
    
    Button("Claim Your Discount") {
        showingIdentityModal = true
    }
}
```

### 3. Check Before Showing

```swift
// Don't show if user is already known
if !ProfileDataService.shared.isKnownUser {
    showingIdentityModal = true
}
```

### 4. Respect User Consent

```swift
// Only collect if user has opted in
if ConsentService.shared.isOptedIn() {
    showingIdentityModal = true
}
```

---

## Testing

### Test Cases

1. **Valid Submission**
   - Fill all required fields correctly
   - Click Submit
   - ✅ Modal should dismiss
   - ✅ User should become known

2. **Invalid Email**
   - Enter "notanemail"
   - ✅ Submit button should be disabled

3. **Empty Required Fields**
   - Leave first name empty
   - ✅ Submit button should be disabled

4. **Optional Fields**
   - Fill only required fields
   - Click Submit
   - ✅ Should work without optional fields

5. **Complete Form**
   - Fill all fields (required + optional)
   - Click Submit
   - ✅ Both identity and contact events should fire

---

## Customization

### Change Colors

```swift
// In IdentityFormView.swift

// Submit button color
.background(viewModel.isFormValid ? Color.blue : Color.gray)

// Change to your brand color
.background(viewModel.isFormValid ? Color("BrandColor") : Color.gray)
```

### Change Header Icon

```swift
// Current icon
Image(systemName: "person.circle.fill")

// Alternative icons
Image(systemName: "person.badge.plus")
Image(systemName: "person.crop.circle.badge.checkmark")
Image(systemName: "star.circle.fill")
```

### Add Custom Fields

```swift
// Add a custom field in the optional section
VStack(alignment: .leading, spacing: 4) {
    Text("Company Name")
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(.secondary)
    
    TextField("Acme Inc.", text: $viewModel.companyName)
        .textFieldStyle(.roundedBorder)
}
```

---

## Integration Checklist

- [x] IdentityFormViewModel created
- [x] IdentityFormView created
- [x] ProfileDataService integration
- [x] Form validation implemented
- [x] Optional fields handling
- [x] Auto-dismiss on success
- [x] Debug logging
- [x] Error handling
- [x] Example ProfileView created
- [x] LocationPermissionView created
- [x] Documentation complete

---

## Summary

✅ **Identity Modal is ready to use!**

**What it does**:
1. Collects user information (required + optional)
2. Validates input (email format, required fields)
3. Transitions user from anonymous to known (isAnonymous = "0")
4. Sends identity attributes to Salesforce Data Cloud
5. Captures device information
6. Updates contact information
7. Auto-dismisses on success
8. Provides debug logging

**To use it**:
```swift
@State private var showingIdentityModal = false

Button("Share Your Info") {
    showingIdentityModal = true
}
.sheet(isPresented: $showingIdentityModal) {
    IdentityFormView()
}
```

**Result**: User becomes a **KNOWN profile** (isAnonymous = "0") and all future events include their identity attributes! 🎉

---

**Implementation Date**: October 27, 2025  
**Status**: ✅ Complete  
**Files Created**: 4 (ViewModel, View, ProfileView, LocationPermissionView)

---

**End of Documentation**

