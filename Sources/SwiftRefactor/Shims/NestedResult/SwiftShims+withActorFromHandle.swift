
import Foundation
import SwiftAST


extension SwiftShims {

    /// With `Actor` result from`() -> Handle`
    static func withActorFromHandle(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

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

extension SwiftExpr.function {

    /// With `Actor` result from`() -> Handle`
    static func withActorFromHandle(
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withActorFromHandle", args: [.closure([], nest: nest) ])
    }
}
