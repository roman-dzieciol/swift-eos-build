
import Foundation
import SwiftAST


extension SwiftShims {
    /// `Pointer<SdkObject>`: `SwiftObject`
    static func withSdkObjectPointerFromSwiftObject(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if lhs.name == "Options" {

        }

        if !rhs.isInOutParm,
           let lhsPointer = lhs.type.canonical.asPointer,
           let lhsObject = lhsPointer.pointeeType.asDeclRef?.decl.canonical as? SwiftObject,
           !lhsObject.inSwiftEOS,
           !(lhsObject is SwiftEnum),
           let rhsObject = rhs.type.canonical.asDeclRef?.decl.canonical as? SwiftObject,
           rhsObject.inSwiftEOS,
           !(rhsObject is SwiftEnum),
           lhsObject === rhsObject.sdk
        {
            return .try(.function.withSdkObjectPointerFromSwiftObject(
                rhs.expr,
                managedBy: .string("pointerManager"),
                pointerName: rhs.name,
                nest: nested))
        }
        return nil
    }
}
