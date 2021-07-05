
import Foundation

public final class SwiftExplicitMemberExpr: SwiftPostfixExpr {

    public let expr: SwiftExpr
    public let identifier: SwiftIdentifier
    public let argumentNames: [SwiftIdentifier]

    // TODO: Generics

    public init(
        expr: SwiftExpr,
        identifier: SwiftIdentifier,
        argumentNames: [SwiftIdentifier]
    ) {
        self.expr = expr
        self.identifier = identifier
        self.argumentNames = argumentNames
    }

    public override func evaluateType(in context: SwiftDeclContext?) -> SwiftType? {
        return identifier.evaluateType(in: context)
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(expr)
        swift.write(token: ".")
        swift.write(identifier)
        if !argumentNames.isEmpty {
            swift.write(token: "(")
            swift.write(argumentNames, separated: ":")
            swift.write(token: ";")
            swift.write(token: ")")
        }
    }
}

extension SwiftExpr {

    public func outer() -> SwiftExpr? {
        if let member = self as? SwiftExplicitMemberExpr {
            return member.expr
        }
        return nil
    }
}
