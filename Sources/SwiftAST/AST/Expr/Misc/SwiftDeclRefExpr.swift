
import Foundation

public final class SwiftDeclRefExpr: SwiftPrimaryExpr {

    public let declRef: SwiftDeclRefType

    public init(declRef: SwiftDeclRefType) {
        self.declRef = declRef
    }

    public override func evaluateType(in context: SwiftDeclContext?) -> SwiftType? {
        return declRef
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(declRef.decl.name)
    }
}

extension SwiftDeclRefType {

    public var declRefExpr: SwiftDeclRefExpr {
        .init(declRef: self)
    }
}
