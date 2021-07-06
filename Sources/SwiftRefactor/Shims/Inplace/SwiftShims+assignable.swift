
import Foundation
import SwiftAST

extension SwiftShims {

    static func assignable(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if try canAssign(lhs: lhs, rhs: rhs, options: []) {
            return nested
        }
        return nil
    }
}
