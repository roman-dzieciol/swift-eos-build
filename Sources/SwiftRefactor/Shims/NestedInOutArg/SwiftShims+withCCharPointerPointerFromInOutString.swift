
import Foundation
import SwiftAST


extension SwiftShims {

    static func withCCharPointerPointersFromInOutString(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if let lhsPointer = lhs.type.canonical.asPointer,
           let lhsBuiltin = lhsPointer.pointeeType.asBuiltin,
           let lhsArrayCount = lhs.linked(.arrayLength) as? SwiftVarDecl,
           let rhsArrayCount = lhsArrayCount.swifty,
           lhsBuiltin.isCChar,
           let rhsBuiltin = rhs.type.canonical.asBuiltin,
           rhsBuiltin.isString,
           rhs.isInOutParm
        {
            if let inOutArrayCountInvocationDecl = rhsArrayCount.linked(.invocation) as? SwiftDecl {

                let arrayCountExpr = inOutArrayCountInvocationDecl.expr.member(.string(lhsArrayCount.name))

                if rhs.type.isOptional != false {
                    return .function.withCCharPointerFromInOutOptionalString(
                        inoutOptionalString: rhs.expr.inout,
                        bufferPointerName: rhs.name,
                        arrayCount: arrayCountExpr,
                        nest: nested)
                } else {
                    return .function.withCCharPointerFromInOutString(
                        inoutString: rhs.expr.inout,
                        bufferPointerName: rhs.name,
                        arrayCount: arrayCountExpr,
                        nest: nested)
                }

            } else {

                if rhs.type.isOptional != false {
                    return .function.withCCharPointerPointersFromInOutOptionalString(
                        inoutOptionalString: rhs.expr.inout,
                        bufferPointerName: rhs.name,
                        countPointerName: lhsArrayCount.name,
                        nest: nested)
                } else {
                    return .function.withCCharPointerPointersFromInOutString(
                        inoutString: rhs.expr.inout,
                        bufferPointerName: rhs.name,
                        countPointerName: lhsArrayCount.name,
                        nest: nested)
                }
            }

        }
        return nil
    }
}
