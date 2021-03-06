
import Foundation
import ArgumentParser
import ClangAST
import CTestableImpl
import SwiftAST
import SwiftFromClang
import SwiftRefactor
import SwiftPrinter
import os.log

extension Logger {
    public static let main = Logger(subsystem: "dev.roman.eos", category: "Main")
}

private struct Defaults {

    static let repositoryRootURL = URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()

    static let versionStringURL = repositoryRootURL
        .appendingPathComponent("eos-version.txt")

    static func version() throws -> String {
        try String(contentsOf: Defaults.versionStringURL).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func versionOutputURL(version: String? = nil) throws -> URL {
        try repositoryRootURL
            .appendingPathComponent("Temp")
            .appendingPathComponent(version ?? Defaults.version())
    }

    static func astURL(version: String? = nil) throws -> URL {
        try versionOutputURL().appendingPathComponent("AST/EOSSDK.ast.json")
    }

    static func bindingsURL(version: String? = nil) throws -> URL {
        try versionOutputURL().appendingPathComponent("Bindings/SwiftEOS")
    }

    static func templateURL() -> URL {
        repositoryRootURL.appendingPathComponent("Template")
    }

    static func packageTemplatesURL() -> URL {
        templateURL().appendingPathComponent("package")
    }

    static func packageSourceURL() -> URL {
        packageTemplatesURL().appendingPathComponent("SwiftEOS")
    }

    static func packageTargetURL(bindingsURL: URL) -> URL {
        bindingsURL
    }

    static func sourceOfHandwrittenCodeURL() -> URL {
        repositoryRootURL.appendingPathComponent("Sources/SwiftRefactor/EOSSDK/Public")
    }

    static func bindingsHandwrittenCodeURL(bindingsURL: URL) -> URL {
        packageTargetURL(bindingsURL: bindingsURL).appendingPathComponent("Sources/SwiftEOS/Shims")
    }

    static func bindingsGeneratedCodeURL(bindingsURL: URL) -> URL {
        packageTargetURL(bindingsURL: bindingsURL).appendingPathComponent("Sources/SwiftEOS/SDK")
    }

    static func bindingsGeneratedTestsURL(bindingsURL: URL) -> URL {
        packageTargetURL(bindingsURL: bindingsURL).appendingPathComponent("Tests/SwiftEOSTests/SDK")
    }

    static func bindingsGeneratedSdkTestsURL(bindingsURL: URL) -> URL {
        packageTargetURL(bindingsURL: bindingsURL).appendingPathComponent("Tests/SwiftEOSWithTestableSDKTests/SDK")
    }

    static func sdkSourceURL() throws -> URL {
        try versionOutputURL().appendingPathComponent("EOSSDK.xcframework")
    }

    static func testableSdkURL() throws -> URL {
        try versionOutputURL().appendingPathComponent("TestableEOSSDK")
    }

    static func testableSdkHeaderURL() throws -> URL {
        try testableSdkURL().appendingPathComponent("Sources/TestableEOSSDK/include")
    }

    static func testableSdkImplURL() throws -> URL {
        try testableSdkURL().appendingPathComponent("Sources/TestableEOSSDK")
    }

    static func apiNotesURLs() throws -> [URL] {
        [
            try sdkSourceURL().appendingPathComponent("ios-arm64/EOSSDK.framework/Headers/EOSSDK.apinotes"),
            try sdkSourceURL().appendingPathComponent("macos-x86_64/EOSSDK.framework/Headers/EOSSDK.apinotes"),
        ]
    }

    static func swiftModuleImports() -> [String] { [
        "import Foundation",
        "import EOSSDK",
        ] }

    static func swiftTestModuleImports() -> [String] { [
        "import XCTest",
        "import EOSSDK",
        "@testable import SwiftEOS",
    ] }

    static func swiftSdkTestModuleImports() -> [String] { [
        "import XCTest",
        "import EOSSDK",
        "@testable import SwiftEOSWithTestableSDK",
    ] }

}

struct SwiftEOSBuild: ParsableCommand {

    @Option var astPath: String?
    @Option var bindingsPath: String?
    @Flag var allowDelete: Bool = false
    @Flag(inversion: .prefixedNo) var emitPackage: Bool = true
    @Flag(inversion: .prefixedNo) var emitSourcesSymlink: Bool = true
    @Flag(inversion: .prefixedNo) var emitTestableSdk: Bool = true

