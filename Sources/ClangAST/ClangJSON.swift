
import Foundation

public class ClangJSON {

    final public let info: [String: Any]

    public init(_ info: [String: Any]) {
        self.info = info
    }

    final public func string(key: String) -> String? {
        info[key] as? String
    }

    final public func bool(key: String) -> Bool? {
        info[key] as? Bool
    }

    final public func dictionary(key: String) -> [String: Any]? {
        info[key] as? [String: Any]
    }
}

