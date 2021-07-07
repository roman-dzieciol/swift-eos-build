
import Foundation
import SwiftAST


extension SwiftShims {

    /// Returns exact value of Int as another Int type, or throws error
    static func intFromAnotherInt(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if let lhsInt = lhs.type.canonical.asInt,
           let rhsInt = rhs.type.canonical.asInt,
           lhsInt.builtinName != rhsInt.builtinName {
            switch (lhsInt.builtinName, rhsInt.builtinName) {
            case ("UInt64", _):
                fatalError()

            case (_, "UInt64"):
                fatalError()

            default:
                return .try(.function.safeNumericCast(exactly: nested))
            }
        }
        
        return nil
    }
}
