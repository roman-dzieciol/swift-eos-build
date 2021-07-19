
import Foundation

public class SwiftStatementsBuilder: SwiftExpr {


    public var statements: [SwiftStmt]

    public init(
        statements: [SwiftStmt] = []
    ) {
        self.statements = statements
    }

    public override func evaluateType(in context: SwiftDeclContext?) -> SwiftType? {
        return nil
    }

    public override func evaluateThrowing() -> Bool {
        return statements.contains(where: { $0.evaluateThrowing() })
    }

    public override func write(to swift: SwiftOutputStream) {
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