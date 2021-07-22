
import Foundation


final public class SwiftStatementsBuilder: SwiftExpr {

    public var statements: [SwiftStmt]

    public init(
        statements: [SwiftStmt] = []
    ) {
        self.statements = statements
    }

    public override func perform<R>(_ action: (SwiftExpr) -> R?) -> R? {
        return action(self) ?? statements.firstNonNil {  $0.perform(action) }
    }

    public override func evaluateType(in context: SwiftDeclContext?) -> SwiftType? {
        return nil
    }

    public override func evaluateThrowing() -> Bool {
        return statements.contains(where: { $0.evaluateThrowing() })
    }

    public override func write(to swift: SwiftOutputStream) {
        let statements = statements.filter {
            if let builder = $0 as? SwiftExprBuilder, builder.expr == nil {
                return false
            }
            return true
        }
        if !statements.isEmpty {
            swift.write(statements, separated: "\n")
        }
    }

    public func append(_ element: SwiftStmt) {
        statements.append(element)
    }

    public static func += (lhs: inout SwiftStatementsBuilder, rhs: [SwiftStmt]) {
        lhs.statements += rhs
    }
}
