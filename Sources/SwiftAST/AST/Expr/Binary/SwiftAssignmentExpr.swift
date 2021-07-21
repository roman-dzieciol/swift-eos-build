
import Foundation

public final class SwiftAssignmentExpr: SwiftBinaryExpr {

    public let lhs: SwiftExpr
    public let rhs: SwiftExpr

    public init(lhs: SwiftExpr, rhs: SwiftExpr) {
        self.lhs = lhs
        self.rhs = rhs
    }

    public override func perform<R>(_ action: (SwiftExpr) -> R?) -> R? {
        return action(self) ?? lhs.perform(action) ?? rhs.perform(action)
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(lhs)
        swift.write(token: "=")
        swift.write(rhs)
    }
}

extension SwiftExpr {

    public func assign(_ rhs: SwiftExpr) -> SwiftAssignmentExpr {
        SwiftAssignmentExpr(lhs: self, rhs: rhs)
    }

    public static func assignment(lhs: SwiftExpr, rhs: SwiftExpr) -> SwiftAssignmentExpr {
        SwiftAssignmentExpr(lhs: lhs, rhs: rhs)
    }
}
