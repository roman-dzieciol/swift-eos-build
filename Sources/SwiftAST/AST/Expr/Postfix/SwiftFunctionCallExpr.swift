
import Foundation

public class SwiftFunctionCallExpr: SwiftPostfixExpr {

    public let expr: SwiftExpr
    public let args: SwiftFunctionCallArgClauseExpr
    public let useTrailingClosures: Bool

    public init(
        expr: SwiftExpr,
        args: SwiftFunctionCallArgClauseExpr,
        useTrailingClosures: Bool
    ) {
        self.expr = expr
        self.args = args
        self.useTrailingClosures = useTrailingClosures
    }

    public convenience init(
        expr: SwiftExpr,
        args: [SwiftFunctionCallArgExpr],
        useTrailingClosures: Bool
    ) {
        self.init(expr: expr,
                  args: SwiftFunctionCallArgClauseExpr(
                    list: SwiftFunctionCallArgListExpr(
                        items: args,
                        useTrailingClosures: useTrailingClosures),
                    useTrailingClosures: useTrailingClosures),
                  useTrailingClosures: useTrailingClosures)
    }

    public override func evaluateType(in context: SwiftDeclContext?) -> SwiftType? {
        return expr.evaluateType(in: context)
    }

    public override func evaluateThrowing() -> Bool {
        expr.evaluateThrowing() || args.list.items.contains(where: { $0.evaluateThrowing() })
    }

    public override func write(to swift: SwiftOutputStream) {

        if !(swift.stack.dropLast(1).last is SwiftPostfixExpr), // TODO
           !(swift.stack.dropLast(1).last is SwiftTryExpr),
           !(expr is SwiftTryExpr),
           evaluateThrowing() {
            swift.write(SwiftTryExpr(isOptional: false, expr: expr))
        } else {
            swift.write(expr)
        }

        swift.write(args)

        if useTrailingClosures {
            let items = Array(args.list.trailingClosureItems)
            for (index, item) in items.enumerated() {
                if index > .zero {
                    swift.write(item.identifier)
                    swift.write(token: ":")
                }
                swift.write(item.expr)
            }
        } else {
        }
    }
}

public final class SwiftFunctionCallArgClauseExpr: SwiftExpr {

    public static let none = SwiftFunctionCallArgClauseExpr(list: .none, useTrailingClosures: false)

    public let list: SwiftFunctionCallArgListExpr
    public let useTrailingClosures: Bool

    public init(
        list: SwiftFunctionCallArgListExpr,
        useTrailingClosures: Bool
    ) {
        self.list = list
        self.useTrailingClosures = useTrailingClosures
    }

    public override func write(to swift: SwiftOutputStream) {
        if list.items.isEmpty || !list.itemsToWrite.isEmpty {
            swift.write(nested: "(", ")") {
                swift.write(list)
            }
        }
    }
}

public final class SwiftFunctionCallArgListExpr: SwiftExpr {

    public static let none = SwiftFunctionCallArgListExpr(items: [], useTrailingClosures: true)

    public let items: [SwiftFunctionCallArgExpr]
    public let useTrailingClosures: Bool
    public let nonTrailingClosureItems: Array<SwiftFunctionCallArgExpr>.SubSequence
    public let trailingClosureItems: Array<SwiftFunctionCallArgExpr>.SubSequence
    public let itemsToWrite: [SwiftFunctionCallArgExpr]

    public init(
        items: [SwiftFunctionCallArgExpr],
        useTrailingClosures: Bool
    ) {
        self.items = items
        self.useTrailingClosures = useTrailingClosures

        if items.filter({ $0.expr is SwiftClosureExpr}).count > 1 {

        }
        if useTrailingClosures {
            if let lastNonClosureIndex = items.lastIndex(where: { !($0.expr is SwiftClosureExpr) }) {
                self.nonTrailingClosureItems = items[...lastNonClosureIndex]
                self.trailingClosureItems = items[lastNonClosureIndex.advanced(by: 1)...]
                self.itemsToWrite = Array(nonTrailingClosureItems)
            } else {
                self.nonTrailingClosureItems = []
                self.trailingClosureItems = items[...]
                self.itemsToWrite = []
            }
        } else {
            self.nonTrailingClosureItems = items[...]
            self.trailingClosureItems = []
            self.itemsToWrite = items
        }
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(itemsToWrite, separated: ",")
    }
}

public class SwiftFunctionCallArgExpr: SwiftExpr {

    public let identifier: SwiftIdentifier?
    public let expr: SwiftExpr
    public let omitIdentifier: Bool

    public init(identifier: SwiftIdentifier?, expr: SwiftExpr) {
        self.identifier = identifier
        self.expr = expr
        self.omitIdentifier = identifier == nil
    }

    public convenience init(_ string: String?, expr: SwiftExpr) {
        self.init(identifier: string.map { .string($0) }, expr: expr)
    }

    public override func evaluateThrowing() -> Bool {
        expr.evaluateThrowing()
    }

    public override func write(to swift: SwiftOutputStream) {
        if !omitIdentifier, let identifier = identifier {
            swift.write(identifier)
            swift.write(token: ":")
        }
        swift.write(expr)
    }
}

extension SwiftFunctionParm {

    public func arg(_ expr: SwiftExpr) -> SwiftFunctionCallArgExpr {
        if let label = label, label != name {
            return SwiftFunctionCallArgExpr(identifier: .string(label), expr: expr)
        } else {
            return SwiftFunctionCallArgExpr(identifier: nil, expr: expr)

        }
    }
}

extension SwiftExpr {

    public func call(_ args: [SwiftFunctionCallArgExpr], useTrailingClosures: Bool = true) -> SwiftFunctionCallExpr {
        SwiftFunctionCallExpr(
            expr: self,
            args: SwiftFunctionCallArgClauseExpr(
                list: SwiftFunctionCallArgListExpr(
                    items: args,
                    useTrailingClosures: useTrailingClosures),
                useTrailingClosures: useTrailingClosures),
            useTrailingClosures: useTrailingClosures)

    }
}


extension SwiftFunction {
    public func call(_ args: [SwiftFunctionCallArgExpr], useTrailingClosures: Bool = true) -> SwiftFunctionCallExpr {
        self.expr.call(args, useTrailingClosures: useTrailingClosures)
    }
}


extension SwiftFunctionCallExpr {
    public static func named(_ name: @autoclosure @escaping () -> String,
                             args: [SwiftFunctionCallArgExpr],
                             useTrailingClosures: Bool = true
    ) -> SwiftFunctionCallExpr {
        return SwiftFunctionCallExpr(expr: .string(name()), args: args, useTrailingClosures: useTrailingClosures)
    }
}

extension SwiftFunctionCallArgExpr {
    public static func closure(captures: [String] = [], _ params: [String] = [], nest: SwiftExpr, identifier: SwiftExpr? = nil) -> SwiftFunctionCallArgExpr {
        return SwiftClosureExpr(captures: captures, params: params, statements: nest).arg(identifier)
    }

    public static func arg(_ label: String?, _ expr: SwiftExpr) -> SwiftFunctionCallArgExpr {
        if let label = label {
            return SwiftFunctionCallArgExpr(identifier: .string(label), expr: expr)
        } else {
            return SwiftFunctionCallArgExpr(identifier: nil, expr: expr)
        }
    }
}
