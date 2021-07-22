
import Foundation

final public class SwiftActor: SwiftObject {

    public init(name: String, superTypes: [String], inner: [SwiftAST] = [], comment: SwiftComment? = nil) {
        super.init(name: name, tagName: "actor", superTypes: superTypes, inner: inner, comment: comment)
    }

    public override func copy() -> SwiftActor {
        let copy = SwiftActor(name: name, superTypes: superTypes, inner: inner.map { $0.copy() }, comment: comment?.copy())
        linkCopy(from: self, to: copy)
        return copy
    }
}
