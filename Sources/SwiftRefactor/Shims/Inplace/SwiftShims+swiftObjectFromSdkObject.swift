
import Foundation
import SwiftAST


extension SwiftShims {

    static func swiftObjectFromSdkObject(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        // `SwiftObject` = `SdkObject`
        if !rhs.isInOutParm,
           let lhsDeclRef = lhs.type.canonical.asDeclRef,
           let lhsDecl = lhsDeclRef.decl.canonical as? SwiftObject,
           let rhsDeclRef = rhs.type.canonical.asDeclRef,
           let rhsDecl = rhsDeclRef.decl.canonical as? SwiftObject,
           lhsDecl.sdk === rhsDecl,
           lhsDecl.inSwiftEOS,
           !rhsDecl.inSwiftEOS {

            _ = try lhsDecl.functionInitFromSdkObject()

            var result: SwiftExpr = .try(lhsDecl.expr.call([.init(identifier: .string("sdkObject"), expr: nested)]))

            if lhs.type.isOptional == false {
                result = SwiftForcedValueExpr(expr: result)
            }

            return result
        }

        return nil
    }
}
