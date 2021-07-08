
import Foundation
import SwiftAST


extension SwiftOutputStream {

    public func write(debug comment: String, lhs: SwiftVarDecl, rhs: SwiftVarDecl) {
        write(textIfNeeded: "\n")
        write(text: "/* \(comment) -- \(lhs.name) = \(rhs.name)")
        write(textIfNeeded: "\n")
        write(text: "lhs: \(lhs.type)")
        write(textIfNeeded: "\n")
        write(text: "rhs: \(rhs.type)")
        write(textIfNeeded: "\n")
        write(text: "aka lhs: \(lhs.type.canonical)")
        write(textIfNeeded: "\n")
        write(text: "aka rhs: \(rhs.type.canonical)")
        write(textIfNeeded: "\n")
        write(text: "stack: \(stack)")
        write(textIfNeeded: "\n")
        write(text: "*/")
        write(textIfNeeded: "\n")
    }
}

public func dbgVar(_ lhs: SwiftVarDecl, _ rhs: SwiftVarDecl) {
    print("lhs: \(lhs.name) \(lhs.type)")
    print("rhs: \(rhs.name) \(rhs.type)")
    print("aka lhs: \(lhs.type.canonical)")
    print("aka rhs: \(rhs.type.canonical)")
}


public func dbg(_ error: SwiftyError) {


    switch error {
    case let .assignmentToSelf(item):
        print("assignmentToSelf: \(item)")

    case let .unknownTypecast(lhs, rhs):
        dbgVar(lhs, rhs)

    case let .unknownPointerCast(lhs, rhs):
        dbgVar(lhs, rhs)


    case let .unknownCopy(lhs, rhs):
        dbgVar(lhs, rhs)

    case let .unknownExprType(expr):
        print("unknownExprType: \(expr)")

    case let .unknownExprTypeIn(expr, declContext):
        print("unknownExprType: \(expr) in \(declContext)")

    }
}

