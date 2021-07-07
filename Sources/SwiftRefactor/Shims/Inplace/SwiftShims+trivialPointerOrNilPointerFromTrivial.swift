
import Foundation
import SwiftAST


extension SwiftShims {

    /// Managed `Pointer<TrivialValue>?` = `TrivialValue?`
    static func trivialPointerOrNilPointerFromTrivial(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        let rhsCanonical = rhs.type.canonical

        if !rhs.isInOutParm,
           let lhsPointer = lhs.type.canonical.asPointer,
           lhsPointer.pointeeType.isTrivial,
           rhsCanonical.isTrivial,
           lhsPointer.pointeeType.optional == rhsCanonical.optional {
            return .string("pointerManager").member(.function.managedPointer(copyingValueOrNilPointer: nested))
        }

        return nil
    }
}
