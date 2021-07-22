

import Foundation

final public class SourceLocation: ClangJSON, Equatable {

    public var offset: Int? { info["offset"] as? Int }
    public var col: Int? { info["col"] as? Int }
    public var tokLen: Int? { info["tokLen"] as? Int }

    public static func == (lhs: SourceLocation, rhs: SourceLocation) -> Bool {
        return lhs.offset == rhs.offset && lhs.col == rhs.col && lhs.tokLen == rhs.tokLen
    }
}
