
import Foundation

public class SwiftSelfExpr: SwiftPrimaryExpr {
}

public final class SwiftSelfMethodExpr: SwiftSelfExpr {

    public let identifier: SwiftIdentifier

    public init(identifier: SwiftIdentifier) {
        self.identifier = identifier
    }

    public override func perform<R>(_ action: (SwiftExpr) -> R?) -> R? {
        return action(self) ?? identifier.perform(action)
    }

    public override func evaluateType(in context: SwiftDeclContext?) -> SwiftType? {
        return identifier.evaluateType(in: context)
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(name: "self")
        swift.write(token: ".")
        swift.write(identifier)
    }
}

public final class SwiftSelfSubscriptExpr: SwiftSelfExpr {

    public let function: SwiftExpr

    public init(function: SwiftExpr) {
        self.function = function
    }

    public override func perform<R>(_ action: (SwiftExpr) -> R?) -> R? {
        return action(self) ?? function.perform(action)
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(name: "self")
        swift.write(token: "[")
        swift.write(function)
        swift.write(token: "]")
    }
}

extension SwiftExpr {
    public static func self_(_ identifier: SwiftIdentifier) -> SwiftSelfMethodExpr {
        SwiftSelfMethodExpr(identifier: identifier)
    }
}
