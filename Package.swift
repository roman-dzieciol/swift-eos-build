// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftEOSBuild",
    platforms: [.macOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "swift-eos-build",
            targets: ["SwiftEOSBuild"]
        ),
        .library(
            name: "ClangAST",
            targets: ["ClangAST"]
        ),
        .library(
            name: "SwiftAST",
            targets: ["SwiftAST"]
        ),
        .library(
            name: "SwiftFromClang",
            targets: ["SwiftFromClang"]
        ),
        .library(
            name: "SwiftRefactor",
            targets: ["SwiftRefactor"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.0"),
        //.package(url: "https://github.com/apple/swift-syntax.git", .branch("release/5.5")),

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "SwiftEOSBuild",
            dependencies: [
                .target(name: "SwiftEOSBuildCore"),
                .target(name: "ClangAST"),
                .target(name: "SwiftAST"),
                .target(name: "SwiftFromClang"),
                .target(name: "SwiftRefactor"),
                .target(name: "SwiftPrinter"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
                           //,
                            //.product(name: "SwiftSyntax", package: "swift-syntax")]
        ]),
        .target(
            name: "SwiftEOSBuildCore"
        ),
        .target(
            name: "ClangAST",
            dependencies: [
                .target(name: "SwiftEOSBuildCore")
            ]
        ),
        .target(
            name: "SwiftAST",
            dependencies: [
                .target(name: "ClangAST"),
                .target(name: "SwiftEOSBuildCore")
            ]
        ),
        .target(
            name: "CTestHelpers",
            dependencies: [
            ]
        ),
        .target(
            name: "SwiftFromClang",
            dependencies: [
                .target(name: "ClangAST"),
                .target(name: "SwiftAST"),
                .target(name: "SwiftEOSBuildCore")
            ]
        ),
        .target(
            name: "SwiftRefactor",
            dependencies: [
                .target(name: "ClangAST"),
                .target(name: "SwiftAST"),
                .target(name: "SwiftEOSBuildCore")
            ]
        ),
        .target(
            name: "SwiftPrinter",
            dependencies: [
                .target(name: "ClangAST"),
                .target(name: "SwiftAST"),
                .target(name: "SwiftEOSBuildCore")
            ]
        ),
        .testTarget(
            name: "ClangASTTests",
            dependencies: ["ClangAST"]),
        .testTarget(
            name: "SwiftASTTests",
            dependencies: ["SwiftAST", "CTestHelpers"]),
        .testTarget(
            name: "SwiftFromClangTests",
            dependencies: ["SwiftFromClang"]),
        .testTarget(
            name: "SwiftRefactorTests",
            dependencies: ["SwiftRefactor"]),
        .testTarget(
            name: "SwiftPrinterTests",
            dependencies: ["SwiftPrinter", "SwiftRefactor"]),
        .testTarget(
            name: "SwiftEOSBuildTests",
            dependencies: ["SwiftEOSBuild"]),
    ]
)
