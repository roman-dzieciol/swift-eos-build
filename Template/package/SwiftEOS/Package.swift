// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftEOS",
    platforms: [.macOS(.v11), .iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftEOS",
            targets: ["SwiftEOS"]),
        .library(
            name: "SwiftEOSWithTestableSDK",
            targets: ["SwiftEOSWithTestableSDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "TestableEOSSDK", path: "../swift-eos-test")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftEOS",
            dependencies: ["EOSSDK"],
            path: "Sources/SwiftEOS"
        ),
        .target(
            name: "SwiftEOSWithTestableSDK",
            dependencies: [.product(name: "EOSSDK", package: "TestableEOSSDK")],
            path: "SourcesLink/SwiftEOS"
        ),
        .binaryTarget(
            name: "EOSSDK",
            url: "https://github.com/roman-dzieciol/swift-eos-build/releases/download/0.0.1/EOSSDK.xcframework.zip",
            checksum: "e04ced44f462d39819ae23d38780aa4d312ad378c601ffd1e6a88f1db3c26aae"
        ),
        .testTarget(
            name: "SwiftEOSTests",
            dependencies: ["SwiftEOS"]
        ),
        .testTarget(
            name: "SwiftEOSWithTestableSDKTests",
            dependencies: ["SwiftEOSWithTestableSDK"]
        ),
    ]
)
