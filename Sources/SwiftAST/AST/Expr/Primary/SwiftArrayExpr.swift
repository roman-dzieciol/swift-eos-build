
import Foundation

public final class SwiftArrayExpr: SwiftPrimaryExpr {

    public let items: [SwiftExpr]

    public var itemType: SwiftType

    public init(items: [SwiftExpr], itemType: SwiftType) {
        self.items = items
        self.itemType = itemType
    }

    public override func perform<R>(_ action: (SwiftExpr) -> R?) -> R? {
        return action(self) ?? items.firstNonNil { $0.perform(action) }
    }

    public override func evaluateType(in context: SwiftDeclContext?) -> SwiftType? {
        return itemType
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(token: "[")
        swift.write(items, separated: ",")
        swift.write(token: "]")
    }
}