    mutating func run() throws {

        let astURL = try astPath.map { URL(fileURLWithPath: $0) } ?? Defaults.astURL()
        let bindingsURL = try bindingsPath.map { URL(fileURLWithPath: $0) } ?? Defaults.bindingsURL()

        guard FileManager.default.fileExists(atPath: astURL.path) else {
            throw ValidationError("Input not found: \(astURL.path)")
        }

        try SwiftEOSBuildImpl(
            astURL: astURL,
            bindingsURL: bindingsURL,
            allowDelete: allowDelete,
            emitPackage: emitPackage,
            emitSourcesSymlink: emitSourcesSymlink,
            emitTestableSdk: emitTestableSdk
        ).main()
    }
}

class SwiftEOSBuildImpl {

    let logger = Logger.main
    let allowDelete: Bool
    let emitPackage: Bool
    let emitSourcesSymlink: Bool
    let emitTestableSdk: Bool
    let astURL: URL
    let bindingsURL: URL
    let handwrittenCodeSourceURL: URL
    let handwrittenCodeTargetURL: URL
    let swiftModuleOutputURL: URL
    let swiftTestsModuleOutputURL: URL
    let swiftSdkTestsModuleOutputURL: URL
    let packageSourceURL: URL
    let packageTargetURL: URL
    let testableSdkHeaderURL: URL
    let testableSdkImplURL: URL
    let apiNotesURLs: [URL]

    init(astURL: URL, bindingsURL: URL, allowDelete: Bool, emitPackage: Bool, emitSourcesSymlink: Bool, emitTestableSdk: Bool) throws {
        self.allowDelete = allowDelete
        self.emitPackage = emitPackage
        self.emitSourcesSymlink = emitSourcesSymlink
        self.emitTestableSdk = emitTestableSdk
        self.astURL = astURL
        self.bindingsURL = bindingsURL
        self.handwrittenCodeSourceURL = Defaults.sourceOfHandwrittenCodeURL()
        self.handwrittenCodeTargetURL = Defaults.bindingsHandwrittenCodeURL(bindingsURL: bindingsURL)
        self.swiftModuleOutputURL = Defaults.bindingsGeneratedCodeURL(bindingsURL: bindingsURL)
        self.swiftTestsModuleOutputURL = Defaults.bindingsGeneratedTestsURL(bindingsURL: bindingsURL)
        self.swiftSdkTestsModuleOutputURL = Defaults.bindingsGeneratedSdkTestsURL(bindingsURL: bindingsURL)
        self.packageSourceURL = Defaults.packageSourceURL()
        self.packageTargetURL = Defaults.packageTargetURL(bindingsURL: bindingsURL)
        self.testableSdkHeaderURL = try Defaults.testableSdkHeaderURL()
        self.testableSdkImplURL = try Defaults.testableSdkImplURL()
        self.apiNotesURLs = try Defaults.apiNotesURLs()

        logger.log( "AST input path: \(astURL.path, privacy: .public)")
        logger.log( "Bindings handwritten code source dir: \(self.handwrittenCodeSourceURL.path, privacy: .public)")
        logger.log( "Bindings handwritten code target dir: \(self.handwrittenCodeTargetURL.path, privacy: .public)")
        logger.log( "Bindings autogenerated code output dir: \(self.swiftModuleOutputURL.path, privacy: .public)")
        logger.log( "Bindings package source dir: \(self.packageSourceURL.path, privacy: .public)")
        logger.log( "Bindings package target dir: \(self.packageTargetURL.path, privacy: .public)")

        if emitPackage {
            try checkOrRemoveItem(at: packageTargetURL.appendingPathComponent("Package.swift"), allowDelete: allowDelete, isDirectory: false)
            try checkOrRemoveItem(at: packageTargetURL.appendingPathComponent("Sources"), allowDelete: allowDelete, isDirectory: true)
            try checkOrRemoveItem(at: packageTargetURL.appendingPathComponent("Tests"), allowDelete: allowDelete, isDirectory: true)
        }
        if emitSourcesSymlink {
            try? FileManager.default.trashItem(at: packageTargetURL.appendingPathComponent("SourcesLink"), resultingItemURL: nil)
        }
        try checkOrRemoveItem(at: handwrittenCodeTargetURL, allowDelete: allowDelete, isDirectory: true)
        try checkOrRemoveItem(at: swiftModuleOutputURL, allowDelete: allowDelete, isDirectory: true)
        try checkOrRemoveItem(at: swiftTestsModuleOutputURL, allowDelete: allowDelete, isDirectory: true)
        try checkOrRemoveItem(at: swiftSdkTestsModuleOutputURL, allowDelete: allowDelete, isDirectory: true)
        try apiNotesURLs.forEach { apiNotesURL in
            try checkOrRemoveItem(at: apiNotesURL, allowDelete: allowDelete, isDirectory: false)
        }

        if emitTestableSdk {
            try checkOrRemoveItem(at: testableSdkImplURL, allowDelete: allowDelete, isDirectory: true)
            try checkOrRemoveItem(at: testableSdkHeaderURL, allowDelete: allowDelete, isDirectory: true)
        }
    }

