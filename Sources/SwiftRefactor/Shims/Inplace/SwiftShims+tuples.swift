
import Foundation
import SwiftAST


extension SwiftShims {

    static func tuples(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {


        // TODO: Tuples
        if let lhsBuiltin = lhs.type.canonical.asBuiltin,
           let rhsBuiltin = rhs.type.canonical.asBuiltin,
           lhsBuiltin == rhsBuiltin,
           lhsBuiltin.builtinName.hasPrefix("("),
           lhsBuiltin.builtinName.hasSuffix(")"),
           lhs.name == "SocketName" {
            return nested
        }
        
        return nil
    }
}
