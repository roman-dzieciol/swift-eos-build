
import Foundation

final public class SwiftTypealias: SwiftDecl {

    public var type: SwiftType

    public override var canonical: SwiftAST {
        type.canonical.asDeclRef?.decl.canonical ?? self
    }

    public override var canonicalType: SwiftType? {
        type.canonical
    }

    public override var innerType: SwiftType? {
        get { type }
        set { newValue.map { type = $0 } }
    }

    public init(name: String, type: SwiftType, comment: SwiftComment? = nil) {
        self.type = type
        //type.isOptional == nil ? type.copy { $0.optional } : type
        super.init(name: name, inner: [], comment: comment)
    }

    public override func handle(visitor: SwiftVisitor) throws {
        try visitor.visitReplacing(type: &type)
        try super.handle(visitor: visitor)
    }
    
    public override func copy() -> SwiftTypealias {
        let copy = SwiftTypealias(name: name, type: type, comment: comment?.copy())
        linkCopy(from: self, to: copy)
        return copy
    }
    
    public override func write(to swift: SwiftOutputStream) {
        swift.write(comment)
        swift.write(name: access)
        swift.write(name: "typealias")
        swift.write(name: name)
        swift.write(token: "=")
        swift.write(type)
    }
}
