
import Foundation
import SwiftAST
//
//func refactor(callback parm: SwiftVarDecl, refactoring: SwiftFunctionRefactoring) throws  -> Bool {
//
//    let parmCanonical = parm.type.canonical
//    guard let sdkCallbackFunctionType = parmCanonical as? SwiftFunctionType else { return false }
//
//    let callbacks = refactoring.function.parms
//        .filter { $0.type.canonical is SwiftFunctionType }
//
//    if refactoring.function.name == "SwiftEOS_Logging_SetCallback" {
//        return false
//    }
//
//
//    let isNotification = refactoring.function.returnType.asDeclRef?.decl.name == "EOS_NotificationId"
//
//
//    if callbacks.count != 1 {
//        return false
//    }
//
//
//    guard sdkCallbackFunctionType.returnType.asBuiltin?.isVoid == true else { fatalError() }
//    guard sdkCallbackFunctionType.paramTypes.count == 1 else { fatalError() }
//
//    guard let sdkCallbackDeclType = sdkCallbackFunctionType.paramTypes.first?.asPointer?.pointeeType.asDeclRef else { fatalError() }
//    guard let sdkCallbackInfoObject = sdkCallbackDeclType.decl as? SwiftStruct else { fatalError() }
//    guard let callbackInfoObject = sdkCallbackInfoObject.copiedAST as? SwiftStruct
//            , callbackInfoObject !== sdkCallbackInfoObject else { fatalError() }
//
//    try callbackInfoObject.functionInitFromSdkObject()
//
//    if isNotification {
//
//        guard let removeNotifyFunction = refactoring.findRemoveNotifyFunction(for: refactoring.function) else {
//            fatalError()
//        }
//
//        let notificationBuiltinType = SwiftBuiltinType(name: "SwiftEOS_Notification", qual: .none)
//
//        refactoring.function.returnType = SwiftGenericType(genericType: notificationBuiltinType,
//                                                           specializationTypes: [SwiftDeclRefType(decl: callbackInfoObject, qual: .none)],
//                                                           qual: .none)
//        refactoring.effectiveReturnType = refactoring.function.returnType
//
//        refactoring.nestedCalls.nested { swift, innerCall in
//            swift.write(withNotification: parm,
//                        removeNotifyFunction: removeNotifyFunction,
//                        invocation: SwiftInvocation(output: innerCall))
//        }
//
//    } else {
//
//        refactoring.nestedCalls.nested { swift, innerCall in
//            swift.write(name: "withCompletionResult")
//            swift.write(nested: "(", ")") {
//                swift.write(name: parm.name)
//                swift.write(token: ",")
//                swift.write(name: "pointerManager")
//            }
//            swift.write(nested: "{", "}") {
//                swift.write(name: "ClientData")
//                swift.write(name: "in")
//                swift.write(textIfNeeded: "\n")
//                innerCall(swift)
//            }
//        }
//
//    }
//
//    // Adjust public function's callback arg type
//    let callbackType = SwiftFunctionType(
//        paramTypes: [callbackInfoObject.declRefType(qual: .none)],
//        returnType: sdkCallbackFunctionType.returnType,
//        qual: .with(attributes: ["@escaping"]))
//    parm.type = callbackType
//
//
//    // Initialize callback struct for call to sdk function
//    let callbackInfoInitCall = SwiftFunctionCallCode(init: callbackInfoObject)
//    callbackInfoInitCall.append { swift in
//        swift.write(name: "CallbackInfo")
//        swift.write(token: ":")
//        swift.write(name: "CallbackInfo")
//    }
//
//    // Remove ClientData from public CallbackInfo
//    callbackInfoObject.inner
//        .filter { $0.name == "ClientData" }
//        .forEach { $0.removeCode() }
//    callbackInfoObject.inner.removeAll { $0.name == "ClientData" }
//
//    // If CallbackInfo has EOS_EResult, remove it and pass Swift.Result<CallbackInfo> as parm
//    if let callbackInfoResultCode = callbackInfoObject.inner.first(where: { $0.name == "ResultCode" }) {
//
//        // Remove ResultCode from public CallbackInfo
//        callbackInfoResultCode.removeCode()
//        callbackInfoObject.inner.removeAll { $0 === callbackInfoResultCode }
//
//        // Adjust public function's callback arg type
//        parm.type = SwiftFunctionType(
//            paramTypes: [.result(successType: callbackInfoObject.declRefType(qual: .none))],
//            returnType: callbackType.returnType,
//            qual: callbackType.qual)
//    }
//
//    refactoring.sdkFunctionCall.append { swift in
//        swift.write(callbackInfoObject: callbackInfoObject, isNotification: isNotification)
//    }
//
//    return true
//}
//
