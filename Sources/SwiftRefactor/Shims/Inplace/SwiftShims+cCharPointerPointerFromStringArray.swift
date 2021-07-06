
import Foundation
import SwiftAST


extension SwiftShims {

    static func cCharPointerPointerFromStringArray(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        // Managed `Pointer<Pointer<CChar>>` = `[String]`
        if !rhs.isInOutParm,
           !(lhs is SwiftFunctionParm && rhs.linked(.arrayLength) != nil),
           let lhsPointer = lhs.type.canonical.asPointer,
           let lhsInnerPointer = lhsPointer.pointeeType.asPointer,
           lhsInnerPointer.pointeeType.isCChar,
           let rhsArray = rhs.type.canonical.asArray,
           rhsArray.elementType.isString
        {
            let arrayExpr = nested.member(SwiftFunctionCallExpr.named("map", args: [ .closure([], nest: .string("$0").member(.string("utf8CString"))) ]))

            return .string("pointerManager").member(.function.managedMutablePointerToBufferOfPointers(copyingArray: arrayExpr))
        }

        return nil
    }
}
