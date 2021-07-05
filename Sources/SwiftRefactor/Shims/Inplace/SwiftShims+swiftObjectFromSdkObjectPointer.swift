
import Foundation
import SwiftAST


extension SwiftShims {

    static func swiftObjectFromSdkObjectPointer(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        // `Swift Object` = `Pointer<SDK Object>`
        if let lhsObject = lhs.type.canonical.asDeclRef?.decl as? SwiftObject,
           let rhsObject = rhs.type.canonical.asPointer?.pointeeType.asDeclRef?.decl as? SwiftObject,
           lhsObject.sdk?.canonical === rhsObject.canonical {

            _ = try lhsObject.functionInitFromSdkObject()

            return .try(lhsObject.expr.member(.function.initFromSdkObject(nested.member(.string("pointee")))))
        }

        return nil
    }
}
