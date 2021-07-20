
import Foundation
import SwiftAST


extension SwiftShims {

    static func withSdkObjectPointerReturnedAsSdkObject(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

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
            return .function.throwingNilResult(
                .function.withPointeeReturned(
                    managedBy: .string("pointerManager"),
                    pointerName: rhs.name,
                    nest: nested
                ))
        }
        return nil
    }

}
