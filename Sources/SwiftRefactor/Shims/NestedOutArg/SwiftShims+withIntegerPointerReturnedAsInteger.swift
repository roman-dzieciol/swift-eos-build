
import Foundation
import SwiftAST


extension SwiftShims {

    static func withIntegerPointerReturnedAsInteger(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if rhs.isInOutParm
            , let lhsBuiltin = lhs.type.canonical.asPointer?.pointeeType.asBuiltin
            , let rhsBuiltin = rhs.type.canonical.asBuiltin
            , lhsBuiltin.isInt
            , rhsBuiltin.isInt
        {
            return .function.withIntegerPointerReturnedAsInteger(
                pointerName: rhs.name,
                nest: nested)
        }
        return nil
    }
}

extension SwiftExpr.function {

    static func withIntegerPointerReturnedAsInteger(
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withIntegerPointerReturnedAsInteger", args: [
            .closure([pointerName], nest: nest) ])
    }
}
