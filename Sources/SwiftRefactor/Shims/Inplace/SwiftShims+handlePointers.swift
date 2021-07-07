
import Foundation
import SwiftAST


extension SwiftShims {

    static func handlePointers(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        // *Handle pointers
        if lhs.type.canonical.isPointer,
           rhs.type.canonical.isPointer,
           lhs.name.hasSuffix("Handle"),
           rhs.name.hasSuffix("Handle") {
            return nested
        }
        return nil
    }
}
