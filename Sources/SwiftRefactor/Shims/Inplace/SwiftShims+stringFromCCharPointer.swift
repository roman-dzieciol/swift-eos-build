
import Foundation
import SwiftAST


extension SwiftShims {

    /// `String` = `Pointer<CChar>`
    static func stringFromCCharPointer(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if lhs.type.canonical.asString != nil,
           rhs.type.canonical.asPointer?.pointeeType.asCChar != nil {
            return .function.stringFromOptionalCStringPointer(nested)
        }

        
        return nil
    }
}
