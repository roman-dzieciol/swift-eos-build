
import Foundation
import SwiftAST

extension SwiftExpr.function {

    static func throwingSdkResult(sdkCall: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("throwingSdkResult", args: [ .closure([], nest: sdkCall) ])
    }

    static func buildSdkObject(pointerManager: SwiftExpr = .string("pointerManager")) -> SwiftExpr {
        SwiftFunctionCallExpr.named("buildSdkObject", args: [ pointerManager.arg("pointerManager") ])
    }

    static func initFromSdkObject(_ sdkObject: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("init", args: [ sdkObject.arg("sdkObject") ])
    }


    static func withSdkObjectPointerFromInOutSwiftObject(
        _ inoutSwiftObject: SwiftExpr,
        managedBy pointerManager: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withSdkObjectPointerFromInOutSwiftObject", args: [
            inoutSwiftObject.arg(nil),
            pointerManager.arg("managedBy"),
            .closure([pointerName], nest: nest) ])
    }

    static func withSdkObjectPointerPointerReturnedAsSwiftObject(
        managedBy pointerManager: SwiftExpr,
        pointerPointerName: String,
        nest: SwiftExpr,
        release: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named(
            "withSdkObjectPointerPointerReturnedAsSwiftObject",
            args: [
                pointerManager.arg("managedBy"),
                .closure([pointerPointerName], nest: nest).arg("nest"),
                release.arg("release"),
            ],
            useTrailingClosures: false)
    }



    static func withSdkObjectPointerFromInOutSdkObject(
        _ inoutSdkObject: SwiftExpr,
        managedBy pointerManager: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withSdkObjectPointerFromInOutSdkObject", args: [
            inoutSdkObject.arg(nil),
            pointerManager.arg("managedBy"),
            .closure([pointerName], nest: nest) ])
    }

    static func withSdkObjectPointerFromInOutOptionalSdkObject(
        _ inoutOptionalSdkObject: SwiftExpr,
        managedBy pointerManager: SwiftExpr,
        pointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withSdkObjectPointerFromInOutOptionalSdkObject", args: [
            inoutOptionalSdkObject.arg(nil),
            pointerManager.arg("managedBy"),
            .closure([pointerName], nest: nest) ])
    }
}
