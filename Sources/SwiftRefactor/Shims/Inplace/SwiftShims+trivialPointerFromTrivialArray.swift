
import Foundation
import SwiftAST


extension SwiftShims {

    /// Managed `Pointer<Pointer<Opaque>>` = `[Pointer<Opaque>]`
    static func trivialPointerFromTrivialArray(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if !rhs.isInOutParm,
           !(lhs is SwiftFunctionParm && rhs.linked(.arrayLength) != nil),
           let lhsPointer = lhs.type.canonical.asPointer,
           lhsPointer.pointeeType.isTrivial,
           let rhsArray = rhs.type.canonical.asArray,
           rhsArray.elementType.isTrivial,
           lhsPointer.pointeeType == rhsArray.elementType
        {
            if lhsPointer.isMutable {
                return .string("pointerManager").member(.function.managedMutablePointerToBuffer(copyingArray: nested))
            } else {
                return .string("pointerManager").member(.function.managedPointerToBuffer(copyingArray: nested))
            }
        }

        return nil
    }
}
