
import Foundation

public final class SwiftIsExpr: SwiftBinaryExpr {

    public let lhs: SwiftExpr
    public let rhs: SwiftExpr

    public init(lhs: SwiftExpr, rhs: SwiftExpr) {
        self.lhs = lhs
        self.rhs = rhs
    }

    public override func perform<R>(_ action: (SwiftExpr) -> R?) -> R? {
        return action(self) ?? lhs.perform(action) ?? rhs.perform(action)
    }

    public override func evaluateType(in context: SwiftDeclContext?) -> SwiftType? {
        return .bool
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(lhs)
        swift.write(name: "is")
        swift.write(rhs)
    }
}
