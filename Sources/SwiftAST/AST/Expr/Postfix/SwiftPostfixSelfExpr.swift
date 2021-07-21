
import Foundation

public final class SwiftPostfixSelfExpr: SwiftPostfixExpr {

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
        return context?.evaluateType()
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(expr)
        swift.write(token: ".")
        swift.write(name: "self")
    }
}
