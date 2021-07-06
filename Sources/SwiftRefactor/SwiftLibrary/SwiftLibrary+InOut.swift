
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

    static func withIntPointerFromInOutInt(
        inoutInteger: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withIntPointerFromInOutInt", args: [
            inoutInteger.arg(nil),
            .closure([pointerName], nest: nest) ])
    }

    static func withIntPointerFromInOutOptionalInt(
        inoutOptionalInteger: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withIntPointerFromInOutOptionalInt", args: [
            inoutOptionalInteger.arg(nil),
            .closure([pointerName], nest: nest) ])
    }

    static func withCCharPointerPointersFromInOutString(
        inoutString: SwiftExpr,
        bufferPointerName: String,
        countPointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withCCharPointerPointersFromInOutString", args: [
            inoutString.arg("inoutString"),
            .closure([bufferPointerName, countPointerName], nest: nest) ])
    }

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

    static func cCharPointerPointerFromInOutStringArray(
        inoutArray: SwiftExpr,
        bufferPointerName: String,
        countPointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("cCharPointerPointerFromInOutStringArray", args: [
            inoutArray.arg("inoutArray"),
            .closure([bufferPointerName, countPointerName], nest: nest) ])
    }

    static func withCCharPointerFromInOutString(
        inoutString: SwiftExpr,
        bufferPointerName: String,
        arrayCount: SwiftExpr,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withCCharPointerFromInOutString", args: [
            inoutString.arg("inoutString"),
            arrayCount.arg("capacity"),
            .closure([bufferPointerName], nest: nest) ])
    }

    static func withCCharPointerFromInOutOptionalString(
        inoutOptionalString: SwiftExpr,
        bufferPointerName: String,
        arrayCount: SwiftExpr,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withCCharPointerFromInOutOptionalString", args: [
            inoutOptionalString.arg("inoutOptionalString"),
            arrayCount.arg("capacity"),
            .closure([bufferPointerName], nest: nest) ])
    }



    static func withPointersToInOutArray(
        inoutArray: SwiftExpr,
        bufferPointerName: String,
        countPointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withPointersToInOutArray", args: [
            inoutArray.arg("inoutArray"),
            .closure([bufferPointerName, countPointerName], nest: nest) ])
    }

    static func withSdkObjectPointerPointerFromInOutSwiftObject(
        inoutSwiftObject: SwiftExpr,
        pointerManager: SwiftExpr,
        pointerPointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withSdkObjectPointerPointerFromInOutSwiftObject", args: [
            inoutSwiftObject.arg(nil),
            pointerManager.arg("managedBy"),
            .closure([pointerPointerName], nest: nest) ])
    }

    static func withTrivialMutablePointerFromInOutTrivial(
        _ inoutValue: SwiftExpr,
        managedBy pointerManager: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withTrivialMutablePointerFromInOutTrivial", args: [
            inoutValue.arg(nil),
            pointerManager.arg("managedBy"),
            .closure([pointerName], nest: nest) ])
    }

    static func withOptionalTrivialMutablePointerFromInOutOptionalTrivial(
        _ inoutOptionalValue: SwiftExpr,
        managedBy pointerManager: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withOptionalTrivialMutablePointerFromInOutOptionalTrivial", args: [
            inoutOptionalValue.arg(nil),
            pointerManager.arg("managedBy"),
            .closure([pointerName], nest: nest) ])
    }

    static func withTrivialMutablePointerFromInOutOptionalTrivial(
        _ inoutOptionalValue: SwiftExpr,
        managedBy pointerManager: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withTrivialMutablePointerFromInOutOptionalTrivial", args: [
            inoutOptionalValue.arg(nil),
            pointerManager.arg("managedBy"),
            .closure([pointerName], nest: nest) ])
    }

    static func withTrivialPointersFromOptionalTrivialArray(
        _ optionalValue: SwiftExpr,
        managedBy pointerManager: SwiftExpr,
        pointerName: String,
        arrayCountName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withTrivialPointersFromOptionalTrivialArray", args: [
            optionalValue.arg(nil),
            pointerManager.arg("managedBy"),
            .closure([pointerName, arrayCountName], nest: nest) ])
    }

}
