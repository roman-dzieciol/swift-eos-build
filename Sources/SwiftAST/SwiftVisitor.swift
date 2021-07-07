
import Foundation

open class SwiftVisitor {

    public private(set) var stack: [SwiftAST] = []
    public private(set) var typeStack: [SwiftType] = []

    public init() {}

    public var stackPath: String {
        stack.map { $0.name }.joined(separator: ".")
    }

    open func visit(ast: SwiftAST) throws {
        stack.append(ast)
        defer { stack.removeLast() }
        try ast.handle(visitor: self)
    }

    open func visitReplacing(type: inout SwiftType) throws {
        let newType = try visit(type: type)
        if newType !== type {
            type = newType
        }
    }

    open func visit(type: SwiftType) throws -> SwiftType {
        typeStack.append(type)
        defer { typeStack.removeLast() }
        return try type.handle(visitor: self)
    }
}

