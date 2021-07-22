
import Foundation

final public class SwiftWriterString {

    private let writer: SwiftWriterStream<String>

    public init() {
        self.writer = SwiftWriterStream<String>(outputStream: String())
    }

    public static func description(for outputtable: SwiftOutputStreamable) -> String {
        debugDescription(for: outputtable)
    }

    public static func debugDescription(for outputtable: SwiftOutputStreamable) -> String {
        SwiftWriterString().from(outputtable)
    }

    public func from(_ inner: SwiftOutputStreamable) -> String {
        writer.write(inner)
        return writer.outputStream
    }
}
