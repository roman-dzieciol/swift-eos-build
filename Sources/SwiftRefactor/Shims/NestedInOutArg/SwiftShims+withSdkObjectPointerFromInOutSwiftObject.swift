
import Foundation
import SwiftAST


extension SwiftShims {

    /// `Pointer<SdkObject>`: `inout SwiftObject`
    static func withSdkObjectOptionalPointerFromInOutOptionalSwiftObject(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if rhs.isInOutParm,
           let rhsObject = rhs.type.canonical.asDeclRef?.decl.canonical as? SwiftObject,
           rhsObject.inSwiftEOS,
           let lhsPointer = lhs.type.canonical.asPointer,
           let lhsObject = lhsPointer.pointeeType.asDeclRef?.decl.canonical as? SwiftObject,
           !lhsObject.inSwiftEOS,
           lhsObject === rhsObject.sdk
        {
            return .try(.function.withSdkObjectOptionalPointerFromInOutOptionalSwiftObject(
                rhs.expr.inout,
                managedBy: .string("pointerManager"),
                pointerName: rhs.name,
                nest: nested))
        }
        return nil
    }

}
