
import Foundation

public protocol SwiftOutputStream {

    var stack: [SwiftOutputStreamable] { get }

    func write(text: String)
    func write(textIfNeeded text: String)
    func write(token: String)
    func write(name: String)
    func write(nested opening: String, _ closing: String, _ contents: () -> Void)
    func write(_ inner: SwiftOutputStreamable?)
    func write(_ inner: [SwiftOutputStreamable])
    func write(_ inner: [SwiftOutputStreamable], separated: String)
    func indent(offset: Int, _ action: () -> Void)
}
