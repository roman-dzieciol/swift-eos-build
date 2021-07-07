
import Foundation
import SwiftAST


extension SwiftShims {

    static func returningTransformedResult(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        let rhsExpr = rhs.expr

        if let shimmed = try rhsExpr.shimmed(.immutableShims, lhs: lhs, rhs: rhs),
           shimmed !== rhsExpr {
            return .function.returningTransformedResult(
                transformedResult: shimmed,
                nested: nested
            )
        }

        return nil
    }
}

extension SwiftExpr.function {

    static func returningTransformedResult(
        transformedResult: SwiftExpr,
        nested: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named(
            "returningTransformedResult",
            args: [
                .closure([], nest: nested, identifier: .string("nested")),
                .closure([], nest: transformedResult, identifier: .string("transformedResult")),
            ],
            useTrailingClosures: false
        )
    }
}
