
import Foundation
import SwiftAST


extension SwiftShims {

    static func withBytePointerPointersReturnedAsByteArray(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if rhs.isInOutParm,
           let lhsPointer = lhs.type.canonical.asPointer,
           let lhsBuiltin = lhsPointer.pointeeType.asBuiltin,
           (lhsBuiltin.isByte || lhsBuiltin.isVoid),
           let rhsArray = rhs.type.canonical.asArray,
           let rhsBuiltin = rhsArray.elementType.asBuiltin,
           rhsBuiltin.isByte,
           let rhsArrayCount = rhs.linked(.arrayLength) as? SwiftVarDecl
        {
            return .function.withElementPointerPointersReturnedAsArray(
                bufferPointerName: rhs.name,
                countPointerName: rhsArrayCount.name,
                nest: nested)
        }
        return nil
    }
}
