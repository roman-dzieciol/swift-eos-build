
import Foundation
import SwiftAST


extension SwiftShims {

    /// TODO: `SDK Union` = `Swifty Union`
    static func sdkUnionFromSwiftUnion(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if let lhsBuiltin = lhs.type.canonical.asBuiltin,
           lhsBuiltin.builtinName.contains("__Unnamed_union"),
           rhs.type.canonical.asDeclRef?.decl.canonical is SwiftUnion {
            return nested
        }

        return nil
    }
}
