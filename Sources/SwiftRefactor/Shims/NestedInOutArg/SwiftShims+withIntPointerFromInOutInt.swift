
import Foundation
import SwiftAST


extension SwiftShims {

    /// With `Pointer<Int>` from `inout Int`
    /// With `Pointer<Int>` from `inout Optional<Int>`
    static func withIntPointerFromInOutInt(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if rhs.isInOutParm
            , let lhsBuiltin = lhs.type.canonical.asPointer?.pointeeType.asBuiltin
            , let rhsBuiltin = rhs.type.canonical.asBuiltin
            , lhsBuiltin.isInt
            , rhsBuiltin.isInt
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

extension SwiftExpr.function {

    /// With `Pointer<Int>` from `inout Int`
    static func withIntPointerFromInOutInt(
        inoutInteger: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withIntPointerFromInOutInt", args: [
            inoutInteger.arg(nil),
            .closure([pointerName], nest: nest) ])
    }

    /// With `Pointer<Int>` from `inout Optional<Int>`
    static func withIntPointerFromInOutOptionalInt(
        inoutOptionalInteger: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withIntPointerFromInOutOptionalInt", args: [
            inoutOptionalInteger.arg(nil),
            .closure([pointerName], nest: nest) ])
    }
}
