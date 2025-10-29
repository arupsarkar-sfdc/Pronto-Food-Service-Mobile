#!/bin/bash

# iOS Pronto Food Delivery App - Project Structure Setup Script
# Run this script from the directory where you want to create your project

set -e  # Exit on any error

PROJECT_NAME="ProntoFoodDeliveryApp"
BUNDLE_ID="com.salesforce.pronto.fooddelivery.ProntoFoodDeliveryApp"

echo "🚀 Setting up iOS Food Delivery App project structure..."
echo "Project Name: $PROJECT_NAME"
echo "Bundle ID: $BUNDLE_ID"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_manual() {
    echo -e "${RED}🔧 MANUAL STEP: $1${NC}"
}

# Check if we're in the right directory
CURRENT_DIR=$(basename "$(pwd)")
if [ "$CURRENT_DIR" = "$PROJECT_NAME" ]; then
    echo "✅ Running from within the project directory: $PROJECT_NAME"
    PROJECT_ROOT="."
elif [ -d "$PROJECT_NAME" ]; then
    echo -e "${RED}❌ Directory $PROJECT_NAME already exists!${NC}"
    echo "Please remove it or choose a different location, or run from within the project directory."
    exit 1
else
    PROJECT_ROOT="$PROJECT_NAME"
fi

print_manual "Before running this script:"
print_manual "1. Open Xcode"
print_manual "2. Create a new iOS App project with:"
print_manual "   - Product Name: $PROJECT_NAME"
print_manual "   - Bundle Identifier: $BUNDLE_ID"
print_manual "   - Language: Swift"
print_manual "   - Interface: SwiftUI"
print_manual "   - Use Core Data: No (we'll add it later if needed)"
print_manual "3. Save it in the current directory: $(pwd)"
print_manual "4. Close Xcode"
print_manual "5. Run this script"
echo ""
read -p "Have you completed the manual steps above? (y/N): " confirm

if [[ $confirm != [yY] ]]; then
    echo "Please complete the manual steps first, then run this script again."
    exit 0
fi

# Verify the Xcode project exists
if [ "$PROJECT_ROOT" = "." ]; then
    # We're inside the project directory
    if [ ! -f "$PROJECT_NAME.xcodeproj/project.pbxproj" ]; then
        echo -e "${RED}❌ Xcode project file not found in current directory!${NC}"
        echo "Please make sure you're in the correct project directory."
        exit 1
    fi
else
    # We're in parent directory
    if [ ! -d "$PROJECT_NAME" ]; then
        echo -e "${RED}❌ $PROJECT_NAME directory not found!${NC}"
        echo "Please make sure you created the Xcode project in the current directory."
        exit 1
    fi
    
    if [ ! -f "$PROJECT_NAME/$PROJECT_NAME.xcodeproj/project.pbxproj" ]; then
        echo -e "${RED}❌ Xcode project file not found!${NC}"
        echo "Please make sure the Xcode project was created correctly."
        exit 1
    fi
    
    cd "$PROJECT_NAME"
fi

print_step "Creating modular project structure..."

# Create main directory structure
mkdir -p "Sources"
mkdir -p "Sources/App"
mkdir -p "Sources/Core"
mkdir -p "Sources/Features"
mkdir -p "Sources/Shared"
mkdir -p "Tests"
mkdir -p "Documentation"
mkdir -p "Scripts"
mkdir -p "Resources"

# Core module directories
print_step "Creating Core module structure..."
mkdir -p "Sources/Core/Models"
mkdir -p "Sources/Core/Services"
mkdir -p "Sources/Core/Networking"
mkdir -p "Sources/Core/Persistence"
mkdir -p "Sources/Core/Extensions"
mkdir -p "Sources/Core/Utilities"
mkdir -p "Sources/Core/Constants"

# Salesforce integration
mkdir -p "Sources/Core/Services/Salesforce"
mkdir -p "Sources/Core/Services/Salesforce/DataCloud"
mkdir -p "Sources/Core/Services/Salesforce/Personalization"
mkdir -p "Sources/Core/Services/Salesforce/Authentication"

# Feature modules
print_step "Creating Feature modules..."
mkdir -p "Sources/Features/Home"
mkdir -p "Sources/Features/Home/ViewModels"
mkdir -p "Sources/Features/Home/Views"
mkdir -p "Sources/Features/Home/Models"

mkdir -p "Sources/Features/Restaurant"
mkdir -p "Sources/Features/Restaurant/ViewModels"
mkdir -p "Sources/Features/Restaurant/Views"
mkdir -p "Sources/Features/Restaurant/Models"

mkdir -p "Sources/Features/Menu"
mkdir -p "Sources/Features/Menu/ViewModels"
mkdir -p "Sources/Features/Menu/Views"
mkdir -p "Sources/Features/Menu/Models"

