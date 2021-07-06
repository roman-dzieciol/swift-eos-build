

import Foundation
import SwiftAST

public typealias SwiftyError = SwiftRefactorError

public enum SwiftRefactorError: Error {
    case assignmentToSelf(Any)
    case unknownTypecast(SwiftVarDecl, SwiftVarDecl)
    case unknownPointerCast(SwiftVarDecl, SwiftVarDecl)
    case unknownCopy(SwiftVarDecl, SwiftVarDecl)
    case unknownExprType(SwiftExpr)
    case unknownExprTypeIn(SwiftExpr, SwiftDeclContext)
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
