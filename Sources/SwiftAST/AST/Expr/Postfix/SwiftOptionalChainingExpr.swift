
import Foundation

public final class SwiftOptionalChainingExpr: SwiftPostfixExpr {

    public let expr: SwiftExpr

    public init(
        expr: SwiftExpr
    ) {
        self.expr = expr
    }

    public override func evaluateType(in context: SwiftDeclContext?) -> SwiftType? {
        return expr.evaluateType(in: context)?.optional
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(expr)
        swift.write(token: "?")
    }
}
