// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "A Principal Engineer",
    products: [
        .executable(
            name: "aPrincipalEngineer",
            targets: ["aPrincipalEngineer"]
        )
    ],
    dependencies: [
        .package(name: "Publish", url: "https://github.com/johnsundell/publish.git", from: "0.7.0")
    ],
    targets: [
        .target(
            name: "aPrincipalEngineer",
            dependencies: ["Publish"]
        )
    ]
)