    private func checkOrRemoveItem(at url: URL, allowDelete: Bool, isDirectory: Bool) throws {
        var outIsDirectory: ObjCBool = isDirectory ? true : false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &outIsDirectory) else { return }

        if allowDelete {
            logger.log("Output item already exists, trashing: \(url.path, privacy: .public)")
            try FileManager.default.trashItem(at: url, resultingItemURL: nil)
        } else {
            throw ValidationError("Output item already exists, please remove: \(url.path)")
        }
    }

    func main() throws {

        if emitPackage {
            try FileManager.default.createDirectory(at: packageTargetURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [:])
            try FileManager.default.copyItem(at: packageSourceURL.appendingPathComponent("Package.swift"), to: packageTargetURL.appendingPathComponent("Package.swift"))
            try FileManager.default.copyItem(at: packageSourceURL.appendingPathComponent("Sources"), to: packageTargetURL.appendingPathComponent("Sources"))
            try FileManager.default.copyItem(at: packageSourceURL.appendingPathComponent("Tests"), to: packageTargetURL.appendingPathComponent("Tests"))
        }

        if emitTestableSdk {
            try FileManager.default.createDirectory(at: testableSdkImplURL, withIntermediateDirectories: true, attributes: [:])
            try FileManager.default.createDirectory(at: testableSdkHeaderURL, withIntermediateDirectories: true, attributes: [:])
        }
        
        try FileManager.default.createDirectory(at: handwrittenCodeTargetURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [:])

        if emitSourcesSymlink {
            try FileManager.default.createSymbolicLink(atPath: packageTargetURL.appendingPathComponent("SourcesLink").path,
                                                       withDestinationPath: "Sources")
        }

        logger.log("Copying handwritten code to \(self.handwrittenCodeTargetURL.path, privacy: .public)...")
        try FileManager.default.copyItem(at: handwrittenCodeSourceURL, to: handwrittenCodeTargetURL)
        logger.log("Copied handwritten code to \(self.handwrittenCodeTargetURL.path, privacy: .public)")
        
        let clangAST = try ClangAST.from(url: astURL)

        if emitTestableSdk {
            logger.log("Emitting TestableEOSSDK...")
            try CTestableImpl(ast: clangAST, headersURL: testableSdkHeaderURL, implURL: testableSdkImplURL).emit()
            logger.log("Emitted TestableEOSSDK")
        }

        logger.log("Building SwiftAST...")
        let swiftAST = try SwiftFromClang(ast: clangAST).swiftModule()
        logger.log("Built SwiftAST")

        let refactoredModules = try SwiftRefactor().refactor(module: swiftAST, apiNotesURLs: apiNotesURLs)

        func output(module: SwiftModule, to url: URL, imports: [String], options: SwiftWriterOptions) throws {
            logger.log("Printing \(module.name) to \(url.path, privacy: .public)...")
            try SwiftPrinter(outputDir: url, imports: imports, options: options).write(module: module)
            logger.log("Printed \(module.name) to \(url.path, privacy: .public)")
        }

        try output(
            module: refactoredModules.swiftModule,
            to: swiftModuleOutputURL,
            imports: Defaults.swiftModuleImports(),
            options: [.compact]
        )
        try output(
            module: refactoredModules.swiftTestsModule,
            to: swiftTestsModuleOutputURL,
            imports: Defaults.swiftTestModuleImports(),
            options: [.compact]
        )
        try output(
            module: refactoredModules.swiftSdkTestsModule,
            to: swiftSdkTestsModuleOutputURL,
            imports: Defaults.swiftSdkTestModuleImports(),
            options: []
        )

        print("Bindings written to: \(self.packageTargetURL.path)")
    }
}


SwiftEOSBuild.main()
