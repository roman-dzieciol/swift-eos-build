
import Foundation

public final class SwiftAsExpr: SwiftBinaryExpr {

    public let isOptional: Bool?
    public let lhs: SwiftExpr
    public let rhs: SwiftExpr

    public init(lhs: SwiftExpr, isOptional: Bool?, rhs: SwiftExpr) {
        self.isOptional = isOptional
        self.lhs = lhs
        self.rhs = rhs
    }

    public override func perform<R>(_ action: (SwiftExpr) -> R?) -> R? {
        return action(self) ?? lhs.perform(action) ?? rhs.perform(action)
    }

    public override func evaluateType(in context: SwiftDeclContext?) -> SwiftType? {
        if isOptional != false {
            return rhs.evaluateType(in: context)?.optional
        } else {
            return rhs.evaluateType(in: context)
        }
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(lhs)
        swift.write(name: "as" + SwiftName.token(isOptional: isOptional))
        swift.write(rhs)
    }
}
