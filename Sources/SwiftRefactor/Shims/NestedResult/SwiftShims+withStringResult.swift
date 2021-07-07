
import Foundation
import SwiftAST


extension SwiftShims {

    /// With `String` result from`() -> Pointer<CChar>`
    static func withStringResult(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if lhs.type.canonical.asString != nil,
           rhs.type.canonical.asPointer?.pointeeType.asCChar != nil {
            return .function.withStringResult(nested)
        }
        return nil
    }
}

extension SwiftExpr.function {

    /// With `String` result from`() -> Pointer<CChar>`
    static func withStringResult(_ nest: SwiftExpr) -> SwiftExpr {
            .try(SwiftFunctionCallExpr.named("withStringResult", args: [ .closure([], nest: nest) ]))
    }
}
