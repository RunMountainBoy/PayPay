// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PayPay",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "PayPay",
            targets: ["Domain", "Application", "Infrastructure"]
        ),
    ],
    targets: [
        .target(
            name: "Domain",
            path: "Sources/Domain"
        ),
        .target(
            name: "Application",
            dependencies: ["Domain"],
            path: "Sources/Application"
        ),
        .target(
            name: "Infrastructure",
            dependencies: ["Application"],
            path: "Sources/Infrastructure",
            exclude: [
                "App", // Exclude ExpensesApp.swift, Info.plist
                "Adapters/In/SwiftUI" // Exclude all SwiftUI views and viewmodels
            ]
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: ["Domain", "Application", "Infrastructure"],
            path: "Tests"
        ),
    ]
)
