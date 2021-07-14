
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
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [:])
        FileManager.default.createFile(atPath: url.path, contents: nil, attributes: [:])
        let fileHandle = try FileHandle(forWritingTo: url)
        let outputStream = SwiftWriterStream(outputStream: FileHandlerOutputStream(fileHandle))
        try action(outputStream)
    }

    public func write(module: SwiftModule) throws {

        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true, attributes: [:])

        let outputs = [URL: [SwiftAST]](grouping: module.inner, by: { url(for: $0) })

        let byName = [String: [(URL, [SwiftAST])]](grouping: outputs.map { ($0.key, $0.value) }, by: { $0.0.lastPathComponent })

        var uniqueOutputs: [URL: [SwiftAST]] = [:]
        for (_, urlPairs) in byName {
            if let (url, asts) = urlPairs.first, urlPairs.count == 1 {
                uniqueOutputs[url] = asts
            } else {
                var uniqueNames: [String] = urlPairs.map { $0.0.lastPathComponent }
                var urls: [URL] = urlPairs.map { $0.0.deletingLastPathComponent() }


                while( Set(uniqueNames).count != urlPairs.count ) {
                    uniqueNames = zip(urls, uniqueNames).map { $0.0.lastPathComponent + $0.1 }
                    urls = urls.map { $0.deletingLastPathComponent() }
                    urls.forEach {
                        guard !$0.lastPathComponent.isEmpty else { fatalError() }
                    }
                }

                let pairs: [(URL, [SwiftAST])] = zip(urlPairs, uniqueNames).map { pair, uniqueName in
                    (pair.0.deletingLastPathComponent().appendingPathComponent(uniqueName), pair.1)
                }


                for (url, asts) in pairs {
                    if let outputPairs = uniqueOutputs[url] {
                        uniqueOutputs[url] = outputPairs + asts
                    } else {
                        uniqueOutputs[url] = asts
                    }
                }
            }
        }

        let finalOutputs: [(URL, [SwiftAST])] = uniqueOutputs.map { (url, asts) in

            let lastComponent = url.lastPathComponent

            if lastComponent.hasSuffix("Options.swift") {
                let url = url.deletingLastPathComponent().appendingPathComponent("Options").appendingPathComponent(lastComponent)
                return (url, asts)
            } else if lastComponent.hasSuffix("CallbackInfo.swift") {
                let url = url.deletingLastPathComponent().appendingPathComponent("CallbackInfo").appendingPathComponent(lastComponent)
                return (url, asts)
            }

            return (url, asts)
        }

        try finalOutputs.forEach { (url, ast) in
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [:])
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

        var components = swiftAST.name.split(separator: "_", maxSplits: Int.max, omittingEmptySubsequences: true)

        if components.first == "SwiftEOS" {
            components.removeFirst()
        }

        var outputUrl = outputDir

        if let swiftObject = swiftAST as? SwiftObject, swiftObject.tagName == "extension", swiftObject.superTypes.contains("CustomStringConvertible") {
            return outputUrl
                .appendingPathComponent("EOS")
                .appendingPathComponent("EOS+CustomStringConvertible.swift")
        }

        for component in components {
            outputUrl.appendPathComponent(String(component))
        }

        outputUrl.appendPathExtension("swift")

        return outputUrl
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
