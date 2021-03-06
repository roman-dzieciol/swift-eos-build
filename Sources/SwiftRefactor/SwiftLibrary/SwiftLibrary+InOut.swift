
import Foundation
import SwiftAST

extension SwiftExpr.function {

    static func withTransformedInOut(
        inoutValue: SwiftExpr,
        valueToTransformed: SwiftExpr,
        valueFromTransformed: SwiftExpr,
        transformedName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withTransformedInOut", args: [
            inoutValue.arg("inoutValue"),
            .closure(["valueToTransform"], nest: valueToTransformed),
            .closure(["resultToTransform"], nest: valueFromTransformed),
            .closure([transformedName], nest: nest) ])
    }

    static func withPointersToInOutArray(
        inoutArray: SwiftExpr,
        bufferPointerName: String,
        countPointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withPointersToInOutArray", args: [
            inoutArray.arg("inoutOptionalArray"),
            .closure([bufferPointerName, countPointerName], nest: nest) ])
    }

    static func withSdkObjectOptionalPointerToOptionalPointerFromInOutOptionalSwiftObject(
        inoutSwiftObject: SwiftExpr,
        pointerManager: SwiftExpr,
        pointerPointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withSdkObjectOptionalPointerToOptionalPointerFromInOutOptionalSwiftObject", args: [
            inoutSwiftObject.arg(nil),
            pointerManager.arg("managedBy"),
            .closure([pointerPointerName], nest: nest) ])
    }

    static func withZeroInitializedCStruct(
        type: SwiftExpr,
        cstructVarName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withZeroInitializedCStruct", args: [
            type.arg("type"),
            .closure([cstructVarName], nest: nest) ])
    }

}

extension SwiftExpr.function {

    static func withPointeeReturned(
        managedBy pointerManager: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withPointeeReturned", args: [
            pointerManager.arg("managedBy"),
            .closure([pointerName], nest: nest) ])
    }
}


