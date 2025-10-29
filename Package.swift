// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "ProntoFoodDeliveryApp",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ProntoFoodDeliveryApp",
            targets: ["ProntoFoodDeliveryApp"]
        ),
    ],
    dependencies: [
        // Salesforce Marketing Cloud SDK for Data Cloud integration
        // Documentation: https://developer.salesforce.com/docs/data/data-cloud-ref/guide/c360a-api-engagement-mobile-sdk.html
        // Note: Replace with actual SFMC SDK package when ready to integrate
        // .package(url: "https://github.com/salesforce-marketingcloud/MarketingCloudSDK-iOS.git", from: "8.0.0"),
        
        // Add other SPM dependencies here when needed
        // .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "ProntoFoodDeliveryApp",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "ProntoFoodDeliveryAppTests",
            dependencies: ["ProntoFoodDeliveryApp"],
            path: "Tests"
        ),
    ]
)
