
import Foundation
import SwiftAST


extension SwiftShims {

    static func typecastBoolResult(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if let lhsBuiltin = lhs.type.canonical.asBuiltin
            , let rhsDecl = rhs.type.asDeclRef?.decl.canonical
            , lhsBuiltin.builtinName == "Bool"
            , rhsDecl.name == "EOS_Bool"
        {
            return .function.typecastBoolResult(nested)
        }
        return nil
    }
}
