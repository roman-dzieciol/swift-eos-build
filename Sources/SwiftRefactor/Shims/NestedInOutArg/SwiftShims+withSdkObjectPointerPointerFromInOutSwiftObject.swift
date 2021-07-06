
import Foundation
import SwiftAST


extension SwiftShims {

    /// `Pointer<Pointer<SdkObject>?>`: `inout SwiftObject`
    static func withSdkObjectPointerPointerFromInOutSwiftObject(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if rhs.isInOutParm,
           let rhsObject = rhs.type.canonical.asDeclRef?.decl.canonical as? SwiftObject,
           rhsObject.inSwiftEOS,
           let lhsPointer = lhs.type.canonical.asPointer,
           let lhsPointerPointer = lhsPointer.pointeeType.asPointer,
           let lhsObject = lhsPointerPointer.pointeeType.asDeclRef?.decl.canonical as? SwiftObject,
           !lhsObject.inSwiftEOS,
           lhsObject === rhsObject.sdk
        {
            return .function.withSdkObjectPointerPointerFromInOutSwiftObject(
                inoutSwiftObject: rhs.expr.inout,
                pointerManager: .string("pointerManager"),
                pointerPointerName: rhs.name,
                nest: nested)
        }
        return nil
    }

}
