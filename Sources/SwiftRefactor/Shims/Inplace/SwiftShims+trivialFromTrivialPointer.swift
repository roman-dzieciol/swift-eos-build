
import Foundation
import SwiftAST


extension SwiftShims {

    /// `TrivialValue?` = `Pointer<TrivialValue>?`
    static func trivialFromTrivialPointer(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        let lhsCanonical = lhs.type.canonical

        if !rhs.isInOutParm,
           lhsCanonical.isTrivial,
           let rhsPointer = rhs.type.canonical.asPointer,
           rhsPointer.pointeeType.isTrivial,
           lhsCanonical.optional == rhsPointer.pointeeType.optional {
            return nested.member(.string("pointee"))
        }

        return nil
    }
}