mkdir -p "Sources/Features/Cart"
mkdir -p "Sources/Features/Cart/ViewModels"
mkdir -p "Sources/Features/Cart/Views"
mkdir -p "Sources/Features/Cart/Models"

mkdir -p "Sources/Features/Order"
mkdir -p "Sources/Features/Order/ViewModels"
mkdir -p "Sources/Features/Order/Views"
mkdir -p "Sources/Features/Order/Models"

mkdir -p "Sources/Features/Profile"
mkdir -p "Sources/Features/Profile/ViewModels"
mkdir -p "Sources/Features/Profile/Views"
mkdir -p "Sources/Features/Profile/Models"

mkdir -p "Sources/Features/Authentication"
mkdir -p "Sources/Features/Authentication/ViewModels"
mkdir -p "Sources/Features/Authentication/Views"
mkdir -p "Sources/Features/Authentication/Models"

mkdir -p "Sources/Features/Search"
mkdir -p "Sources/Features/Search/ViewModels"
mkdir -p "Sources/Features/Search/Views"
mkdir -p "Sources/Features/Search/Models"

mkdir -p "Sources/Features/Tracking"
mkdir -p "Sources/Features/Tracking/ViewModels"
mkdir -p "Sources/Features/Tracking/Views"
mkdir -p "Sources/Features/Tracking/Models"

# Shared components
print_step "Creating Shared components..."
mkdir -p "Sources/Shared/UI"
mkdir -p "Sources/Shared/UI/Components"
mkdir -p "Sources/Shared/UI/Modifiers"
mkdir -p "Sources/Shared/UI/Styles"
mkdir -p "Sources/Shared/UI/Theme"

mkdir -p "Sources/Shared/Protocols"
mkdir -p "Sources/Shared/Managers"
mkdir -p "Sources/Shared/Coordinators"

# Test structure
print_step "Creating test structure..."
mkdir -p "Tests/UnitTests"
mkdir -p "Tests/UnitTests/Core"
mkdir -p "Tests/UnitTests/Features"
mkdir -p "Tests/UnitTests/Shared"
mkdir -p "Tests/IntegrationTests"
mkdir -p "Tests/UITests"
mkdir -p "Tests/Mocks"
mkdir -p "Tests/TestHelpers"

# Resources
print_step "Creating resources structure..."
mkdir -p "Resources/Images"
mkdir -p "Resources/Fonts"
mkdir -p "Resources/Colors"
mkdir -p "Resources/Localizations"
mkdir -p "Resources/Configuration"

# Move existing files to new structure
print_step "Organizing existing files..."

# Move ContentView to Home feature
if [ -f "ContentView.swift" ]; then
    mv "ContentView.swift" "Sources/Features/Home/Views/"
    print_success "Moved ContentView.swift to Home feature"
fi

# Move App file to Sources/App
if [ -f "${PROJECT_NAME}App.swift" ]; then
    mv "${PROJECT_NAME}App.swift" "Sources/App/"
    print_success "Moved App file to Sources/App"
fi

# Create placeholder files to maintain structure
print_step "Creating placeholder files..."

# Core Models
cat > "Sources/Core/Models/README.md" << 'EOF'
# Core Models

This directory contains the core data models used throughout the application:

- `Restaurant.swift` - Restaurant entity model
- `MenuItem.swift` - Menu item model with customizations
- `Order.swift` - Order entity and status models
- `User.swift` - User profile and preferences
- `Cart.swift` - Shopping cart models

These models should be framework-agnostic and contain only business logic.
EOF

# Core Services
cat > "Sources/Core/Services/README.md" << 'EOF'
# Core Services

This directory contains all service layer implementations:

## Salesforce/
- `SalesforceDataCloudService.swift` - Main Salesforce integration
- `SalesforceAuthService.swift` - Authentication handling
- `PersonalizationService.swift` - Customer personalization logic

## Other Services
- `LocationService.swift` - GPS and location handling
- `NotificationService.swift` - Push notifications
- `AnalyticsService.swift` - App analytics and tracking
EOF

# Networking
cat > "Sources/Core/Networking/README.md" << 'EOF'
# Networking Layer

Contains all networking related code:

- `APIClient.swift` - Generic API client
- `Endpoints.swift` - API endpoint definitions
- `NetworkError.swift` - Error handling
- `RequestBuilder.swift` - Request construction utilities
EOF

# Create .gitkeep files for empty directories
find Sources Tests Resources -type d -empty -exec touch {}/.gitkeep \;

# Create basic configuration files
print_step "Creating configuration files..."

# SwiftLint configuration
cat > ".swiftlint.yml" << 'EOF'
# SwiftLint Configuration for Food Delivery App

