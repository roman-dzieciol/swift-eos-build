
import Foundation
import SwiftAST


extension SwiftShims {

    /// Managed `Pointer<Void or UInt8 or Int8>` = `[UInt8 or Int8]`
    static func bytePointerFromByteArray(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if !rhs.isInOutParm,
           !(lhs is SwiftFunctionParm && rhs.linked(.arrayLength) != nil),
           let lhsPointer = lhs.type.canonical.asPointer,
           (lhsPointer.pointeeType.isVoid || lhsPointer.pointeeType.isByte),
           let rhsArray = rhs.type.canonical.asArray,
           (rhsArray.elementType.isVoid || rhsArray.elementType.isByte)
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
