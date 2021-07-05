
import Foundation
import SwiftAST


extension SwiftShims {

    static func withBytesPointerFromInOutBytesArray(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if lhs.name == "OutBuffer" {
            
        }
        if rhs.isInOutParm,
           let lhsPointer = lhs.type.canonical.asPointer,
           let lhsBuiltin = lhsPointer.pointeeType.asBuiltin,
           (lhsBuiltin.isByte || lhsBuiltin.isVoid),
           let rhsArray = rhs.type.canonical.asArray,
           let rhsBuiltin = rhsArray.elementType.asBuiltin,
           rhsBuiltin.isByte,
//           lhsBuiltin == rhsBuiltin,
           let rhsArrayCount = rhs.linked(.arrayLength) as? SwiftVarDecl
        {
            return .function.withPointersToInOutArray(
                inoutArray: rhs.expr.inout,
                bufferPointerName: rhs.name,
                countPointerName: rhsArrayCount.name,
                nest: nested)
        }
        return nil
    }


//    static func inoutIntArrayToIntPointerPointer(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {
//
//        if lhs.name == "OutBuffer" {
//
//        }
//        if let lhsPointer = lhs.type.canonical.asPointer,
//           let lhsInnerPointer = lhsPointer.pointeeType.asPointer,
//           let lhsBuiltin = lhsInnerPointer.pointeeType.asBuiltin,
//           lhsBuiltin.isInt,
//           let rhsArray = rhs.type.canonical.asArray,
//           let rhsBuiltin = rhsArray.elementType.asBuiltin,
//           rhsBuiltin.isInt,
//           //           lhsBuiltin == rhsBuiltin,
//           let rhsArrayCount = rhs.linked(.arrayLength) as? SwiftVarDecl
//        {
//            return .function.withPointersToInOutArray(
//                inoutArray: rhs.expr,
//                bufferPointerName: rhs.name,
//                countPointerName: rhsArrayCount.name,
//                nest: nested)
//        }
//        return nil
//    }
}
