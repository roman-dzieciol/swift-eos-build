
import Foundation

public final class SwiftImplicitMemberExpr: SwiftPrimaryExpr {

    public let identifier: SwiftIdentifier

    public init(identifier: SwiftIdentifier) {
        self.identifier = identifier
    }

    public override func evaluateType(in context: SwiftDeclContext?) -> SwiftType? {
        return identifier.evaluateType(in: context)
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(token: ".")
        swift.write(identifier)
    }
}
