
import Foundation
import ArgumentParser
import ClangAST
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

    static func packageSourceURL() -> URL {
        repositoryRootURL.appendingPathComponent("Scripts/Package")
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

    static func sdkSymlinkSourceURL() throws -> URL {
        try versionOutputURL().appendingPathComponent("EOSSDK.xcframework")
    }

    static func sdkSymlinkTargetURL(bindingsURL: URL) -> URL {
        packageTargetURL(bindingsURL: bindingsURL).appendingPathComponent("EOSSDK.xcframework")
    }

    static func apiNotesURL() throws -> URL {
        try sdkSymlinkSourceURL().appendingPathComponent("ios-arm64/EOSSDK.framework/Headers/EOSSDK.apinotes")
    }
}

struct SwiftEOSBuild: ParsableCommand {

    @Option var astPath: String?
    @Option var bindingsPath: String?
    @Flag var allowDelete: Bool = false
    @Flag(inversion: .prefixedNo) var emitPackage: Bool = true
    @Flag(inversion: .prefixedNo) var emitSdkSymlink: Bool = true

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
            emitSdkSymlink: emitSdkSymlink
        ).main()
    }
}

class SwiftEOSBuildImpl {

    let logger = Logger.main
    let allowDelete: Bool
    let emitPackage: Bool
    let emitSdkSymlink: Bool
    let astURL: URL
    let bindingsURL: URL
    let handwrittenCodeSourceURL: URL
    let handwrittenCodeTargetURL: URL
    let autogeneratedCodeOutputURL: URL
    let packageSourceURL: URL
    let packageTargetURL: URL
    let sdkSymlinkSourceURL: URL
    let sdkSymlinkTargetURL: URL
    let apiNotesURL: URL

    init(astURL: URL, bindingsURL: URL, allowDelete: Bool, emitPackage: Bool, emitSdkSymlink: Bool) throws {
        self.allowDelete = allowDelete
        self.emitPackage = emitPackage
        self.emitSdkSymlink = emitSdkSymlink
        self.astURL = astURL
        self.bindingsURL = bindingsURL
        self.handwrittenCodeSourceURL = Defaults.sourceOfHandwrittenCodeURL()
        self.handwrittenCodeTargetURL = Defaults.bindingsHandwrittenCodeURL(bindingsURL: bindingsURL)
        self.autogeneratedCodeOutputURL = Defaults.bindingsGeneratedCodeURL(bindingsURL: bindingsURL)
        self.packageSourceURL = Defaults.packageSourceURL()
        self.packageTargetURL = Defaults.packageTargetURL(bindingsURL: bindingsURL)
        self.sdkSymlinkSourceURL = try Defaults.sdkSymlinkSourceURL()
        self.sdkSymlinkTargetURL = Defaults.sdkSymlinkTargetURL(bindingsURL: bindingsURL)
        self.apiNotesURL = try Defaults.apiNotesURL()

        logger.log( "AST input path: \(astURL.path, privacy: .public)")
        logger.log( "Bindings handwritten code source dir: \(self.handwrittenCodeSourceURL.path, privacy: .public)")
        logger.log( "Bindings handwritten code target dir: \(self.handwrittenCodeTargetURL.path, privacy: .public)")
        logger.log( "Bindings autogenerated code output dir: \(self.autogeneratedCodeOutputURL.path, privacy: .public)")
        logger.log( "Bindings package source dir: \(self.packageSourceURL.path, privacy: .public)")
        logger.log( "Bindings package target dir: \(self.packageTargetURL.path, privacy: .public)")

        if emitPackage {
            try checkOrRemoveItem(at: packageTargetURL.appendingPathComponent("Package.swift"), allowDelete: allowDelete)
            try checkOrRemoveItem(at: packageTargetURL.appendingPathComponent("Sources"), allowDelete: allowDelete)
            try checkOrRemoveItem(at: packageTargetURL.appendingPathComponent("Tests"), allowDelete: allowDelete)
        }
        try checkOrRemoveItem(at: handwrittenCodeTargetURL, allowDelete: allowDelete)
        try checkOrRemoveItem(at: autogeneratedCodeOutputURL, allowDelete: allowDelete)
        try checkOrRemoveItem(at: apiNotesURL, allowDelete: allowDelete)

    }

    private func checkOrRemoveItem(at url: URL, allowDelete: Bool) throws {
        guard FileManager.default.fileExists(atPath: url.path) else { return }

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
            try FileManager.default.copyItem(at: packageSourceURL, to: packageTargetURL)
        }

        try FileManager.default.createDirectory(at: handwrittenCodeTargetURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [:])

        if emitSdkSymlink {
            try FileManager.default.createSymbolicLink(at: sdkSymlinkTargetURL, withDestinationURL: sdkSymlinkSourceURL)
        }

        logger.log("Copying handwritten code to \(self.handwrittenCodeTargetURL.path, privacy: .public)...")
        try FileManager.default.copyItem(at: handwrittenCodeSourceURL, to: handwrittenCodeTargetURL)
        logger.log("Copied handwritten code to \(self.handwrittenCodeTargetURL.path, privacy: .public)")
        
        let clangAST = try ClangAST.from(url: astURL)

        logger.log("Building SwiftAST...")
        let swiftAST = try SwiftFromClang(ast: clangAST).swiftModule()
        logger.log("Built SwiftAST")

        let refactoredModule = try SwiftRefactor().refactor(module: swiftAST, apiNotesURL: apiNotesURL)

        logger.log("Printing to \(self.autogeneratedCodeOutputURL.path, privacy: .public)...")
        try SwiftPrinter(outputDir: autogeneratedCodeOutputURL).write(module: refactoredModule)
        logger.log("Printed to \(self.autogeneratedCodeOutputURL.path, privacy: .public)")


        print("Bindings written to: \(self.packageTargetURL.path)")
    }
}


SwiftEOSBuild.main()
