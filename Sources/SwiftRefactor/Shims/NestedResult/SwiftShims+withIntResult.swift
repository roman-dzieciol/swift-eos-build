
import Foundation
import SwiftAST


extension SwiftShims {

    /// With `Int` result from`() -> AnotherInt`
    static func withIntResult(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if let lhsBuiltin = lhs.type.canonical.asBuiltin
            , let rhsBuiltin = rhs.type.canonical.asBuiltin
            , lhsBuiltin.isInt
            , rhsBuiltin.isInt
            , lhsBuiltin.builtinName != rhsBuiltin.builtinName
        {
            return .function.withIntResult(nested)
        }
        return nil
    }
}

extension SwiftExpr.function {

    /// With `Int` result from`() -> AnotherInt`
    static func withIntResult(_ nest: SwiftExpr) -> SwiftExpr {
            .try(SwiftFunctionCallExpr.named("withIntResult", args: [ .closure([], nest: nest) ]))
    }
}
