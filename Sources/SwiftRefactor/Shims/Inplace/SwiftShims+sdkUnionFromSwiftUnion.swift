
import Foundation
import SwiftAST


extension SwiftShims {

    /// TODO: `SDK Union` = `Swifty Union`
    static func sdkUnionFromSwiftUnion(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if lhs.type.canonical.isUnion,
           rhs.type.canonical.isUnion {
            return nested
        }

        return nil
    }
}
