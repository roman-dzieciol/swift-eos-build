
import Foundation
import SwiftAST


extension SwiftShims {

    /// TODO: Tuples
    static func tuples(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if let lhsBuiltin = lhs.type.canonical.asBuiltin,
           let rhsBuiltin = rhs.type.canonical.asBuiltin,
           lhsBuiltin == rhsBuiltin,
           lhsBuiltin.isFixedWidthString {
            if lhs.inSwiftEOS, lhs.sdk === rhs {
                return SwiftFunctionCallExpr.named(lhsBuiltin.builtinName, args: [nested.arg("tuple")])
            } else if rhs.inSwiftEOS, lhs === rhs.sdk {
                return nested.member(SwiftFunctionCallExpr.named("tuple", args: []))
            } else {
                return nested
            }
        }
        
        return nil
    }
}
