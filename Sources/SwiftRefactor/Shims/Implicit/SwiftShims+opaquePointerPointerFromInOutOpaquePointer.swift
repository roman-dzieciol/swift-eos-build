
import Foundation
import SwiftAST


extension SwiftShims {

    static func opaquePointerPointerFromInOutOpaquePointer(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if let lhsPointer = lhs.type.canonical.asPointer,
           let lhsPointerPointer = lhsPointer.pointeeType.asPointer,
           let rhsPointer = rhs.type.canonical.asPointer,
           let lhsOpaque = lhsPointerPointer.pointeeType.asOpaque,
           let rhsOpaque = rhsPointer.pointeeType.asOpaque,
           lhsOpaque == rhsOpaque {
            return .inout(nested)
        }

        return nil
    }
}
