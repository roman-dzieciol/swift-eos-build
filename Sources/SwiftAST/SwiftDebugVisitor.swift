

import Foundation



public func dbg(_ decl: SwiftAST) {
    SwiftDebugVisitor.write(ast: decl)
}

public class SwiftDebugVisitor: SwiftVisitor {

    var output: String = ""
    var indent: String = ""
    let indentSpacing = 1

    public static func write(ast: SwiftAST) {
        let visitor = SwiftDebugVisitor()
        try! visitor.visit(ast: ast)
        print(visitor.output)
    }

    func debugName(for ast: SwiftAST) -> String {
        switch ast {
        case let ast as SwiftObject:
            return ast.tagName
        case is SwiftFunction:
            return "func "
        case is SwiftVarDecl:
            return "var "
        case is SwiftTypealias:
            return "typealias "
        default:
            return ""//\(type(of: ast))"
        }
    }

    public override func visit(ast: SwiftAST) throws {
        output += "\n"
        output += indent

        switch ast {
        case let ast as SwiftObject:
            output += ast.tagName
        case let ast as SwiftFunction:
            output += "func "
            output += ast.name
            output += " ->"

        case is SwiftVarDecl:
            output += "var "
            output += ast.name
            output += ":"

        case let ast as SwiftTypealias:
            output += "typealias "
            output += ast.name
            output += " ="

        default:
            output += ast.name
            output += ":"
        }

        try indent {
            try super.visit(ast: ast)
        }
    }

    public override func visit(type: SwiftType) throws -> SwiftType {
//        output += indent
        output += " "
        let typeName = "\(Swift.type(of: type))"
            .replacingOccurrences(of: "Swift", with: "")
            .replacingOccurrences(of: "Type", with: "")

        switch type {
        case let type as SwiftBuiltinType:
            output += type.builtinName

        case let type as SwiftPointerType:
            output += "Ptr<"
            let result = try indent { return try super.visit(type: type) }
            output += ">"
            return result

        case let type as SwiftArrayType:
            output += "["
            let result = try indent { return try super.visit(type: type) }
            output += "]"
            return result

        case let type as SwiftDeclRefType:
            output += type.decl.name

        default:
            output += typeName
        }

        output += " "
        return try indent { return try super.visit(type: type) }
    }

    func indent<R>(_ action: () throws -> R) rethrows -> R {
        indent.append(String(repeating: " ", count: indentSpacing))
        defer {
            indent.removeLast(indentSpacing)
        }
        return try action()
    }
}
