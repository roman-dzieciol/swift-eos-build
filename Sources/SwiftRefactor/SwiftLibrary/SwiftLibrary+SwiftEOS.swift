
import Foundation
import SwiftAST


extension SwiftExpr {

    enum function {}
}

extension SwiftExpr.function {

    static func stringFromOptionalCStringPointer(_ cString: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("stringFromOptionalCStringPointer", args: [ cString.arg(nil) ])
    }
}

extension SwiftExpr.function {

    static func map(_ nest: SwiftExpr) -> SwiftExpr {
           SwiftFunctionCallExpr.named("map", args: [ .closure([], nest: nest) ])
    }

    static func compactMap(_ nest: SwiftExpr) -> SwiftExpr {
           SwiftFunctionCallExpr.named("compactMap", args: [ .closure([], nest: nest) ])
    }


    static func byteArray(_ nested: SwiftExpr) -> SwiftExpr {
           SwiftFunctionCallExpr.named("byteArray", args: [ nested.arg("from") ])
    }

    static func unsafeRawBufferPointer(start: SwiftExpr, count: SwiftExpr) -> SwiftExpr {
           SwiftFunctionCallExpr.named("UnsafeRawBufferPointer", args: [ start.arg("start"), count.arg("count") ])
    }

    static func unsafeBufferPointer(start: SwiftExpr, count: SwiftExpr) -> SwiftExpr {
           SwiftFunctionCallExpr.named("UnsafeBufferPointer", args: [ start.arg("start"), count.arg("count") ])
    }

    static func mapBufferToObjects(arrayCount: SwiftExpr, objectInit: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("array", args: [ arrayCount.arg(nil) ])
            .member(SwiftFunctionCallExpr.named("compactMap", args: [ .closure([], nest: objectInit) ]))
    }

    static func swiftNotificationCallbackCall(
        swiftCallbackInfoName: @autoclosure @escaping () -> String,
        sdkCallbackInfoPointerName: String
    ) -> SwiftExpr {
            .string(swiftCallbackInfoName())
            .member(SwiftFunctionCallExpr.named(
                "sendNotification",
                args: [ .string(sdkCallbackInfoPointerName).arg(nil) ]
            ))
    }

    static func swiftCompletionResultCallbackCall(
        swiftCallbackInfoName: @autoclosure @escaping () -> String,
        sdkCallbackInfoPointerName: String
    ) -> SwiftExpr {
            .string(swiftCallbackInfoName())
            .member(SwiftFunctionCallExpr.named(
                "sendCompletionResult",
                args: [ .string(sdkCallbackInfoPointerName).arg(nil) ]
            ))
    }

    static func swiftCompletionCallbackCall(
        swiftCallbackInfoName: @autoclosure @escaping () -> String,
        sdkCallbackInfoPointerName: String
    ) -> SwiftExpr {
            .string(swiftCallbackInfoName())
            .member(SwiftFunctionCallExpr.named(
                "sendCompletion",
                args: [ .string(sdkCallbackInfoPointerName).arg(nil) ]
            ))
    }

    static func withNotification(
        notification: SwiftExpr,
        managedBy pointerManager: SwiftExpr,
        removeNotifyFunc: SwiftFunction,
        removeNotifyFuncExpr: SwiftExpr,
        nest: SwiftExpr
    ) -> SwiftExpr {

        let onDeinit: SwiftExpr = SwiftFunctionCallExpr(
            expr: removeNotifyFuncExpr,
            args: [
                .string("Handle").arg(nil),
                .string("notificationId").arg(nil)
            ], useTrailingClosures: false)
        
        return .try(SwiftFunctionCallExpr.named(
            "withNotification",
            args: [
                notification.arg("notification"),
                pointerManager.arg("managedBy"),
                .closure(["ClientData"], nest: nest, identifier: .string("nested")),
                .closure(captures: ["Handle"], ["notificationId"], nest: onDeinit, identifier: .string("onDeinit")),
            ],
            useTrailingClosures: false))
    }

    static func withCompletionResult(
        completion: SwiftExpr,
        managedBy pointerManager: SwiftExpr,
        nest: SwiftExpr
    ) -> SwiftExpr {

        return .try(SwiftFunctionCallExpr.named(
            "withCompletionResult",
            args: [
                completion.arg("completion"),
                pointerManager.arg("managedBy"),
                .closure(["ClientData"], nest: nest, identifier: .string("nested")), 
            ],
            useTrailingClosures: true))
    }

    static func withCompletion(
        completion: SwiftExpr,
        managedBy pointerManager: SwiftExpr,
        nest: SwiftExpr
    ) -> SwiftExpr {

        return .try(SwiftFunctionCallExpr.named(
            "withCompletion",
            args: [
                completion.arg("completion"),
                pointerManager.arg("managedBy"),
                .closure(["ClientData"], nest: nest, identifier: .string("nested")),
            ],
            useTrailingClosures: true))
    }
}
