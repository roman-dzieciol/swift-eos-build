
import Foundation

public final class SwiftForcedValueExpr: SwiftPostfixExpr {

    public let expr: SwiftExpr

    public init(
        expr: SwiftExpr
    ) {
        self.expr = expr
    }

    public override func perform<R>(_ action: (SwiftExpr) -> R?) -> R? {
        return action(self) ?? expr.perform(action)
    }

    public override func evaluateType(in context: SwiftDeclContext?) -> SwiftType? {
        return expr.evaluateType(in: context)?.nonOptional
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(expr)
        swift.write(token: "!")
    }
}
