
import Foundation

public class SwiftUnion: SwiftObject {

    public init(name: String, superTypes: [String], inner: [SwiftAST] = [], comment: SwiftComment? = nil) {
        super.init(name: name, tagName: "struct", superTypes: superTypes, inner: inner, comment: comment)
    }

    public override func copy() -> SwiftUnion {
        let copy = SwiftUnion(name: name, superTypes: superTypes, inner: inner.map { $0.copy() }, comment: comment?.copy())
        linkCopy(from: self, to: copy)
        return copy
    }

    public override func write(to swift: SwiftOutputStream) {
    }
}
