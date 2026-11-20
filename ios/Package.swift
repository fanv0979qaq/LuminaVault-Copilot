import PackageDescription

let package = Package(
    name: "LuminaVault",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "LuminaVault", targets: ["LuminaVault"])
    ],
    targets: [
        .target(name: "LuminaVault", dependencies: [])
    ]
)
