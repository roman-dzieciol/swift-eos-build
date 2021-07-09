
import Foundation
import SwiftAST
import os.log

public class SwiftSDKCall {

    let function: SwiftFunction
    let sdkFunction: SwiftFunction

    var sdkArgs: [SwiftFunctionCallArgExpr] = []

    let sdkCallBuilder = SwiftExprBuilder()

    var code: SwiftExpr

    var functionTypeParms: [SwiftFunctionParm]
    var inoutParms: [SwiftFunctionParm]

    let outer: SwiftDecl

    public init(function: SwiftFunction, sdkFunction: SwiftFunction, outer: SwiftDecl) throws {

        self.outer = outer
        self.function = function
        self.sdkFunction = sdkFunction

        sdkCallBuilder.expr = sdkFunction.call([])

        code = sdkCallBuilder

        // If function returns EOS_EResult error code, throw it instead
        if function.returnType.canonical.asDeclRef?.decl.name == "EOS_EResult" {
            function.returnType = SwiftBuiltinType.void
            function.isThrowing = true
            code = .try(.function.throwingSdkResult(sdkCall: code))
        }

        functionTypeParms = function.parms
            .filter { $0.type.canonical is SwiftFunctionType }

        inoutParms = function.parms
            .filter { $0.isInOutParm }
    }

    func functionCode() throws -> SwiftExpr {


        let parms = function.parms
        for parm in parms {

            guard let sdkParm = parm.sdk as? SwiftFunctionParm else { fatalError() }

            let lhs = sdkParm
            let rhs = parm

            do {

                // Array count arg is handled by array buffer arg
                // Pass the arg name to SDK function
                if rhs.linked(.arrayBuffer) != nil {
                    function.removeAll([rhs])
                    sdkArgs += [lhs.arg(rhs.expr)]
                    continue
                }

                let inoutParms = self.inoutParms.filter { $0 !== rhs.linked(.arrayLength) }

                if rhs.isInOutParm,
                   inoutParms.count == 1,
                   function.returnType.isVoid,
                   let shimmed = try code.shimmed(.nestedOutShims, lhs: lhs, rhs: rhs) {
                    os_log("shim out arg: %{public}s.%{public}s", function.name, rhs.name)
                    self.code = shimmed
                    self.sdkArgs += [lhs.arg(rhs.expr)]
                    function.returnType = rhs.type
                    function.removeAll([parm])
                    continue
                }
                else if rhs.isInOutParm {
                    if let shimmed = try code.shimmed(.nestedInOutShims, lhs: lhs, rhs: rhs) {
                        os_log("shim arg: %{public}s.%{public}s", function.name, rhs.name)
                        self.code = shimmed
                        self.sdkArgs += [lhs.arg(rhs.expr)]
                        continue
                    }

                    sdkArgs += [lhs.arg(.string("\(rhs.name) /*TODO*/"))]
                } else {

                    if try handleCallback(parm: parm) {
                        continue
                    }

                    if let shimmed = try code.shimmed(.nestedShims, lhs: lhs, rhs: rhs) {
                        os_log("shim nested: %{public}s.%{public}s", function.name, rhs.name)
                        self.code = shimmed
                        self.sdkArgs += [lhs.arg(rhs.expr)]
                    }
                    else if let shimmed = try rhs.expr.shimmed(.immutableShims, lhs: lhs, rhs: rhs) {
                        sdkArgs += [lhs.arg(shimmed)]
                    }
                    else {
                        sdkArgs += [lhs.arg(.string("\(rhs.name) /*TODO*/"))]
                    }

                }

            } catch {
                sdkArgs += [lhs.arg(.string("\(rhs.name) /*TODO*/"))]
            }
        }

        sdkCallBuilder.expr = sdkFunction.call(sdkArgs, useTrailingClosures: false)

        if let shimmed = try code.shimmed(.functionResultShims,
            lhs: function.returnType.tempVar(),
            rhs: sdkFunction.returnType.tempVar()
        ) {
            os_log("shim result: %{public}s -> %{public}s <> %{public}s", function.name, "\(function.returnType)", "\(sdkFunction.returnType)")
            self.code = shimmed
        }

        function.inner
            .filter { $0.name == "ClientData" }
            .forEach { $0.removeCode() }
        function.inner.removeAll { $0.name == "ClientData" }

        code = .function.withPointerManager(code)

        function.isThrowing = code.evaluateThrowing()

        return code
    }

