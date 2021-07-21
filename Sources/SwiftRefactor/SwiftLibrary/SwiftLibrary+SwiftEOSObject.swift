
import Foundation
import SwiftAST

extension SwiftExpr.function {

    static func throwingSdkResult(sdkCall: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("throwingSdkResult", args: [ .closure([], nest: sdkCall) ])
    }

    static func throwingNilResult(_ sdkCall: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("throwingNilResult", args: [ .closure([], nest: sdkCall) ])
    }

    static func buildSdkObject(pointerManager: SwiftExpr = .string("pointerManager")) -> SwiftExpr {
        SwiftFunctionCallExpr.named("buildSdkObject", args: [ pointerManager.arg("pointerManager") ])
    }

    static func initFromSdkObject(_ sdkObject: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("init", args: [ sdkObject.arg("sdkObject") ])
    }


    static func withSdkObjectOptionalPointerFromInOutOptionalSwiftObject(
        _ inoutSwiftObject: SwiftExpr,
        managedBy pointerManager: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withSdkObjectOptionalPointerFromInOutOptionalSwiftObject", args: [
            inoutSwiftObject.arg(nil),
            pointerManager.arg("managedBy"),
            .closure([pointerName], nest: nest) ])
    }

    static func withSdkObjectOptionalPointerToOptionalPointerReturnedAsOptionalSwiftObject(
        managedBy pointerManager: SwiftExpr,
        pointerPointerName: String,
        nest: SwiftExpr,
        release: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named(
            "withSdkObjectOptionalPointerToOptionalPointerReturnedAsOptionalSwiftObject",
            args: [
                pointerManager.arg("managedBy"),
                .closure([pointerPointerName], nest: nest).arg("nest"),
                release.arg("release"),
            ],
            useTrailingClosures: false)
    }



    static func withSdkObjectOptionalPointerFromInOutSdkObject(
        _ inoutSdkObject: SwiftExpr,
        managedBy pointerManager: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withSdkObjectOptionalPointerFromInOutSdkObject", args: [
            inoutSdkObject.arg(nil),
            pointerManager.arg("managedBy"),
            .closure([pointerName], nest: nest) ])
    }

    static func withSdkObjectOptionalPointerFromInOutOptionalSdkObject(
        _ inoutOptionalSdkObject: SwiftExpr,
        managedBy pointerManager: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withSdkObjectOptionalPointerFromInOutOptionalSdkObject", args: [
            inoutOptionalSdkObject.arg(nil),
            pointerManager.arg("managedBy"),
            .closure([pointerName], nest: nest) ])
    }
}
