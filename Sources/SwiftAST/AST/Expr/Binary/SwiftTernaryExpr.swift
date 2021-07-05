
import Foundation

public final class SwiftTernaryExpr: SwiftBinaryExpr {

    public let condition: SwiftExpr
    public let lhs: SwiftExpr
    public let rhs: SwiftExpr

    public init(condition: SwiftExpr, lhs: SwiftExpr, rhs: SwiftExpr) {
        self.condition = condition
        self.lhs = lhs
        self.rhs = rhs
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(condition)
        swift.write(token: "?")
        swift.write(lhs)
        swift.write(token: ":")
        swift.write(rhs)
    }
}
