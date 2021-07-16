
import Foundation
import SwiftAST


extension SwiftShims {

    /// TODO: `Swifty Union` = `SDK Union`
    static func swiftUnionFromSdkUnion(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if lhs.type.canonical.isUnion,
           rhs.type.canonical.isUnion {
            return nested
        }

        return nil
    }
}
