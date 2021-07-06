
import Foundation

public class SwiftEnum: SwiftObject {

    public init(name: String, superTypes: [String], inner: [SwiftAST] = [], comment: SwiftComment? = nil) {
        super.init(name: name, tagName: "enum", superTypes: superTypes, inner: inner, comment: comment)
    }

    public override func copy() -> SwiftEnum {
        let copy = SwiftEnum(name: name, superTypes: superTypes, inner: inner.map { $0.copy() }, comment: comment?.copy())
        linkCopy(from: self, to: copy)
        return copy
    }
}
