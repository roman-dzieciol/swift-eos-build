
import Foundation
import SwiftAST


extension SwiftShims {

    /// With nested `Pointer<Trivial>` from `inout Trivial`
    /// With nested `Pointer<Optional<Trivial>>` from `inout Optional<Trivial>`
    /// With nested `Pointer<Trivial>` from `inout Optional<Trivial>` 
    static func withTrivialMutablePointerFromInOutTrivial(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if let lhsPointer = lhs.type.canonical.asPointer,
           lhsPointer.pointeeType.isTrivial,
           lhsPointer.isMutable,
           rhs.isInOutParm,
           rhs.type.canonical.isTrivial,
           lhsPointer.pointeeType.optional == rhs.type.canonical.optional {

            if rhs.type.isOptional != false {
                if lhs.type.asPointer?.pointeeType.isOptional != false {
                    return .function.withOptionalTrivialMutablePointerFromInOutOptionalTrivial(
                        .inout(rhs.expr),
                        managedBy: .string("pointerManager"),
                        pointerName: rhs.name,
                        nest: nested)
                } else {
                    return .function.withTrivialMutablePointerFromInOutOptionalTrivial(
                        .inout(rhs.expr),
                        managedBy: .string("pointerManager"),
                        pointerName: rhs.name,
                        nest: nested)
                }
            } else {
                return .function.withTrivialMutablePointerFromInOutTrivial(
                    .inout(rhs.expr),
                    managedBy: .string("pointerManager"),
                    pointerName: rhs.name,
                    nest: nested)
            }
        }

        return nil
    }
}

extension SwiftExpr.function {


    /// With nested `Pointer<Trivial>` from `inout Trivial`
    static func withTrivialMutablePointerFromInOutTrivial(
        _ inoutValue: SwiftExpr,
        managedBy pointerManager: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withTrivialMutablePointerFromInOutTrivial", args: [
            inoutValue.arg(nil),
            pointerManager.arg("managedBy"),
            .closure([pointerName], nest: nest) ])
    }

    /// With nested `Pointer<Optional<Trivial>>` from `inout Optional<Trivial>`
    static func withOptionalTrivialMutablePointerFromInOutOptionalTrivial(
        _ inoutOptionalValue: SwiftExpr,
        managedBy pointerManager: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withOptionalTrivialMutablePointerFromInOutOptionalTrivial", args: [
            inoutOptionalValue.arg(nil),
            pointerManager.arg("managedBy"),
            .closure([pointerName], nest: nest) ])
    }

    /// With nested `Pointer<Trivial>` from `inout Optional<Trivial>`
    static func withTrivialMutablePointerFromInOutOptionalTrivial(
        _ inoutOptionalValue: SwiftExpr,
        managedBy pointerManager: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withTrivialMutablePointerFromInOutOptionalTrivial", args: [
            inoutOptionalValue.arg(nil),
            pointerManager.arg("managedBy"),
            .closure([pointerName], nest: nest) ])
    }
}
