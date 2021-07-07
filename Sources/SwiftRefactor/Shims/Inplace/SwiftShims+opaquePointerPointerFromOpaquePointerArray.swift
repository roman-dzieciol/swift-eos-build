
import Foundation
import SwiftAST


extension SwiftShims {

    /// Managed `Pointer<Pointer<Opaque>>` = `[Pointer<Opaque>]`
    static func opaquePointerPointerFromOpaquePointerArray(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if !rhs.isInOutParm,
           !(lhs is SwiftFunctionParm && rhs.linked(.arrayLength) != nil),
           let lhsPointer = lhs.type.canonical.asPointer,
           let lhsInnerPointer = lhsPointer.pointeeType.asPointer,
           let lhsOpaquePtr = lhsInnerPointer.asOpaquePointer,
           let rhsArray = rhs.type.canonical.asArray,
           let rhsOpaquePtr = rhsArray.elementType.asOpaquePointer,
           lhsOpaquePtr == rhsOpaquePtr
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