excluded:
  - Carthage
  - Pods
  - .build
  - DerivedData

opt_in_rules:
  - array_init
  - attributes
  - closure_spacing
  - collection_alignment
  - contains_over_filter_count
  - contains_over_filter_is_empty
  - contains_over_first_not_nil
  - empty_collection_literal
  - empty_count
  - empty_string
  - enum_case_associated_values_count
  - fatal_error_message
  - first_where
  - flatmap_over_map_reduce
  - identical_operands
  - joined_default_parameter
  - last_where
  - literal_expression_end_indentation
  - multiline_arguments
  - multiline_function_chains
  - multiline_literal_brackets
  - multiline_parameters
  - operator_usage_whitespace
  - overridden_super_call
  - prefer_self_type_over_type_of_self
  - redundant_nil_coalescing
  - redundant_type_annotation
  - sorted_first_last
  - toggle_bool
  - unneeded_parentheses_in_closure_argument
  - vertical_parameter_alignment_on_call
  - yoda_condition

line_length:
  warning: 120
  error: 150
  ignores_comments: true
  ignores_urls: true

function_body_length:
  warning: 50
  error: 100

file_length:
  warning: 400
  error: 500

type_body_length:
  warning: 300
  error: 400

identifier_name:
  min_length: 1
  max_length: 40

disabled_rules:
  - trailing_whitespace
EOF

# Create README for the project
cat > "README.md" << EOF
# $PROJECT_NAME

A modern iOS food delivery application built with SwiftUI, MVVM architecture, and Salesforce integration.

## Architecture

This project follows a modular architecture with clear separation of concerns:

### Core Layer (\`Sources/Core/\`)
- **Models**: Business entities and data structures
- **Services**: Business logic and external integrations
- **Networking**: API communication layer
- **Persistence**: Data storage and caching
- **Utilities**: Helper functions and extensions

### Feature Layer (\`Sources/Features/\`)
Each feature is organized as a separate module with its own:
- **ViewModels**: MVVM presentation logic
- **Views**: SwiftUI user interface
- **Models**: Feature-specific data structures

### Shared Layer (\`Sources/Shared/\`)
- **UI Components**: Reusable SwiftUI components
- **Protocols**: Shared interfaces and contracts
- **Managers**: Cross-cutting concerns

## Features

- 🏠 **Home**: Restaurant discovery with personalized recommendations
- 🍕 **Menu**: Browse restaurant menus with customization options
- 🛒 **Cart**: Shopping cart with promo codes and checkout
- 📦 **Orders**: Order history and real-time tracking
- 👤 **Profile**: User preferences and account management
- 🔍 **Search**: Find restaurants and dishes
- 🔐 **Authentication**: Secure user login and registration

## Salesforce Integration

- **Data Cloud**: Customer data and analytics
- **Personalization**: AI-driven recommendations
- **Order Management**: Real-time order processing

## Getting Started

