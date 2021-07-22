
import Foundation

public class SwiftTypeDecl: SwiftDecl {

    final public var type: SwiftType

    public override var innerType: SwiftType? {
        get { type }
        set { newValue.map { type = $0 } }
    }

    public override var expr: SwiftDeclRefExpr {
        self.declRefType(qual: type.qual).declRefExpr
    }

    public override var canonical: SwiftAST {
        type.canonical.asDeclRef?.decl.canonical ?? self
    }

    public override var canonicalType: SwiftType? {
        type.canonical
    }

    public override func declType() -> SwiftType? {
        type
    }

    public init(name: String, inner: [SwiftAST] = [], attributes: Set<String> = [], type: SwiftType, comment: SwiftComment? = nil) {
        self.type = type
        super.init(name: name, inner: inner, attributes: attributes, comment: comment)
    }
}
