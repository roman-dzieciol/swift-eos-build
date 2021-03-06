
import Foundation
import SwiftAST


extension SwiftShims {

    /// Managed `Pointer<CChar>?` = `String?`
    static func cCharPointerFromString(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if !rhs.isInOutParm,
           !(lhs is SwiftFunctionParm && rhs.linked(.arrayLength) != nil),
           let lhsPointer = lhs.type.canonical.asPointer,
           lhsPointer.pointeeType.isCChar,
           rhs.type.canonical.isString
        {
            let arrayExpr = nested.member("utf8CString")
            if lhsPointer.isMutable {
                return .string("pointerManager").member(.function.managedMutablePointerToBuffer(copyingArray: arrayExpr))
            } else {
                return .string("pointerManager").member(.function.managedPointerToBuffer(copyingArray: arrayExpr))
            }
        }

        return nil
    }
}
