
import Foundation
import SwiftAST


extension SwiftShims {

    /// With nested `Pointer<Trivial>, Int` from `Optional<[Trivial]>`
    static func withTrivialPointersFromOptionalTrivialArray(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if !rhs.isInOutParm,
           let lhsPointer = lhs.type.canonical.asPointer,
           lhsPointer.pointeeType.isTrivial,
           let rhsArray = rhs.type.canonical.asArray,
           rhsArray.elementType.isTrivial,
           lhsPointer.pointeeType == rhsArray.elementType,
           let rhsArrayCount = rhs.linked(.arrayLength) as? SwiftVarDecl
        {
            return .try(.function.withTrivialPointersFromOptionalTrivialArray(
                rhs.expr,
                managedBy: .string("pointerManager"),
                pointerName: rhs.name,
                arrayCountName: rhsArrayCount.name,
                nest: nested))
        }
        return nil
    }
}

extension SwiftExpr.function {

    /// With nested `Pointer<Trivial>, Int` from `Optional<[Trivial]>`
    static func withTrivialPointersFromOptionalTrivialArray(
        _ optionalValue: SwiftExpr,
        managedBy pointerManager: SwiftExpr,
        pointerName: String,
        arrayCountName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withTrivialPointersFromOptionalTrivialArray", args: [
            optionalValue.arg(nil),
            pointerManager.arg("managedBy"),
            .closure([pointerName, arrayCountName], nest: nest) ])
    }
}
