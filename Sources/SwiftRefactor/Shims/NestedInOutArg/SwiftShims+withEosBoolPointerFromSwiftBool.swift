
import Foundation
import SwiftAST


extension SwiftShims {

    /// With `Pointer<EOS_Bool>` from `inout Bool`
    /// With `Pointer<EOS_Bool>` from `inout Optional<Bool>`
    static func withEosBoolPointerFromInOutSwiftBool(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if rhs.isInOutParm,
           lhs.type.asPointer?.pointeeType.isEosBool == true,
           rhs.type.isBool
        {
            if rhs.type.isOptional != false {
                return .function.withEosBoolPointerFromInOutOptionalSwiftBool(
                    inoutOptionalBool: rhs.expr.inout,
                    pointerName: rhs.name,
                    nest: nested)
            } else {

                return .function.withEosBoolPointerFromInOutSwiftBool(
                    inoutBool: rhs.expr.inout,
                    pointerName: rhs.name,
                    nest: nested)
            }
        }
        return nil
    }
}

extension SwiftExpr.function {

    /// With `Pointer<EOS_Bool>` from `inout Bool`
    static func withEosBoolPointerFromInOutSwiftBool(
        inoutBool: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withEosBoolPointerFromInOutSwiftBool", args: [
            inoutBool.arg(nil),
            .closure([pointerName], nest: nest) ])
    }

    /// With `Pointer<EOS_Bool>` from `inout Optional<Bool>`
    static func withEosBoolPointerFromInOutOptionalSwiftBool(
        inoutOptionalBool: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withEosBoolPointerFromInOutOptionalSwiftBool", args: [
            inoutOptionalBool.arg(nil),
            .closure([pointerName], nest: nest) ])
    }
}
