
import Foundation
import SwiftAST


extension SwiftShims {

    static func handlePointers(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        // *Handle pointers
        if let lhsPointer = lhs.type.canonical.asPointer,
           let rhsPointer = rhs.type.canonical.asPointer,
           lhs.name.hasSuffix("Handle"),
           rhs.name.hasSuffix("Handle") {
            return nested
        }
        return nil
    }
}
