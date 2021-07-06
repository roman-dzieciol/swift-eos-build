
import Foundation
import SwiftAST


extension SwiftShims {

    static func voidPointerWorkarounds(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        // Void pointer exceptions
        if let lhsPointer = lhs.type.canonical.asPointer,
           let rhsPointer = rhs.type.canonical.asPointer,
           lhsPointer.pointeeType.isVoid,
           rhsPointer.pointeeType.isVoid {
            if (lhs.name == "ClientData" ||
                lhs.name == "SystemAuthCredentialsOptions" ||
                lhs.name == "SystemInitializeOptions") {
                return nested
            }
            if lhs.name.contains("Reserved") {
                return .string("nil")
            }
        }

        return nil
    }
}
