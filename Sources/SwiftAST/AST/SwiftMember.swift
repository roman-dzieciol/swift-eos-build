
import Foundation

final public class SwiftMember: SwiftVarDecl {

    public var getter: SwiftExpr?

    public init(name: String, type: SwiftType, isMutable: Bool = false, getter: SwiftExpr? = nil, comment: SwiftComment? = nil) {
        self.getter = getter
        super.init(name: name, inner: [], type: type, isMutable: isMutable, comment: comment)
    }

    public override func handle(visitor: SwiftVisitor) throws {
        try visitor.visitReplacing(type: &type)
        try super.handle(visitor: visitor)
    }

    public override func copy() -> SwiftMember {
        let copy = SwiftMember(name: name, type: type, isMutable: isMutable, getter: getter, comment: comment?.copy())
        linkCopy(from: self, to: copy)
        return copy
    }

    public override func declType() -> SwiftType? {
        type
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(comment)
        swift.write(name: access)
        swift.write(name: attributes.joined(separator: " "))
        if attributes.contains("lazy") {
            swift.write(name: "var")
        } else {
            swift.write(name: isMutable ? "var" : "let")
        }
        swift.write(name: name)
        swift.write(token: ":")
        swift.write(type)
        if let getter = getter {
            if attributes.contains("lazy") {
                swift.write(token: "=")
            }
            swift.write(nested: "{", "}") {
                swift.write(textIfNeeded: "\n")
                getter.write(to: swift)
                swift.write(textIfNeeded: "\n")
            }
            if attributes.contains("lazy") {
                swift.write(token: "()")
            }
        }
    }
}
