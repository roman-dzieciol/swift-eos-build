
import Foundation
import SwiftAST


extension SwiftShims {

    /// `Pointer<SdkObject>`: `inout SdkObject`
    static func withSdkObjectPointerFromInOutSdkObject(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if rhs.isInOutParm,
           let lhsPointer = lhs.type.canonical.asPointer,
           let lhsObject = lhsPointer.pointeeType.asDeclRef?.decl.canonical as? SwiftObject,
           !lhsObject.inSwiftEOS,
           !(lhsObject is SwiftEnum),
           let rhsObject = rhs.type.canonical.asDeclRef?.decl.canonical as? SwiftObject,
           !rhsObject.inSwiftEOS,
           !(rhsObject is SwiftEnum),
           lhsObject === rhsObject
        {
            if rhs.type.isOptional != false {
                return .function.withSdkObjectPointerFromInOutOptionalSdkObject(
                    .inout(rhs.expr),
                    managedBy: .string("pointerManager"),
                    pointerName: rhs.name,
                    nest: nested)
            } else {
                return .function.withSdkObjectPointerFromInOutSdkObject(
                    .inout(rhs.expr),
                    managedBy: .string("pointerManager"),
                    pointerName: rhs.name,
                    nest: nested)
            }
        }
        return nil
    }
    
}
