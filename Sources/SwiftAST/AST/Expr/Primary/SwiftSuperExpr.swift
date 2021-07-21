
import Foundation

public class SwiftSuperExpr: SwiftPrimaryExpr {
}

public final class SwiftSuperMethodExpr: SwiftSuperExpr {

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
        swift.write(name: "super")
        swift.write(token: ".")
        swift.write(identifier)
    }
}

public final class SwiftSuperSubscriptExpr: SwiftSuperExpr {

    public let function: SwiftExpr

    public init(function: SwiftExpr) {
        self.function = function
    }

    public override func perform<R>(_ action: (SwiftExpr) -> R?) -> R? {
        return action(self) ?? function.perform(action)
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(name: "super")
        swift.write(token: "[")
        swift.write(function)
        swift.write(token: "]")
    }
}
