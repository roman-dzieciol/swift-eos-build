
import Foundation

public class SwiftTypeDecl: SwiftDecl {

    public var type: SwiftType

    public override var expr: SwiftDeclRefExpr {
        self.declRefType(qual: type.qual).declRefExpr
    }

    public override var canonical: SwiftAST {
        type.canonical.asDeclRef?.decl.canonical ?? self
    }

    public override var canonicalType: SwiftType? {
        type.canonical
    }

    public init(name: String, inner: [SwiftAST] = [], attributes: Set<String> = [], type: SwiftType, comment: SwiftComment? = nil) {
        self.type = type
        super.init(name: name, inner: inner, attributes: attributes, comment: comment)
    }
}
