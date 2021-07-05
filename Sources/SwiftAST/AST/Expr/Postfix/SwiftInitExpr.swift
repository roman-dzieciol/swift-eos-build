
import Foundation

public final class SwiftInitExpr: SwiftFunctionCallExpr {

    public var isTypeByName: Bool {
        evaluateType(in: nil) is SwiftDeclRefType
    }

    public override func evaluateType(in context: SwiftDeclContext?) -> SwiftType? {
        return expr.evaluateType(in: context)
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(expr)
        if !isTypeByName {
            swift.write(token: ".")
            swift.write(name: "init")
        }
        swift.write(args)
    }
}
