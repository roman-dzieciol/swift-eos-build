
import Foundation
import SwiftAST


extension SwiftShims {

    static func withActorFromHandle(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        // Actor = actor handle
        if let lhsObject = lhs.type.canonical.asDeclRef?.decl as? SwiftObject,
           lhsObject.name.hasSuffix("_Actor"),
           let lhsHandle = lhsObject.members.first(where: { $0.name == "Handle" }),
           let lhsOpaque = lhsHandle.type.canonical.asOpaquePointer?.pointeeType.asOpaque,
           let rhsOpaque = rhs.type.canonical.asOpaquePointer?.pointeeType.asOpaque,
           lhsOpaque == rhsOpaque
        {
            return .function.withActorFromHandle(nest: nested)
        }

        return nil
    }
}
