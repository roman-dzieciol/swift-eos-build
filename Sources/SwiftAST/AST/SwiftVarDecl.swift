
import Foundation

public class SwiftVarDecl: SwiftTypeDecl {

    final public var isMutable: Bool

    final public var isInOutParm: Bool {
        isMutable && self is SwiftFunctionParm
    }

    final public var sdkVarDecl: SwiftVarDecl {
        linked(.sdk) as! SwiftVarDecl
    }

    public init(name: String, inner: [SwiftAST] = [], attributes: Set<String> = [], type: SwiftType, isMutable: Bool, comment: SwiftComment? = nil) {
        self.isMutable = isMutable
        super.init(name: name, inner: inner, attributes: attributes, type: type, comment: comment)
    }

}

extension SwiftType {

    final public func tempVar(named: SwiftVarDecl? = nil, attributes: Set<String> = [], isMutable: Bool = false) -> SwiftVarDecl {
        SwiftVarDecl(name: named?.name ?? "$0", inner: [], attributes: attributes, type: self, isMutable: isMutable, comment: nil)
    }

    final public func toVar(named: String, isMutable: Bool = false) -> SwiftVar {
        SwiftVar(name: named, type: self, isMutable: isMutable)
    }
}

public final class SwiftVarDeclRefExpr: SwiftPrimaryExpr {

    public let varDecl: SwiftVarDecl

    public init(varDecl: SwiftVarDecl) {
        self.varDecl = varDecl
    }

    public override func evaluateType(in context: SwiftDeclContext?) -> SwiftType? {
        return varDecl.declRefType()
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(varDecl)
    }
}

extension SwiftExpr {

    public static func `var`(_ named: String, type: SwiftType) -> SwiftVarDeclRefExpr {
        SwiftVarDeclRefExpr(varDecl: SwiftVar(name: named, type: type, isMutable: true))
    }

    public static func `let`(_ named: String, type: SwiftType) -> SwiftVarDeclRefExpr {
        SwiftVarDeclRefExpr(varDecl: SwiftVar(name: named, type: type, isMutable: false))
    }
}

