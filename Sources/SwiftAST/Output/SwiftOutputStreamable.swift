
import Foundation

public protocol SwiftOutputStreamable {
    func write(to swift: SwiftOutputStream)
}


extension String: SwiftOutputStreamable {

    public func write(to swift: SwiftOutputStream) {
        swift.write(name: self)
    }
}
