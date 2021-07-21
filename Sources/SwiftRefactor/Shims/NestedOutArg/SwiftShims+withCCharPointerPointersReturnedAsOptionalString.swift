
import Foundation
import SwiftAST


extension SwiftShims {

    static func withCCharPointerPointersReturnedAsString(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if let lhsPointer = lhs.type.canonical.asPointer,
           let lhsBuiltin = lhsPointer.pointeeType.asBuiltin,
           let lhsArrayCount = lhs.linked(.arrayLength) as? SwiftVarDecl,
           lhsArrayCount.swifty != nil,
           lhsBuiltin.isCChar,
           let rhsBuiltin = rhs.type.canonical.asBuiltin,
           rhsBuiltin.isString,
           rhs.isInOutParm
        {
            return .function.withCCharPointerPointersReturnedAsString(
                    bufferPointerName: rhs.name,
                    countPointerName: lhsArrayCount.name,
                    nest: nested
                )
        }
        return nil
    }
}

extension SwiftExpr.function {

    static func withCCharPointerPointersReturnedAsString(
        bufferPointerName: String,
        countPointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withCCharPointerPointersReturnedAsString", args: [
            .closure([bufferPointerName, countPointerName], nest: nest) ])
    }
}
