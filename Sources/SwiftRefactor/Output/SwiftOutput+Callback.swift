
import Foundation
import SwiftAST

func callbackFunc(sdkCallbackInfoObject: SwiftObject,
                  callbackInfoObject: SwiftObject,
                  function: SwiftFunction,
                  isNotification: Bool) -> SwiftFunction {

    let callbackFuncParm = SwiftFunctionParm(
        label: nil,
        name: "pointer",
        type: SwiftPointerType(
            pointeeType: SwiftDeclRefType(
                decl: sdkCallbackInfoObject,
                qual: .none),
            isMutable: false,
            qual: .optional),
        isMutable: false,
        comment: nil)


    //    guard let pointer = pointer else { fatalError() }
    //    guard let clientData = pointer.pointee.ClientData else { fatalError() }
    //    __SwiftEOS__NotificationCallback.from(pointer: clientData) {
    //        try! SwiftEOS_Achievements_OnAchievementsUnlockedCallbackInfo(from: pointer)
    //    }

    let callbackFunc = SwiftFunction(name: "__" + function.name + "__Completion",
                                     returnType: .void,
                                     inner: [callbackFuncParm],
                                     comment: SwiftComment("C callback for ``\(function.name)``")) { swift in
        swift.write(name: "guard")
        swift.write(name: "let")
        swift.write(name: callbackFuncParm.name)
        swift.write(token: "=")
        swift.write(name: callbackFuncParm.name)
        swift.write(name: "else")
        swift.write(token: " { ")
        swift.write(name: "fatalError()")
        swift.write(token: " }")
        swift.write(textIfNeeded: "\n")

        swift.write(name: "guard")
        swift.write(name: "let")
        swift.write(name: "clientData")
        swift.write(token: "=")
        swift.write(name: callbackFuncParm.name)
        swift.write(text: ".")
        swift.write(name: "pointee")
        swift.write(text: ".")
        swift.write(name: "ClientData")
        swift.write(name: "else")
        swift.write(token: " { ")
        swift.write(name: "fatalError()")
        swift.write(token: " }")
        swift.write(textIfNeeded: "\n")

        if isNotification {
            swift.write(name: "__SwiftEOS__NotificationCallback")
        } else {
            swift.write(name: "__SwiftEOS__CompletionCallbackWithResult")
        }
        swift.write(text: ".")
        swift.write(name: "from")
        swift.write(nested: "(", ")") {
            swift.write(name: "pointer")
            swift.write(token: ":")
            swift.write(name: "clientData")
        }
        swift.write(nested: "{", "}") {
            swift.write(textIfNeeded: "\n")
            swift.write(name: "try")
//            swift.write(token: "!")
            swift.write(textIfNeeded: " ")
            swift.write(name: callbackInfoObject.name)
            swift.write(nested: "(", ")") {
                swift.write(name: "from")
                swift.write(token: ":")
                swift.write(name: "pointer")
            }
            swift.write(textIfNeeded: "\n")
        }
    }
    callbackFunc.access = "private"

    return callbackFunc
}
