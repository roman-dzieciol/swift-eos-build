
import Foundation

public final class SwiftParenthesizedExpr: SwiftPrimaryExpr {

    public let expr: SwiftExpr

    public init(expr: SwiftExpr) {
        self.expr = expr
    }

    public override func evaluateType(in context: SwiftDeclContext?) -> SwiftType? {
        return expr.evaluateType(in: context)
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(token: "(")
        swift.write(expr)
        swift.write(token: ")")
    }
}
