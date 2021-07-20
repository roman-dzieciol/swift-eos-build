
import Foundation
import SwiftAST


extension SwiftShims {

    static func withCCharPointerPointersReturnedAsOptionalString(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if let lhsPointer = lhs.type.canonical.asPointer,
           let lhsBuiltin = lhsPointer.pointeeType.asBuiltin,
           let lhsArrayCount = lhs.linked(.arrayLength) as? SwiftVarDecl,
           lhsArrayCount.swifty != nil,
           lhsBuiltin.isCChar,
           let rhsBuiltin = rhs.type.canonical.asBuiltin,
           rhsBuiltin.isString,
           rhs.isInOutParm
        {
            return .function.throwingNilResult(
                .function.withCCharPointerPointersReturnedAsOptionalString(
                    bufferPointerName: rhs.name,
                    countPointerName: lhsArrayCount.name,
                    nest: nested
                ))
        }
        return nil
    }
}

extension SwiftExpr.function {

    static func withCCharPointerPointersReturnedAsOptionalString(
        bufferPointerName: String,
        countPointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withCCharPointerPointersReturnedAsOptionalString", args: [
            .closure([bufferPointerName, countPointerName], nest: nest) ])
    }
}
