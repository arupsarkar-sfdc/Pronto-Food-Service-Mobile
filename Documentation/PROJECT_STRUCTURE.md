# Project Structure

```
ProntoFoodDeliveryApp/
├── README.md
├── Package.swift
├── .swiftlint.yml
├── ProntoFoodDeliveryApp.xcodeproj/
├── Sources/
│   ├── App/
│   │   └── ProntoFoodDeliveryAppApp.swift
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
```
