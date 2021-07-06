
import Foundation

public class ClangJSON {

    public let info: [String: Any]

    public init(_ info: [String: Any]) {
        self.info = info
    }

    public func string(key: String) -> String? {
        info[key] as? String
    }

    public func bool(key: String) -> Bool? {
        info[key] as? Bool
    }

    public func dictionary(key: String) -> [String: Any]? {
        info[key] as? [String: Any]
    }
}

