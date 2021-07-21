
import Foundation


/**
 GRAMMAR OF AN EXPRESSION

 expression → try-operator opt await-operator opt prefix-expression binary-expressions opt

 expression-list → expression | expression , expression-list
 */
public class SwiftExpr: SwiftOutputStreamable, CustomStringConvertible {

    public static let `nil` = SwiftExpr.string("nil")
    public static let `false` = SwiftExpr.string("false")
    public static let `true` = SwiftExpr.string("true")
    public static let `empty` = SwiftExpr.string(".empty")
    public static let `zero` = SwiftExpr.string(".zero")
    public static let todo = SwiftExpr.string("/* TODO: this */")

    public var description: String {
        SwiftWriterString.description(for: self)
    }

    public func perform<R>(_ action: (SwiftExpr) -> R?) -> R? {
        return action(self)
    }

    public func evaluateType(in context: SwiftDeclContext?) -> SwiftType? {
        nil
    }

    public func evaluateThrowing() -> Bool {
        false
    }

    public func write(to swift: SwiftOutputStream) {
        fatalError()
    }
}


public final class SwiftTempExpr: SwiftExpr {

    public let output: SwiftOutputStreamable

    public init(output: SwiftOutputStreamable) {
        self.output = output
    }

    public init(output: @escaping (SwiftOutputStream) -> Void) {
        self.output = SwiftCode { swift in
            output(swift)
        }
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(output)
    }
}


extension SwiftExpr {

    public var optional: SwiftExpr {
        SwiftOptionalChainingExpr(expr: self)
    }

    public func arg(_ identifier: SwiftExpr?) -> SwiftFunctionCallArgExpr {
        SwiftFunctionCallArgExpr(identifier: identifier, expr: self)
    }

    public func arg(_ string: String) -> SwiftFunctionCallArgExpr {
        SwiftFunctionCallArgExpr(identifier: .string(string), expr: self)
    }

    public func member(_ string: String) -> SwiftExplicitMemberExpr {
        member(.string(string))
    }

    public func member(_ expr: SwiftExpr) -> SwiftExplicitMemberExpr {
        if !(self is SwiftOptionalChainingExpr),
           !(expr is SwiftOptionalChainingExpr),
           let type = self.evaluateType(in: nil),
           type.isOptional != false {
            return SwiftExplicitMemberExpr(expr: self.optional, identifier: expr, argumentNames: [])
        } else {
            return SwiftExplicitMemberExpr(expr: self, identifier: expr, argumentNames: [])
        }
    }
}
