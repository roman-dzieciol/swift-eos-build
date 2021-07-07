
import Foundation
import SwiftAST


extension SwiftShims {

    /// Managed `Pointer<SdkObject>` = `SwiftObject`
    static func sdkObjectPointerOrNilPointerFromSwiftObject(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if !rhs.isInOutParm,
           !(lhs is SwiftFunctionParm && rhs.linked(.arrayLength) != nil),
           let lhsPointer = lhs.type.canonical.asPointer,
           let lhsDeclRef = lhsPointer.pointeeType.asDeclRef,
           let lhsDecl = lhsDeclRef.decl.canonical as? SwiftObject,
           let rhsDeclRef = rhs.type.canonical.asDeclRef,
           let rhsDecl = rhsDeclRef.decl.canonical as? SwiftObject,
           lhsDecl === rhsDecl.sdk,
           rhsDecl.inSwiftEOS {

            let valueExpr = nested.member(.function.buildSdkObject())

            if lhsPointer.isMutable {
                return SwiftExpr.try(.string("pointerManager").member(.function.managedMutablePointer(copyingValueOrNilPointer: valueExpr)))
            } else {
                return SwiftExpr.try(.string("pointerManager").member(.function.managedPointer(copyingValueOrNilPointer: valueExpr)))
            }
        }
        
        return nil
    }
}
