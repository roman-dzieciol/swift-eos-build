
import Foundation
import SwiftAST

extension SwiftShims {

    static func withTransformed(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        guard !rhs.isInOutParm else { return nil }

        let rhsExpr = rhs.type.isOptional == false ? rhs.expr : rhs.expr.optional

        if let shimmed = try rhsExpr.shimmed(.immutableShims, lhs: lhs, rhs: rhs),
           shimmed !== rhsExpr {
            return .function.withTransformed(
                value: rhs.expr,
                transform: shimmed,
                transformedName: lhs.name,
                nested: nested
            )
        }

        return nil
    }
}

extension SwiftExpr.function {

    static func withTransformed(
        value: SwiftExpr,
        transform: SwiftExpr,
        transformedName: String,
        nested: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named(
            "withTransformed",
            args: [
                value.arg("value"),
                .closure([transformedName], nest: transform, identifier: .string("transform")),
                .closure([transformedName], nest: nested, identifier: .string("nested")),
            ],
            useTrailingClosures: false
        )
    }
}
