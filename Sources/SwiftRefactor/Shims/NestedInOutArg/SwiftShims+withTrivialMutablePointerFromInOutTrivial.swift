
import Foundation
import SwiftAST


extension SwiftShims {

    static func withTrivialMutablePointerFromInOutTrivial(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if lhs.name == "OutPeerId" {

        }

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
