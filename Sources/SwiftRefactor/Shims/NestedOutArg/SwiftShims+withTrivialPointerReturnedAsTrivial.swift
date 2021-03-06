
import Foundation
import SwiftAST


extension SwiftShims {

    static func withTrivialPointerReturnedAsTrivial(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if let lhsPointer = lhs.type.canonical.asPointer,
           lhsPointer.pointeeType.isTrivial,
           lhsPointer.isMutable,
           rhs.isInOutParm,
           rhs.type.canonical.isTrivial,
           lhsPointer.pointeeType.optional == rhs.type.canonical.optional {

            return .function.withTrivialPointerReturnedAsTrivial(
                managedBy: .string("pointerManager"),
                pointerName: rhs.name,
                nest: nested
            )
        }

        return nil
    }
}

extension SwiftExpr.function {

    static func withTrivialPointerReturnedAsTrivial(
        managedBy pointerManager: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withTrivialPointerReturnedAsTrivial", args: [
            pointerManager.arg("managedBy"),
            .closure([pointerName], nest: nest) ])
    }
}
