# Fix "No such module 'SFMCSDK'" Error in Xcode

## Problem
Packages show in "Package Dependencies" but Xcode says "No such module 'SFMCSDK'" and "No such module 'Cdp'"

## ✅ Step-by-Step Fix

### Step 1: Verify Packages Are Added to Target

1. In Xcode, click on your **project** (blue icon at the top of Project Navigator)
2. Select the **ProntoFoodDeliveryApp** target (not the project)
3. Go to **"General"** tab
4. Scroll down to **"Frameworks, Libraries, and Embedded Content"** section
5. Check if you see:
   - `Cdp` (from mobile-sdk-cdp-ios)
   - `SFMCSDK` (from sfmc-sdk-ios)

If they're **NOT** there:
- Click the **"+"** button
- In the dialog, you should see both modules listed
- Add both `Cdp` and `SFMCSDK`
- Set them to **"Do Not Embed"** (they're Swift packages, not frameworks)

### Step 2: Check Build Phases

1. Select the **ProntoFoodDeliveryApp** target
2. Go to **"Build Phases"** tab
3. Expand **"Link Binary With Libraries"**
4. Verify both modules are listed:
   - ✅ `Cdp`
   - ✅ `SFMCSDK`

If missing, click **"+"** and add them.

### Step 3: Clean Everything

In Xcode, run these commands in order:

1. **Product → Clean Build Folder** (or press Shift+Cmd+K)
2. Close Xcode completely (Cmd+Q)
3. Open Terminal and run:
   ```bash
   # Navigate to your project
   cd ~/Projects/Mobile/iOS/ProntoFoodDeliveryApp
   
   # Delete derived data
   rm -rf ~/Library/Developer/Xcode/DerivedData/ProntoFoodDeliveryApp-*
   
   # Reset SPM caches
   rm -rf .build
   rm -rf ~/Library/Caches/org.swift.swiftpm/
   ```
4. Open Xcode again
5. Go to **File → Packages → Reset Package Caches**
6. Go to **File → Packages → Update to Latest Package Versions**
7. **Product → Build** (Cmd+B)

### Step 4: Check Package Resolution

1. In Xcode, go to **File → Packages → Resolve Package Versions**
2. Wait for packages to resolve
3. Check if there are any errors in the **Report Navigator** (Cmd+9)

### Step 5: Verify Package Products

If modules still aren't found, check the package products:

1. In Project Navigator, expand **"Package Dependencies"**
2. Right-click on **SFMCSDK** → Show in Finder
3. In the **Package.swift** file shown, look for the products
4. Make sure the product names match your imports

### Step 6: Alternative - Remove and Re-add Packages

If nothing works:

1. Select your project in Project Navigator
2. Select the **project** (not target) 
3. Go to **"Package Dependencies"** tab
4. Select **SFMCSDK** → Click **"-"** to remove
5. Select **Cdp** → Click **"-"** to remove
6. Click **"+"** to add them back:
   - Add `https://github.com/salesforce-marketingcloud/sfmc-sdk-ios.git`
   - Add `https://github.com/salesforce-marketingcloud/mobile-sdk-cdp-ios.git`
7. Make sure to select the **ProntoFoodDeliveryApp** target when prompted

### Step 7: Check for Conflicting Frameworks

I noticed a red "Personalization" folder in your project. Remove any old framework references:

1. Select **ProntoFoodDeliveryApp** target
2. Go to **Build Phases**
3. Expand **"Link Binary With Libraries"**
4. Remove any red or invalid framework references
5. Expand **"Copy Bundle Resources"**
6. Remove any framework files that shouldn't be there

Also check **Build Settings**:
1. Search for **"Framework Search Paths"**
2. Remove any paths that point to old framework locations
3. Search for **"Import Paths"**
4. Clear any custom import paths

### Step 8: Verify Swift Version Compatibility

1. Select **ProntoFoodDeliveryApp** target
2. Go to **Build Settings**
3. Search for **"Swift Language Version"**
4. Make sure it's set to **Swift 5** or higher

### Step 9: Check Minimum Deployment Target

1. Select **ProntoFoodDeliveryApp** target
2. Go to **General** tab
3. Check **"Minimum Deployments"**
4. Make sure iOS is set to **13.0 or higher** (SFMC SDK requires iOS 13+)

## 🔍 Quick Diagnostic Commands

Run this in Terminal to check your setup:

```bash
cd ~/Projects/Mobile/iOS/ProntoFoodDeliveryApp

# Check if Package.resolved exists
ls -la Package.resolved

# Check package versions
cat Package.resolved | grep -A 3 "sfmc-sdk-ios\|mobile-sdk-cdp-ios"
```

## ✅ Expected Result

After these steps, you should be able to:
- ✅ Import both modules without errors:
  ```swift
  import Cdp
  import SFMCSDK
  ```
- ✅ Build successfully (Cmd+B)
- ✅ See no red errors in the imports

## 🆘 If Still Not Working

If you still see "No such module" errors after all these steps:

1. **Check Xcode version**: You need Xcode 14.0 or higher
   ```bash
   xcodebuild -version
   ```

2. **Check Swift version**:
   ```bash
   swift --version
   ```

3. **Try creating a new simple target**:
   - File → New → Target → App
   - Add the packages to this new target
   - Try importing there to isolate the issue

4. **Check Xcode console output**:
   - View → Navigators → Report Navigator (Cmd+9)
   - Look for detailed error messages during build

## 📝 Notes

- The module names are **case-sensitive**: `SFMCSDK` not `SFMCsdk`
- SPM packages don't use `.framework` extension in imports
- The packages must be added to BOTH the project AND the target
- Sometimes Xcode's indexing gets confused - restarting helps




