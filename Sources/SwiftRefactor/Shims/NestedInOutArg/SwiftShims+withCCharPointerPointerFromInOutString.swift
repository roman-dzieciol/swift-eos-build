
import Foundation
import SwiftAST


extension SwiftShims {

    /// With nested `Pointer<CChar>` from `inout String`
    /// With nested `Pointer<CChar>` from `inout Optional<String>`
    /// With nested `Pointer<Pointer<CChar>>, Int` from `inout Optional<String>`
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
                    return .function.eos_withCCharPointerForOutOptionalString(
                        outOptionalString: rhs.expr.inout,
                        bufferPointerName: rhs.name,
                        arrayCount: arrayCountExpr,
                        nest: nested)
                } else {
                    return .function.eos_withCCharPointerForOutString(
                        outString: rhs.expr.inout,
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
                }
//                else {
//                    return .function.withCCharPointerPointersFromInOutString(
//                        inoutString: rhs.expr.inout,
//                        bufferPointerName: rhs.name,
//                        countPointerName: lhsArrayCount.name,
//                        nest: nested)
//                }
            }

        }
        return nil
    }
}

extension SwiftExpr.function {

    /// With nested `Pointer<CChar>` from `inout String`
    static func eos_withCCharPointerForOutString(
        outString: SwiftExpr,
        bufferPointerName: String,
        arrayCount: SwiftExpr,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("eos_withCCharPointerForOutString", args: [
            outString.arg("outString"),
            arrayCount.arg("capacity"),
            .closure([bufferPointerName], nest: nest) ])
    }

    /// With nested `Pointer<CChar>` from `inout Optional<String>`
    static func eos_withCCharPointerForOutOptionalString(
        outOptionalString: SwiftExpr,
        bufferPointerName: String,
        arrayCount: SwiftExpr,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("eos_withCCharPointerForOutOptionalString", args: [
            outOptionalString.arg("outOptionalString"),
            arrayCount.arg("capacity"),
            .closure([bufferPointerName], nest: nest) ])
    }

//    /// With nested `Pointer<Pointer<CChar>>, Int` from `inout String`
//    static func withCCharPointerPointersFromInOutString(
//        inoutString: SwiftExpr,
//        bufferPointerName: String,
//        countPointerName: String,
//        nest: SwiftExpr
//    ) -> SwiftExpr {
//        SwiftFunctionCallExpr.named("withCCharPointerPointersFromInOutString", args: [
//            inoutString.arg("inoutString"),
//            .closure([bufferPointerName, countPointerName], nest: nest) ])
//    }

    /// With nested `Pointer<Pointer<CChar>>, Int` from `inout Optional<String>`
    static func withCCharPointerPointersFromInOutOptionalString(
        inoutOptionalString: SwiftExpr,
        bufferPointerName: String,
        countPointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withCCharPointerPointersFromInOutOptionalString", args: [
            inoutOptionalString.arg("inoutOptionalString"),
            .closure([bufferPointerName, countPointerName], nest: nest) ])
    }
}
