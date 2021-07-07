
import Foundation
import SwiftAST


extension SwiftShims {

    /// `SdkObject` = `SwiftObject`
    static func sdkObjectFromSwiftObject(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if !rhs.isInOutParm,
           let lhsDeclRef = lhs.type.canonical.asDeclRef,
           let lhsDecl = lhsDeclRef.decl.canonical as? SwiftObject,
           let rhsDeclRef = rhs.type.canonical.asDeclRef,
           let rhsDecl = rhsDeclRef.decl.canonical as? SwiftObject,
           lhsDecl === rhsDecl.sdk,
           !lhsDecl.inSwiftEOS,
           rhsDecl.inSwiftEOS {
            return nested.member(.function.buildSdkObject())
        }

        return nil
    }
}
