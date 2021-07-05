
import Foundation
import SwiftAST


extension SwiftShims {

    static func withStringResult(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        // `String` = `Pointer<CChar>`
        if lhs.type.canonical.asString != nil,
           rhs.type.canonical.asPointer?.pointeeType.asCChar != nil {
            return .function.withStringResult(nested)
        }
        return nil
    }
}
