
import Foundation

public final class SwiftSubscriptExpr: SwiftPostfixExpr {

    public let expr: SwiftExpr
    public let args: SwiftFunctionCallArgListExpr

    public init(
        expr: SwiftExpr,
        args: SwiftFunctionCallArgListExpr
    ) {
        self.expr = expr
        self.args = args
    }

    public override func perform<R>(_ action: (SwiftExpr) -> R?) -> R? {
        return action(self) ?? expr.perform(action) ?? args.perform(action)
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(expr)
        swift.write(token: "[")
        swift.write(args)
        swift.write(token: "]")
    }
}
