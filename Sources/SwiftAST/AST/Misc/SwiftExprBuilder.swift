
import Foundation


public class SwiftExprBuilder: SwiftExpr {

    public var expr: SwiftExpr?
    
    public init(
        expr: SwiftExpr? = nil
    ) {
        self.expr = expr
    }

    public override func evaluateType(in context: SwiftDeclContext?) -> SwiftType? {
        return expr?.evaluateType(in: context)
    }

    public override func evaluateThrowing() -> Bool {
        return expr?.evaluateThrowing() == true
    }

    public override func write(to swift: SwiftOutputStream) {
        if let expr = expr {
            swift.write(expr)
        }
    }
}
