
import Foundation

public final class SwiftMemberExpr: SwiftPrimaryExpr {

    public let member: SwiftExpr

    public init(member: SwiftIdentifier) {
        self.member = member
    }

    public override func evaluateType(in context: SwiftDeclContext?) -> SwiftType? {
        return member.evaluateType(in: context)
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(token: ".")
        swift.write(member)
    }
}
