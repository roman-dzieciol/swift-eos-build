
import Foundation
import SwiftAST


extension SwiftShims {

    /// With nested `Pointer<SdkObject>` from `SwiftObject`
    static func withSdkObjectPointerFromSwiftObject(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

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

extension SwiftExpr.function {

    /// With nested `Pointer<SdkObject>` from `SwiftObject`
    static func withSdkObjectPointerFromSwiftObject(
        _ swiftObject: SwiftExpr,
        managedBy pointerManager: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withSdkObjectPointerFromSwiftObject", args: [
            swiftObject.arg(nil),
            pointerManager.arg("managedBy"),
            .closure([pointerName], nest: nest) ])
    }
}
