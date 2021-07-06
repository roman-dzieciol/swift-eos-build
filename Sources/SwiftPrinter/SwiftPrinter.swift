
import Foundation
import SwiftAST
import Darwin

public class SwiftPrinter {

    let outputDir: URL

    public init(outputDir: URL) {
        self.outputDir = outputDir
    }

    func writingToDisk(fileName: String, action: (SwiftOutputStream) throws -> Void) throws {
        let url = outputDir.appendingPathComponent(fileName)
        try writingToDisk(url: url, action: action)
    }

    func writingToDisk(url: URL, action: (SwiftOutputStream) throws -> Void) throws {
        try! FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [:])
        FileManager.default.createFile(atPath: url.path, contents: nil, attributes: [:])
        let fileHandle = try FileHandle(forWritingTo: url)
        let outputStream = SwiftWriterStream(outputStream: FileHandlerOutputStream(fileHandle))
        try action(outputStream)
    }

    public func write(module: SwiftModule) throws {

//        try? FileManager.default.removeItem(at: outputDir)
        try! FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true, attributes: [:])

        let outputs = [URL: [SwiftAST]](grouping: module.inner, by: { url(for: $0) })

        try outputs.forEach { (url, ast) in
            try writingToDisk(url: url) { swiftOutput in
                swiftOutput.write(name: "import")
                swiftOutput.write(name: "Foundation")
                swiftOutput.write(text: "\n")
                swiftOutput.write(name: "import")
                swiftOutput.write(name: "EOSSDK")
                swiftOutput.write(text: "\n")
                swiftOutput.write(ast)
            }
        }
    }

    private func url(for swiftAST: SwiftAST) -> URL {

        let suffix: String = {
            if swiftAST is SwiftEnum {
                return "+Enums"
            } else if swiftAST is SwiftFunction {
                return ""
            } else if swiftAST.name.hasSuffix("_Actor") {
                return ""
            } else {
                return "+Types"
            }
        }()

        if swiftAST is SwiftEnum {
            return outputDir
                .appendingPathComponent("EOS" + suffix)
                .appendingPathExtension("swift")
        }

        var tokens = swiftAST.name.split(separator: "_", maxSplits: Int.max, omittingEmptySubsequences: true)

        if swiftAST is SwiftObject {
            tokens = Array(tokens.prefix(2))
            return outputDir
                .appendingPathComponent(String(tokens.last!) + suffix)
                .appendingPathExtension("swift")
        } else {
            tokens = tokens.dropLast()
            tokens = Array(tokens.prefix(2))
            return outputDir
                .appendingPathComponent(String(tokens.last!) + suffix)
                .appendingPathExtension("swift")
        }
    }
}

struct FileHandlerOutputStream: TextOutputStream {
    private let fileHandle: FileHandle

    init(_ fileHandle: FileHandle) {
        self.fileHandle = fileHandle
    }

    mutating func write(_ string: String) {
        string.data(using: .utf8).map { fileHandle.write($0) }
    }
}
