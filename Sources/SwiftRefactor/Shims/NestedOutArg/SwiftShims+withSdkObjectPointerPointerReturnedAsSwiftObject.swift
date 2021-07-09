
import Foundation
import SwiftAST


extension SwiftShims {

    /// `Pointer<Pointer<SdkObject>?>`: `-> SwiftObject`
    static func withSdkObjectPointerPointerReturnedAsSwiftObject(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if rhs.isInOutParm,
           let rhsObject = rhs.type.canonical.asDeclRef?.decl.canonical as? SwiftObject,
           rhsObject.inSwiftEOS,
           let lhsPointer = lhs.type.canonical.asPointer,
           let lhsPointerPointer = lhsPointer.pointeeType.asPointer,
           let lhsObject = lhsPointerPointer.pointeeType.asDeclRef?.decl.canonical as? SwiftObject,
           !lhsObject.inSwiftEOS,
           lhsObject === rhsObject.sdk
        {
            guard let releaseFunc = lhsObject.linked(.releaseFunc) as? SwiftFunction else {
                fatalError()
            }

            return .function.withSdkObjectPointerPointerReturnedAsSwiftObject(
                managedBy: .string("pointerManager"),
                pointerPointerName: lhs.name,
                nest: nested,
                release: releaseFunc.expr
            )
        }
        return nil
    }

}
