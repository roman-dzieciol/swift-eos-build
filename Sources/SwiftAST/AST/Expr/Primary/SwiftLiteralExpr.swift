
import Foundation

public final class SwiftLiteralExpr: SwiftPrimaryExpr {

    public let literal: () -> String
    public let literalType: SwiftType

    public init(literal: @autoclosure @escaping () -> String, literalType: SwiftType) {
        self.literal = literal
        self.literalType = literalType
    }

    public override func evaluateType(in context: SwiftDeclContext?) -> SwiftType? {
        return literalType
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(name: literal())
    }
}



extension SwiftIdentifier {

    public static func string(_ text: @autoclosure @escaping () -> String) -> SwiftLiteralExpr {
            .init(literal: text(), literalType: .string)
    }

}