    func handleCallback(parm: SwiftFunctionParm) throws -> Bool {

        guard functionTypeParms.count == 1 else { return false }

        let parmCanonical = parm.type.canonical
        guard let sdkCallbackFunctionType = parmCanonical as? SwiftFunctionType else { return false }

        if function.sdk?.name.hasSuffix("EOS_Logging_SetCallback") == true {
            return false
        }

        let isNotification = function.returnType.asDeclRef?.decl.name == "EOS_NotificationId"
        guard sdkCallbackFunctionType.returnType.asBuiltin?.isVoid == true else { fatalError() }
        guard sdkCallbackFunctionType.paramTypes.count == 1 else { fatalError() }

        guard let sdkCallbackDeclType = sdkCallbackFunctionType.paramTypes.first?.asPointer?.pointeeType.asDeclRef else { fatalError() }
        guard let sdkCallbackInfoObject = sdkCallbackDeclType.decl as? SwiftStruct else { fatalError() }
        guard let callbackInfoObject = sdkCallbackInfoObject.linked(.swifty) as? SwiftStruct
                , callbackInfoObject !== sdkCallbackInfoObject else { fatalError() }

        _ = try callbackInfoObject.functionInitFromSdkObject()

        if isNotification {

            guard let removeNotifyFunction = findRemoveNotifyFunction(for: function, outer: outer) else {
                fatalError()
            }

            let notificationBuiltinType = SwiftBuiltinType(name: "SwiftEOS_Notification", qual: .none)

            function.returnType = SwiftGenericType(genericType: notificationBuiltinType,
                                                               specializationTypes: [SwiftDeclRefType(decl: callbackInfoObject, qual: .none)],
                                                               qual: .none)

            let removeExpr = SwiftExplicitMemberExpr(expr: .string("self").optional, identifier: (removeNotifyFunction.swifty as! SwiftFunction).expr, argumentNames: [])

            code = .function.withNotification(
                notification: parm.expr,
                managedBy: .string("pointerManager"),
                removeNotifyFunc: removeNotifyFunction.swifty as! SwiftFunction,
                removeNotifyFuncExpr: removeExpr,
                nest: code)

            _ = try callbackInfoObject.functionSendNotification(sdkCallbackInfoDecl: sdkCallbackInfoObject)

            let swiftCallbackCall: SwiftExpr = .function.swiftNotificationCallbackCall(
                swiftCallbackInfoName: callbackInfoObject.name,
                sdkCallbackInfoPointerName: SwiftName.sdkCallbackInfoPointer)
            sdkArgs += [.closure([SwiftName.sdkCallbackInfoPointer], nest: swiftCallbackCall, identifier: nil)]


        } else {

            code = .function.withCompletion(
                completion: parm.expr,
                managedBy: .string("pointerManager"),
                nest: code)

            _ = try callbackInfoObject.functionSendCompletion(sdkCallbackInfoDecl: sdkCallbackInfoObject)

            let swiftCallbackCall: SwiftExpr = .function.swiftCompletionCallbackCall(
                swiftCallbackInfoName: callbackInfoObject.name,
                sdkCallbackInfoPointerName: SwiftName.sdkCallbackInfoPointer)
            sdkArgs += [.closure([SwiftName.sdkCallbackInfoPointer], nest: swiftCallbackCall, identifier: nil)]

        }

        // Adjust public function's callback arg type
        let callbackType = SwiftFunctionType(
            paramTypes: [callbackInfoObject.declRefType(qual: .none)],
            returnType: sdkCallbackFunctionType.returnType,
            qual: .with(attributes: []))
        parm.type = callbackType


        // Remove ClientData from public CallbackInfo
        callbackInfoObject.inner
            .filter { $0.name == "ClientData" }
            .forEach { $0.removeCode() }
        callbackInfoObject.inner.removeAll { $0.name == "ClientData" }

        // If CallbackInfo has EOS_EResult, remove it and pass Swift.Result<CallbackInfo> as parm
//        if let callbackInfoResultCode = callbackInfoObject.inner.first(where: { $0.name == "ResultCode" }) {
//
//            // Remove ResultCode from public CallbackInfo
//            callbackInfoResultCode.removeCode()
//            callbackInfoObject.inner.removeAll { $0 === callbackInfoResultCode }
//
//            // Adjust public function's callback arg type
//            parm.type = SwiftFunctionType(
//                paramTypes: [.result(successType: callbackInfoObject.declRefType(qual: .none))],
//                returnType: callbackType.returnType,
//                qual: callbackType.qual)
//        }

        return true
    }


func findRemoveNotifyFunction(for addNotifyFunction: SwiftFunction, outer: SwiftDecl) -> SwiftFunction? {
    let removeNotifyName = addNotifyFunction.name.replacingOccurrences(of: "_AddNotify", with: "_RemoveNotify")
    let functions = outer.inner.compactMap { $0 as? SwiftFunction }
    if let removeNotifyFunction = functions.first(where: { $0.name == removeNotifyName }),
       let sdkFunction = removeNotifyFunction.linked(.sdk) as? SwiftFunction {
        return sdkFunction
    }
    let removeNotifyNameWithoutVersion = String(removeNotifyName.reversed().drop(while: { $0.isNumber }).reversed()).dropSuffix("V")
    if let removeNotifyFunction = functions.first(where: { $0.name == removeNotifyNameWithoutVersion }),
       let sdkFunction = removeNotifyFunction.linked(.sdk) as? SwiftFunction {
        return sdkFunction
    }
    return nil
}


}
