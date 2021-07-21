
import Foundation
import SwiftAST


extension SwiftShims {

    /// With nested `Pointer<SdkObject>` from `SwiftObject`
    static func withSdkObjectOptionalPointerFromOptionalSwiftObject(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

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
            if lhsPointer.isMutable && rhs.name == "Options" {
                return .try(.function.withSdkObjectOptionalMutablePointerFromSwiftObject(
                    rhs.expr,
                    managedBy: .string("pointerManager"),
                    pointerName: rhs.name,
                    nest: nested))
            } else {
                return .try(.function.withSdkObjectOptionalPointerFromOptionalSwiftObject(
                    rhs.expr,
                    managedBy: .string("pointerManager"),
                    pointerName: rhs.name,
                    nest: nested))
            }
        }
        return nil
    }
}

extension SwiftExpr.function {

    /// With nested `Pointer<SdkObject>` from `SwiftObject`
    static func withSdkObjectOptionalPointerFromOptionalSwiftObject(
        _ swiftObject: SwiftExpr,
        managedBy pointerManager: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withSdkObjectOptionalPointerFromOptionalSwiftObject", args: [
            swiftObject.arg(nil),
            pointerManager.arg("managedBy"),
            .closure([pointerName], nest: nest) ])
    }

    /// With nested `Pointer<SdkObject>` from `SwiftObject`
    static func withSdkObjectOptionalMutablePointerFromSwiftObject(
        _ swiftObject: SwiftExpr,
        managedBy pointerManager: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withSdkObjectOptionalMutablePointerFromSwiftObject", args: [
            swiftObject.arg(nil),
            pointerManager.arg("managedBy"),
            .closure([pointerName], nest: nest) ])
    }
}
