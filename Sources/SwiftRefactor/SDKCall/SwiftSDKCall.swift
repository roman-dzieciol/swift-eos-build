
import Foundation
import SwiftAST
import os.log

final public class SwiftSDKCall {

    let function: SwiftFunction
    let sdkFunction: SwiftFunction

    var sdkArgs: [SwiftFunctionCallArgExpr] = []

    let sdkCallBuilder = SwiftExprBuilder()

    var code: SwiftExpr

    var functionTypeParms: [SwiftFunctionParm]
    var inoutParms: [SwiftFunctionParm]

    let outer: SwiftDecl

    var returnComment: SwiftCommentBlock?
    var throwsComment: SwiftCommentBlock?

    public init(function: SwiftFunction, sdkFunction: SwiftFunction, outer: SwiftDecl) throws {

        self.outer = outer
        self.function = function
        self.sdkFunction = sdkFunction

        sdkCallBuilder.expr = sdkFunction.call([])

        code = sdkCallBuilder

        functionTypeParms = function.parms
            .filter { $0.type.canonical is SwiftFunctionType }

        inoutParms = function.parms
            .filter { $0.isInOutParm }

        returnComment = function.comment?.blockComments.first(where: { $0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "return" })

        // If function returns EOS_EResult error code, throw it instead
        if function.returnType.canonical.asDeclRef?.decl.name == "EOS_EResult" {
            function.returnType = SwiftBuiltinType.void
            function.isThrowing = true
            code = .try(.function.throwingSdkResult(sdkCall: code))
            throwsComment = returnComment
            throwsComment?.name = "Throws"
            throwsComment?.fixEosResultComment()
            returnComment = nil
        } else {
            // TODO: fix invalid comments that should be on callbacks instead
        }
        
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

                if lhs.name.hasSuffix("Options"),
                   let lhsPointer = lhs.type.canonical.asPointer,
                   let lhsObject = lhsPointer.pointeeType.asDeclRef?.decl.canonical as? SwiftObject,
                   !lhsObject.inSwiftEOS,
                   !(lhsObject is SwiftEnum),
                   let rhsObject = rhs.type.canonical.asDeclRef?.decl.canonical as? SwiftObject,
                   rhsObject.inSwiftEOS,
                   !(rhsObject is SwiftEnum),
                   lhsObject === rhsObject.sdk,
                   lhsObject.members.count == 1,
                   lhsObject.members.first?.name == "ApiVersion"
                {
                    code = .try(.function.withSdkObjectOptionalMutablePointerFromSwiftObject(
                        rhsObject.expr.call([]),
                        managedBy: .string("pointerManager"),
                        pointerName: rhs.name,
                        nest: code))
                    function.removeAll([rhs])
                    sdkArgs += [lhs.arg(rhs.expr)]
                }
                else if rhs.isInOutParm,
                   inoutParms.count == 1,
                   function.returnType.isVoid,
                   let shimmed = try code.shimmed(.nestedOutShims, lhs: lhs, rhs: rhs) {
                    os_log("shim out arg: %{public}s.%{public}s", log: .disabled, function.name, rhs.name)
                    self.code = shimmed
                    self.sdkArgs += [lhs.arg(rhs.expr)]
                    function.returnType = rhs.type.nonOptional
                    function.link(.returnedOutParam, ref: rhs)

                    if returnComment == nil {

                        let returnComment = SwiftCommentBlock(name: "Returns", comments: [])
                        if let paramComments = function.comment?.paramComments.first(where: { $0.name == rhs.name })?.inner {
                            returnComment.append(contentsOf: paramComments)
                        } else {
                            returnComment.add(comment: " ")
                        }
                        self.returnComment = returnComment
                        function.comment?.append(returnComment)
                    }

                    function.removeAll([parm])
                    continue
                }
                else if rhs.isInOutParm {
                    if let shimmed = try code.shimmed(.nestedInOutShims, lhs: lhs, rhs: rhs) {
                        os_log("shim arg: %{public}s.%{public}s", log: .disabled, function.name, rhs.name)
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
                        os_log("shim nested: %{public}s.%{public}s", log: .disabled, function.name, rhs.name)
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
            os_log("shim result: %{public}s -> %{public}s <> %{public}s", log: .disabled, function.name, "\(function.returnType)", "\(sdkFunction.returnType)")
            self.code = shimmed
        }

        if let clientDataParam = function.parms.first(where: { $0.name == "ClientData" }) {
            clientDataParam.removeCode()
            function.removeAll([clientDataParam])
        }

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

            guard let removeNotifyFunction = function.sdk?.linked(.removeNotifyFunc) as? SwiftFunction else {
                fatalError()
            }

            let notificationBuiltinType = SwiftBuiltinType(name: "SwiftEOS_Notification", qual: .none)

            function.returnType = SwiftGenericType(genericType: notificationBuiltinType,
                                                               specializationTypes: [SwiftDeclRefType(decl: callbackInfoObject, qual: .none)],
                                                               qual: .none)

            code = .function.withNotification(
                notification: parm.expr,
                managedBy: .string("pointerManager"),
                removeNotifyFunc: removeNotifyFunction,
                removeNotifyFuncExpr: removeNotifyFunction.expr,
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



}
