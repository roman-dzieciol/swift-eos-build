
import Foundation

public final class SwiftInOutExpr: SwiftPrefixExpr {

    public let identifier: SwiftIdentifier

    public init(identifier: SwiftIdentifier) {
        self.identifier = identifier
    }

    public override func evaluateType(in context: SwiftDeclContext?) -> SwiftType? {
        return identifier.evaluateType(in: context)
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(token: "&")
        swift.write(identifier)
    }
}

extension SwiftExpr {
    public var `inout`: SwiftInOutExpr {
        SwiftInOutExpr(identifier: self)
    }

    public static func `inout`(_ identifier: SwiftIdentifier) -> SwiftInOutExpr {
        SwiftInOutExpr(identifier: identifier)
    }
}
