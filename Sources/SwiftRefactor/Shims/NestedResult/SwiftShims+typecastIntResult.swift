
import Foundation
import SwiftAST


extension SwiftShims {

    static func typecastIntResult(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if let lhsBuiltin = lhs.type.canonical.asBuiltin
            , let rhsBuiltin = rhs.type.canonical.asBuiltin
            , lhsBuiltin.isInt
            , rhsBuiltin.isInt
            , lhsBuiltin.builtinName != rhsBuiltin.builtinName
        {
            return .function.typecastIntResult(nested)
        }
        return nil
    }
}
