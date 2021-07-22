

import Foundation

final public class SwiftExprRef: SwiftAST {

    public let expr: SwiftExpr

    public init(expr: SwiftExpr) {
        self.expr = expr
        super.init(name: "SwiftExprRef")
    }
}


extension SwiftExpr {

    public func link(ast: SwiftAST) {
        ast.link(.expr, ref: SwiftExprRef(expr: self))
    }
}
