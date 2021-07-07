
import Foundation
import SwiftAST


extension SwiftShims {

    /// With `Actor` result from`() -> Handle`
    static func returningActorFromHandle(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if let lhsObject = lhs.type.canonical.asDeclRef?.decl as? SwiftObject,
           lhsObject.name.hasSuffix("_Actor"),
           let lhsHandle = lhsObject.members.first(where: { $0.name == "Handle" }),
           let lhsOpaque = lhsHandle.type.canonical.asOpaquePointer?.pointeeType.asOpaque,
           let rhsOpaque = rhs.type.canonical.asOpaquePointer?.pointeeType.asOpaque,
           lhsOpaque == rhsOpaque
        {
            return .function.returningActorFromHandle(nest: nested)
        }

        return nil
    }
}

extension SwiftExpr.function {

    /// With `Actor` result from`() -> Handle`
    static func returningActorFromHandle(
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("returningActorFromHandle", args: [.closure([], nest: nest) ])
    }
}
