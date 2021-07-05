
import Foundation
import SwiftAST


extension SwiftExpr {

    enum function {}
}

extension SwiftExpr.function {

    static func string(cString: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("String", args: [ cString.arg("cString") ])
    }

    static func stringArrayFromCCharPointerPointer(pointer: SwiftExpr, count: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("stringArrayFromCCharPointerPointer", args: [ pointer.arg("pointer"), count.arg("count") ])
    }

    static func safeNumericCast(exactly: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("safeNumericCast", args: [ exactly.arg("exactly") ])
    }

    static func typecastIntResult(_ nest: SwiftExpr) -> SwiftExpr {
            .try(SwiftFunctionCallExpr.named("typecastIntResult", args: [ .closure([], nest: nest) ]))
    }

    static func typecastBoolResult(_ nest: SwiftExpr) -> SwiftExpr {
            .try(SwiftFunctionCallExpr.named("typecastBoolResult", args: [ .closure([], nest: nest) ]))
    }

    static func withStringResult(_ nest: SwiftExpr) -> SwiftExpr {
            .try(SwiftFunctionCallExpr.named("withStringResult", args: [ .closure([], nest: nest) ]))
    }


}

extension SwiftExpr.function {

    static func swiftBoolFromEosBool(eosBool: SwiftExpr) -> SwiftExpr {
           SwiftFunctionCallExpr.named("swiftBoolFromEosBool", args: [ eosBool.arg(nil) ])
    }

    static func eosBoolFromSwiftBool(swiftBool: SwiftExpr) -> SwiftExpr {
           SwiftFunctionCallExpr.named("eosBoolFromSwiftBool", args: [ swiftBool.arg(nil) ])
    }
}

extension SwiftExpr.function {

    static func map(_ nest: SwiftExpr) -> SwiftExpr {
           SwiftFunctionCallExpr.named("map", args: [ .closure([], nest: nest) ])
    }

    static func compactMap(_ nest: SwiftExpr) -> SwiftExpr {
           SwiftFunctionCallExpr.named("compactMap", args: [ .closure([], nest: nest) ])
    }


    static func array(_ nested: SwiftExpr) -> SwiftExpr {
           SwiftFunctionCallExpr.named("Array", args: [ nested.arg(nil) ])
    }

    static func unsafeRawBufferPointer(start: SwiftExpr, count: SwiftExpr) -> SwiftExpr {
           SwiftFunctionCallExpr.named("UnsafeRawBufferPointer", args: [ start.arg("start"), count.arg("count") ])
    }

    static func unsafeBufferPointer(start: SwiftExpr, count: SwiftExpr) -> SwiftExpr {
           SwiftFunctionCallExpr.named("UnsafeBufferPointer", args: [ start.arg("start"), count.arg("count") ])
    }

    static func trivialArrayFromTrivialPointer(start: SwiftExpr, count: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("trivialArrayFromTrivialPointer", args: [ start.arg("start"), count.arg("count") ])
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
                .string("notificationId").arg(removeNotifyFunc.parms.last!.name)
            ], useTrailingClosures: false)
        
        return .try(SwiftFunctionCallExpr.named(
            "withNotification",
            args: [
                notification.arg("notification"),
                pointerManager.arg("managedBy"),
                .closure(["ClientData"], nest: nest, identifier: .string("nested")),
                .closure(captures: ["weak self"], ["notificationId"], nest: onDeinit, identifier: .string("onDeinit")),
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

//    write(textIfNeeded: " ")
//    write(name: "onDeinit")
//    write(token: ":")
//    write(nested: "{", "}") {
//        indent(offset: 4) {
//            write(token: "[")
//            write(name: "Handle")
//            write(token: "]")
//            write(name: "notificationId")
//            write(name: "in")
//            write(textIfNeeded: "\n")
//            write(name: removeNotifyFunction.name)
//            write(nested: "(", ")") {
//                //                        write(name: "Handle")
//                //                        write(token: ":")
//                write(name: "Handle")
//                write(token: ",")
//                //                        write(name: "InId")
//                //                        write(token: ":")
//                write(name: "notificationId")
//            }
//        }
//    }
//}
//
//    static func withUnsafeMutablePointer(to value: SwiftExpr, named nestedName: String, nest: SwiftExpr) -> SwiftExpr {
//           SwiftFunctionCallExpr.named("withUnsafeMutablePointer", args: [ value.arg("to"), .closure([nestedName], nest: nest) ])
//    }
//
//    static func withUnsafePointer(to value: SwiftExpr, named nestedName: String, nest: SwiftExpr) -> SwiftExpr {
//           SwiftFunctionCallExpr.named("withUnsafePointer", args: [ value.arg("to"), .closure([nestedName], nest: nest) ])
//    }
}

//public func write(objectArray: SwiftVarDecl,
//                  objectInit: SwiftFunction,
//                  arrayBuffer: SwiftVarDecl,
//                  arrayCount: SwiftVarDecl,
//                  arrayBufferInvocation: SwiftInvocation,
//                  arrayCountInvocation: SwiftInvocation,
//                  ptrInvocation: SwiftInvocation? = nil
//) {
//
//    let ptrInvocation = ptrInvocation ?? SwiftInvocation { swift in swift.write(name: "$0") }
//
//    //        write(name: "try")
//    arrayBufferInvocation.write(to: self)
//    write(textIfNeeded: "\n")
//    indent(offset: 4) {
//        write(token: ".")
//        write(name: "array")
//        write(nested: "(", ")") {
//            arrayCountInvocation.write(to: self)
//        }
//        write(textIfNeeded: "\n")
//        write(token: ".")
//        write(name: "compactMap")
//        write(nested: "{", "}") {
//            write(name: "$0")
//            write(token: ".")
//            write(name: "pointee")
//        }
//        write(textIfNeeded: "\n")
//        write(token: ".")
//        write(name: "compactMap")
//        write(nested: "{", "}") {
//            if objectInit.isThrowing {
//                write(name: "try")
//            }
//            if objectInit.name == "init" {
//                let initName = objectArray.type.asArrayElement?.asDeclRef?.decl.name ?? ".init"
//                write(name: initName)
//            } else {
//                write(name: objectInit.name)
//            }
//            write(nested: "(", ")") {
//                if let label = objectInit.parms.first?.label {
//                    write(name: label)
//                    write(token: ":")
//                }
//                ptrInvocation.write(to: self)
//            }
//        }
//    }
//    }
