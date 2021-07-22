
import Foundation


final public class SwiftCodeBlock: SwiftExpr {

    public let statements: [SwiftStmt]

    public init(
        statements: [SwiftStmt]
    ) {
        self.statements = statements
    }

    public override func perform<R>(_ action: (SwiftExpr) -> R?) -> R? {
        return action(self) ?? statements.firstNonNil {  $0.perform(action) }
    }

    public override func evaluateType(in context: SwiftDeclContext?) -> SwiftType? {
        for statement in statements {
            if let evaluatedType = statement.evaluateType(in: context) {
                return evaluatedType
            }
        }
        return nil
    }

    public override func evaluateThrowing() -> Bool {
        for statement in statements {
            if statement.evaluateType(in: nil) != nil {
                return statement.evaluateThrowing()
            }
        }
        return false
    }

    public override func write(to swift: SwiftOutputStream) {
        let statements = statements.filter {
            if let builder = $0 as? SwiftExprBuilder, builder.expr == nil {
                return false
            }
            return true
        }
        swift.write(statements, separated: "\n")
    }
}
