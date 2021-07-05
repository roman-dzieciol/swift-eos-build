
import Foundation
import SwiftAST


extension SwiftShims {

    static func withIntPointerFromInOutInt(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if rhs.name == "OutPort" {

        }
        if rhs.isInOutParm
            , let lhsBuiltin = lhs.type.canonical.asPointer?.pointeeType.asBuiltin
            , let rhsBuiltin = rhs.type.canonical.asBuiltin
            , lhsBuiltin.isInt
            , rhsBuiltin.isInt
//            , builtin.builtinName != sdkBuiltin.builtinName
        {
            if rhs.type.isOptional != false {
                return .function.withIntPointerFromInOutOptionalInt(
                    inoutOptionalInteger: rhs.expr.inout,
                    pointerName: rhs.name,
                    nest: nested)
            } else {

                return .function.withIntPointerFromInOutInt(
                    inoutInteger: rhs.expr.inout,
                    pointerName: rhs.name,
                    nest: nested)
            }
        }
        return nil
    }
}
