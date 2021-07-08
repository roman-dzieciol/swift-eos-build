

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
