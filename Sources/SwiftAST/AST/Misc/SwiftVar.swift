
import Foundation


public class SwiftVar: SwiftVarDecl {

    public var varDeclExpr: SwiftVarDeclRefExpr {
        SwiftVarDeclRefExpr(varDecl: self)
    }

    public init(name: String, type: SwiftType, isMutable: Bool = false) {
        super.init(name: name, type: type, isMutable: isMutable)
    }

    public override func copy() -> SwiftVar {
        let copy = SwiftVar(name: name, type: type, isMutable: isMutable)
        linkCopy(from: self, to: copy)
        return copy
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(name: isMutable ? "var" : "let")
        swift.write(name: name)
        swift.write(token: ":")
        swift.write(type)
    }
}
