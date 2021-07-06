
import Foundation
import SwiftAST


extension SwiftShims {

    static func swiftUnionFromSdkUnion(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        // TODO: `Swifty Union` = `SDK Union`
        if lhs.type.canonical.asDeclRef?.decl.canonical is SwiftUnion,
           let rhsBuiltin = rhs.type.canonical.asBuiltin,
           rhsBuiltin.builtinName.contains("__Unnamed_union") {
            return nested
        }

        return nil
    }
}
