
import Foundation
import SwiftAST


extension SwiftShims {

    static func withHandlePointerFromInOutHandle(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if let lhsPointer = lhs.type.canonical.asPointer,
           (lhs.name.hasSuffix("Handle") || lhsPointer.pointeeType.isHandlePointer || lhsPointer.pointeeType.isOpaquePointer()),
           (rhs.name.hasSuffix("Handle") || rhs.type.canonical.isHandlePointer || rhs.type.canonical.isOpaquePointer()),
           lhsPointer.isMutable,
           rhs.isInOutParm,
           try canAssign(lhsType: lhsPointer.pointeeType.copy({ $0.with(isOptional: lhs.type.isOptional)}),
                         rhsType: rhs.type, options: []) {
            
            if rhs.type.isOptional != false {
                if lhs.type.isOptional != false {
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
