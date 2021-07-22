
import Foundation
import SwiftAST

final public class SwiftPrinter {

    let outputDir: URL
    let imports: [String]
    let importsString: String
    let options: SwiftWriterOptions
    let queue = DispatchQueue(label: "SwiftPrinter")
    let parallelPrinting: Bool = true

    public init(outputDir: URL, imports: [String], options: SwiftWriterOptions) {
        self.outputDir = outputDir
        self.imports = imports
        self.importsString = imports.joined(separator: "\n") + "\n\n"
        self.options = options
    }

    func writingToDisk(url: URL, action: (SwiftOutputStream) throws -> Void) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [:])
        var output = ""
        output.reserveCapacity(1024 * 70)
        let outputStream = SwiftWriterStream(outputStream: output, options: options)
        try action(outputStream)
        try outputStream.outputStream.write(to: url, atomically: true, encoding: .utf8)
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

        if parallelPrinting {
            DispatchQueue.concurrentPerform(iterations: finalOutputs.count) { index in
                do {
                    let (url, ast) = finalOutputs[index]
                    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [:])
                    try writingToDisk(url: url) { swift in
                        swift.write(text: importsString)
                        swift.write(ast)
                    }
                } catch {
                    print(error)
                }
            }
        } else {
            try finalOutputs.forEach { (url, ast) in
                try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [:])
                try writingToDisk(url: url) { swift in
                    swift.write(text: importsString)
                    swift.write(ast)
                }
            }
        }
    }

    private func isTestObject(_ ast: SwiftAST) -> Bool {
        if let swiftObject = ast as? SwiftObject, swiftObject.superTypes.contains("XCTestCase") {
            return true
        }
        return false
    }

    private func url(for swiftAST: SwiftAST) -> URL {

        var components = swiftAST.name.split(separator: "_", maxSplits: Int.max, omittingEmptySubsequences: true)

        if components.first == "SwiftEOS" {
            components.removeFirst()
        }

        var outputUrl: URL = outputDir

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
