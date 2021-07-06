
import Foundation

public class SwiftWriterString: SwiftWriterStream<String> {

    public init() {
        super.init(outputStream: String())
    }

    public static func description(for outputtable: SwiftOutputStreamable) -> String {
        debugDescription(for: outputtable)
    }

    public static func debugDescription(for outputtable: SwiftOutputStreamable) -> String {
        SwiftWriterString().from(outputtable)
    }

    public func from(_ inner: SwiftOutputStreamable) -> String {
        write(inner)
        return outputStream
    }
}
