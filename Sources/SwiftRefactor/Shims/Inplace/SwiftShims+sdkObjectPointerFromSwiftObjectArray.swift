
import Foundation
import SwiftAST


extension SwiftShims {

    /// Managed `Pointer<SdkObject>` = `[SwiftObject]`
    static func sdkObjectPointerFromSwiftObjectArray(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if !rhs.isInOutParm,
           !(lhs is SwiftFunctionParm && rhs.linked(.arrayLength) != nil),
           let lhsPointer = lhs.type.canonical.asPointer,
           let lhsDeclRef = lhsPointer.pointeeType.asDeclRef,
           let lhsDecl = lhsDeclRef.decl.canonical as? SwiftObject,
           let rhsArray = rhs.type.canonical.asArray,
           let rhsDeclRef = rhsArray.elementType.asDeclRef,
           let rhsDecl = rhsDeclRef.decl.canonical as? SwiftObject,
           lhsDecl === rhsDecl.sdk,
           rhsDecl.inSwiftEOS {

            let arrayExpr = nested.member(SwiftFunctionCallExpr.named("map", args: [ .closure([], nest: .try(.string("$0").member(.function.buildSdkObject()))) ]))

            if lhsPointer.isMutable {
                return SwiftExpr.try(.string("pointerManager").member(.function.managedMutablePointerToBuffer(copyingArray: arrayExpr)))
            } else {
                return SwiftExpr.try(.string("pointerManager").member(.function.managedPointerToBuffer(copyingArray: arrayExpr)))
            }
        }

        return nil
    }
}
