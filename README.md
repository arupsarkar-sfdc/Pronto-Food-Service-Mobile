# ProntoFoodDeliveryApp

A modern iOS food delivery application built with SwiftUI, MVVM architecture, and Salesforce integration.

## Architecture

This project follows a modular architecture with clear separation of concerns:

### Core Layer (`Sources/Core/`)
- **Models**: Business entities and data structures
- **Services**: Business logic and external integrations
- **Networking**: API communication layer
- **Persistence**: Data storage and caching
- **Utilities**: Helper functions and extensions

### Feature Layer (`Sources/Features/`)
Each feature is organized as a separate module with its own:
- **ViewModels**: MVVM presentation logic
- **Views**: SwiftUI user interface
- **Models**: Feature-specific data structures

### Shared Layer (`Sources/Shared/`)
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

1. Open `ProntoFoodDeliveryApp.xcodeproj` in Xcode
2. Configure your Salesforce credentials in `Configuration/`
3. Build and run the project

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Project Structure

```
ProntoFoodDeliveryApp/
├── Sources/
│   ├── App/                    # App entry point
│   ├── Core/                   # Core business logic
│   ├── Features/               # Feature modules
│   └── Shared/                 # Shared components
├── Tests/                      # Test suites
├── Resources/                  # Assets and configurations
└── Documentation/              # Project documentation
```

## Contributing

Please read our coding standards and follow the established patterns when contributing to this project.
