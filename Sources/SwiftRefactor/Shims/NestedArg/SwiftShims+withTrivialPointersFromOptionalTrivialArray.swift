
import Foundation
import SwiftAST


extension SwiftShims {

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
