
import Foundation

public final class SwiftTryExpr: SwiftPrefixExpr {

    public let isOptional: Bool?
    public let expr: SwiftExpr

    public init(isOptional: Bool?, expr: SwiftExpr) {
        self.isOptional = isOptional
        self.expr = expr
    }

    public override func evaluateType(in context: SwiftDeclContext?) -> SwiftType? {
        return expr.evaluateType(in: context)
    }

    public override func evaluateThrowing() -> Bool {
        isOptional == false
    }

    public override func write(to swift: SwiftOutputStream) {
        if !(expr is SwiftTryExpr) { // TODO
            swift.write(name: "try" + SwiftName.token(isOptional: isOptional))
        }
        swift.write(expr)
    }
}

extension SwiftExpr {
    
    public static func `try`(_ expr: SwiftExpr, isOptional: Bool = false) -> SwiftTryExpr {
        SwiftTryExpr(isOptional: isOptional, expr: expr)
    }
}
