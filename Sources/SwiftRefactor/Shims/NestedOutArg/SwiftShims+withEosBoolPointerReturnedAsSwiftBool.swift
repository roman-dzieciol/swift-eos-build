
import Foundation
import SwiftAST


extension SwiftShims {

    static func withEosBoolPointerReturnedAsSwiftBool(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if rhs.isInOutParm,
           lhs.type.asPointer?.pointeeType.isEosBool == true,
           rhs.type.isBool
        {
            return .function.withEosBoolPointerReturnedAsSwiftBool(
                pointerName: rhs.name,
                nest: nested)
        }
        return nil
    }
}

extension SwiftExpr.function {

    static func withEosBoolPointerReturnedAsSwiftBool(
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withEosBoolPointerReturnedAsSwiftBool", args: [
            .closure([pointerName], nest: nest) ])
    }
}
