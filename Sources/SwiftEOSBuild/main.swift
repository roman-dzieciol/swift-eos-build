
import Foundation
import ArgumentParser
import ClangAST
import SwiftAST
import SwiftFromClang
import SwiftRefactor
import SwiftPrinter
import os.log

struct SwiftEOSBuild: ParsableCommand {

    @Option var input: String
    @Option var output: String

    mutating func run() throws {
        try SwiftEOSBuildImpl(
            inputURL: URL(fileURLWithPath: input),
            outputURL: URL(fileURLWithPath: output)
        ).main()
    }
}

class SwiftEOSBuildImpl {

    let inputURL: URL
    let outputURL: URL

    let outputDir: URL

    let sourceManualDir: URL
    let targetManualDir: URL

    init(inputURL: URL, outputURL: URL) throws {
        self.inputURL = inputURL
        self.outputURL = outputURL

        outputDir = outputURL.appendingPathComponent("./EOS/Sources/EOS/EOSSDK")
        targetManualDir = outputURL.appendingPathComponent("./EOS/Sources/EOS/SwiftEOS")
        sourceManualDir = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("./Sources/SwiftRefactor/EOSSDK/Public")
    }

    func main() throws {

        let clangAST = try ClangAST.from(url: inputURL)

        os_log("Building SwiftAST...")
        let swiftAST = try SwiftFromClang(ast: clangAST).swiftModule()
        os_log("Built SwiftAST")

        let refactoredModule = try SwiftRefactor().refactor(module: swiftAST)

        os_log("Printing to %{public}s...", outputDir.path)
        try SwiftPrinter(outputDir: outputDir).write(module: refactoredModule)
        os_log("Printed to %{public}s", outputDir.path)

//        try? FileManager.default.removeItem(at: targetManualDir)
//        try FileManager.default.createDirectory(at: targetManualDir, withIntermediateDirectories: true, attributes: [:])
        try FileManager.default.copyItem(at: sourceManualDir, to: targetManualDir)
    }
}


SwiftEOSBuild.main()
