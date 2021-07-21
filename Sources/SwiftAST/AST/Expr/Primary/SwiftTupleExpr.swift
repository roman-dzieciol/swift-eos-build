
import Foundation

public final class SwiftTupleExpr: SwiftPrimaryExpr {

    public let items: [SwiftTupleItemExpr]

    public init(items: [SwiftTupleItemExpr]) {
        self.items = items
    }

    public override func perform<R>(_ action: (SwiftExpr) -> R?) -> R? {
        return action(self) ?? items.firstNonNil { $0.perform(action) }
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(token: "(")
        swift.write(items, separated: ",")
        swift.write(token: ")")
    }
}

public final class SwiftTupleItemExpr: SwiftExpr {

    public let identifier: SwiftIdentifier
    public let expr: SwiftExpr

    public init(identifier: SwiftIdentifier, expr: SwiftExpr) {
        self.identifier = identifier
        self.expr = expr
    }

    public override func perform<R>(_ action: (SwiftExpr) -> R?) -> R? {
        return action(self) ?? identifier.perform(action) ?? expr.perform(action)
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(identifier)
        swift.write(token: ":")
        swift.write(expr)
    }
}
