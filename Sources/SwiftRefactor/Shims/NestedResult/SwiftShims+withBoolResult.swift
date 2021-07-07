
import Foundation
import SwiftAST


extension SwiftShims {

    /// With `Bool` result from`() -> EOS_Bool`
    static func withBoolResult(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if let lhsBuiltin = lhs.type.canonical.asBuiltin
            , let rhsDecl = rhs.type.asDeclRef?.decl.canonical
            , lhsBuiltin.builtinName == "Bool"
            , rhsDecl.name == "EOS_Bool"
        {
            return .function.withBoolResult(nested)
        }
        return nil
    }
}

extension SwiftExpr.function {

    /// With `Bool` result from`() -> EOS_Bool`
    static func withBoolResult(_ nest: SwiftExpr) -> SwiftExpr {
            .try(SwiftFunctionCallExpr.named("withBoolResult", args: [ .closure([], nest: nest) ]))
    }
}
