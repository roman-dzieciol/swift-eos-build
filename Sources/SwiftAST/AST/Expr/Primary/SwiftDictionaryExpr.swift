
import Foundation

public final class SwiftDictionaryExpr: SwiftPrimaryExpr {

    public let items: [(SwiftExpr,SwiftExpr)]

    public init(items: [(SwiftExpr,SwiftExpr)]) {
        self.items = items
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(token: "[")
        if items.isEmpty {
            swift.write(token: ":")
        } else {
            for (index, item) in items.enumerated() {
                swift.write(item.0)
                swift.write(token: ":")
                swift.write(item.1)
                if index != items.indices.last {
                    swift.write(token: ",")
                }
            }
        }
        swift.write(token: "]")
    }
}