1. Open \`$PROJECT_NAME.xcodeproj\` in Xcode
2. Configure your Salesforce credentials in \`Configuration/\`
3. Build and run the project

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Project Structure

\`\`\`
$PROJECT_NAME/
├── Sources/
│   ├── App/                    # App entry point
│   ├── Core/                   # Core business logic
│   ├── Features/               # Feature modules
│   └── Shared/                 # Shared components
├── Tests/                      # Test suites
├── Resources/                  # Assets and configurations
└── Documentation/              # Project documentation
\`\`\`

## Contributing

Please read our coding standards and follow the established patterns when contributing to this project.
EOF

# Create basic Package.swift for SPM dependencies (if needed later)
cat > "Package.swift" << EOF
// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "$PROJECT_NAME",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "$PROJECT_NAME",
            targets: ["$PROJECT_NAME"]
        ),
    ],
    dependencies: [
        // Add SPM dependencies here when needed
        // .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "$PROJECT_NAME",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "${PROJECT_NAME}Tests",
            dependencies: ["$PROJECT_NAME"],
            path: "Tests"
        ),
    ]
)
EOF

# Create development scripts
print_step "Creating development scripts..."

mkdir -p "Scripts"

cat > "Scripts/setup.sh" << 'EOF'
#!/bin/bash

# Development environment setup script

echo "🔧 Setting up development environment..."

# Install SwiftLint if not installed
if ! command -v swiftlint &> /dev/null; then
    echo "Installing SwiftLint..."
    brew install swiftlint
fi

# Install SwiftFormat if not installed
if ! command -v swiftformat &> /dev/null; then
    echo "Installing SwiftFormat..."
    brew install swiftformat
fi

echo "✅ Development environment setup complete!"
EOF

cat > "Scripts/lint.sh" << 'EOF'
#!/bin/bash

# Run SwiftLint on the project

echo "🔍 Running SwiftLint..."

if command -v swiftlint &> /dev/null; then
    swiftlint
else
    echo "❌ SwiftLint not installed. Run 'Scripts/setup.sh' first."
    exit 1
fi
EOF

cat > "Scripts/format.sh" << 'EOF'
#!/bin/bash

# Format code using SwiftFormat

echo "🎨 Formatting code..."

if command -v swiftformat &> /dev/null; then
    swiftformat Sources/ Tests/ --swiftversion 5.7
    echo "✅ Code formatting complete!"
else
    echo "❌ SwiftFormat not installed. Run 'Scripts/setup.sh' first."
    exit 1
fi
EOF

# Make scripts executable
chmod +x Scripts/*.sh

# Create documentation structure
print_step "Creating documentation..."

mkdir -p "Documentation/Architecture"
mkdir -p "Documentation/API"
mkdir -p "Documentation/Setup"

cat > "Documentation/Architecture/MVVM.md" << 'EOF'
# MVVM Architecture Guide

## Overview

This application follows the Model-View-ViewModel (MVVM) architectural pattern with SwiftUI.

## Structure

### Models
- Pure data structures
- No UI dependencies
- Conform to Codable for serialization

### Views
- SwiftUI views
- Declarative UI
- Observe ViewModels via @StateObject/@ObservedObject

### ViewModels
- Business logic
- State management
- Conform to ObservableObject
- Use @Published for reactive properties

## Best Practices

1. Keep Views lightweight
2. Put business logic in ViewModels
3. Use dependency injection
4. Make ViewModels testable
EOF

cat > "Documentation/Setup/Salesforce.md" << 'EOF'
# Salesforce Integration Setup

## Prerequisites

1. Salesforce Developer Account
2. Connected App configuration
3. OAuth 2.0 credentials

## Configuration Steps

1. Create Connected App in Salesforce
2. Configure OAuth settings
3. Add credentials to app configuration
4. Test authentication flow

## Data Cloud Setup

Configure Data Cloud objects for:
- Customer profiles
- Order history
- Restaurant data
- Menu items
- Personalization preferences
EOF

# Create directory tree visualization
print_step "Creating project structure visualization..."

cat > "Documentation/PROJECT_STRUCTURE.md" << EOF
# Project Structure

\`\`\`
$PROJECT_NAME/
├── README.md
├── Package.swift
├── .swiftlint.yml
├── $PROJECT_NAME.xcodeproj/
├── Sources/
│   ├── App/
│   │   └── ${PROJECT_NAME}App.swift
│   ├── Core/
│   │   ├── Models/
│   │   ├── Services/
│   │   │   ├── Salesforce/
│   │   │   │   ├── DataCloud/
│   │   │   │   ├── Personalization/
│   │   │   │   └── Authentication/
│   │   ├── Networking/
│   │   ├── Persistence/
│   │   ├── Extensions/
│   │   ├── Utilities/
│   │   └── Constants/
│   ├── Features/
│   │   ├── Home/
│   │   ├── Restaurant/
│   │   ├── Menu/
│   │   ├── Cart/
│   │   ├── Order/
│   │   ├── Profile/
│   │   ├── Authentication/
│   │   ├── Search/
│   │   └── Tracking/
│   └── Shared/
│       ├── UI/
│       │   ├── Components/
│       │   ├── Modifiers/
│       │   ├── Styles/
│       │   └── Theme/
│       ├── Protocols/
│       ├── Managers/
│       └── Coordinators/
├── Tests/
│   ├── UnitTests/
│   ├── IntegrationTests/
│   ├── UITests/
│   ├── Mocks/
│   └── TestHelpers/
├── Resources/
│   ├── Images/
│   ├── Fonts/
│   ├── Colors/
│   ├── Localizations/
│   └── Configuration/
├── Scripts/
│   ├── setup.sh
│   ├── lint.sh
│   └── format.sh
└── Documentation/
    ├── Architecture/
    ├── API/
    └── Setup/
\`\`\`
EOF

print_success "Project structure created successfully!"
print_success "Total directories created: $(find . -type d | wc -l)"
print_success "Total files created: $(find . -type f | wc -l)"

echo ""
print_step "Next Steps:"
echo "1. 📝 Review the project structure in Xcode"
echo "2. 🔧 Run 'Scripts/setup.sh' to install development tools"
echo "3. 📋 Read 'Documentation/Setup/Salesforce.md' for integration setup"
echo "4. 🎯 Start implementing features in the 'Sources/Features/' directory"
echo ""

print_warning "Important: You'll need to manually add the new source files to your Xcode project"
print_warning "as you create them, or configure Xcode to automatically detect file system changes."

echo ""
print_success "🎉 iOS Food Delivery App project structure setup complete!"