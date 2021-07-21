
import Foundation
import SwiftAST


extension SwiftShims {

    static func withHandleReturned(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if let lhsPointer = lhs.type.canonical.asPointer,
           (lhs.name.hasSuffix("Handle") || lhsPointer.pointeeType.isHandlePointer || lhsPointer.pointeeType.isOpaquePointer()),
           (rhs.name.hasSuffix("Handle") || rhs.type.canonical.isHandlePointer || rhs.type.canonical.isOpaquePointer()),
           lhsPointer.isMutable,
           rhs.isInOutParm,
           try canAssign(lhsType: lhsPointer.pointeeType.copy({ $0.with(isOptional: lhs.type.isOptional)}),
                         rhsType: rhs.type, options: []) {

            return .function.throwingNilResult(
                .function.withHandleReturned(
                    managedBy: .string("pointerManager"),
                    pointerName: rhs.name,
                    nest: nested
                ))
        }

        return nil
    }
}

extension SwiftExpr.function {

    static func withHandleReturned(
        managedBy pointerManager: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withHandleReturned", args: [
            pointerManager.arg("managedBy"),
            .closure([pointerName], nest: nest) ])
    }
}
