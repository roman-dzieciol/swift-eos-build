
import Foundation
import SwiftAST


extension SwiftObject {

    func functionInitFromSdkObject() throws -> SwiftFunction {

        if let function = linked(.functionInitFromSdkObject) as? SwiftFunction {
            return function
        }

        let sdkObject = sdk as! SwiftObject

        let functionParm = SwiftFunctionParm(
            label: SwiftName.sdkObject,
            name: SwiftName.sdkObject,
            type: SwiftDeclRefType(decl: sdkObject, qual: .optional))

        let function = SwiftFunction(
            name: "init",
            isAsync: false,
            isOptional: true,
            isThrowing: true,
            returnType: .void,
            inner: [functionParm],
            comment: .init("Initialize from SDK object"))

        link(.functionInitFromSdkObject, ref: function)

        let sdkObjectExpr: SwiftExpr = .string(SwiftName.sdkObject)

        var statements: [SwiftExpr] = []

        statements += [SwiftTempExpr { swift in
            swift.write(name: "guard")
            swift.write(name: "let")
            swift.write(name: SwiftName.sdkObject)
            swift.write(token: "=")
            swift.write(name: SwiftName.sdkObject)
            swift.write(name: "else")
            swift.write(token: "{")
            swift.write(name: "return")
            swift.write(name: "nil")
            swift.write(token: "}")
        }]

        inner.append(function)

        for member in members {

            let sdkMember = member.sdk as! SwiftMember

            let lhs = member
            let rhs = sdkMember

            member.isMutable = false

            let lhsExpr = SwiftExpr.self_(lhs.expr)
            let rhsMemberExpr = sdkObjectExpr.member(rhs.expr)

            do {
                if let shimmed = try rhsMemberExpr.shimmed(.immutableShims, lhs: lhs, rhs: rhs) {
                    let stmt = SwiftExprBuilder(expr: lhsExpr.assign(shimmed))
                    statements.append(stmt)
                    stmt.link(ast: lhs)
                    stmt.link(ast: rhs)
                } else {
                    statements.append(.string("/* TODO: \(lhs.name) */"))
                }

            } catch {
                statements.append(.string("/* TODO: \(lhs.name) */"))
            }
        }

        function.code = SwiftCodeBlock(statements: statements)

        return function
    }


    func functionSendCompletionResult(sdkCallbackInfoDecl: SwiftDecl) throws -> SwiftFunction {

        if let function = linked(.functionSendCompletionResult) as? SwiftFunction {
            return function
        }

        let functionParm = SwiftFunctionParm(
            label: nil,
            name: SwiftName.sdkCallbackInfoPointer,
            type: SwiftPointerType(pointeeType: sdkCallbackInfoDecl.declRefType(), isMutable: false, qual: .optional))

        let function = SwiftFunction(
            name: "sendCompletion",
            isAsync: false,
            isOptional: false,
            isThrowing: false,
            returnType: .void,
            inner: [functionParm],
            comment: .init("Send completion using the pointer to C callback info provided"))

        function.attributes.formUnion(["static"])

        link(.functionSendCompletionResult, ref: function)

        let statements: [SwiftExpr] = [
            SwiftTempExpr { swift in
            swift.write(name: "guard")
            swift.write(name: "let")
            swift.write(name: SwiftName.sdkCallbackInfoPointer)
            swift.write(token: "=")
            swift.write(name: SwiftName.sdkCallbackInfoPointer)
            swift.write(name: "else")
            swift.write(token: "{")
            swift.write(name: "return")
            swift.write(token: "}")
            swift.write(textIfNeeded: "\n")
            swift.write(name: "guard let callback = __SwiftEOS__CompletionCallbackWithResult<Self>.from(pointer: \(SwiftName.sdkCallbackInfoPointer).pointee.ClientData) else { return }")
            swift.write(textIfNeeded: "\n")
            swift.write(name: "guard let callbackInfo = try? Self.init(sdkObject: \(SwiftName.sdkCallbackInfoPointer).pointee) else { return }")
        },
            .string("callback").member("completionResult").call([.string("callbackInfo").arg(nil)]),
        ]

        inner.append(function)

        function.code = SwiftCodeBlock(statements: statements)

        return function
    }

    func functionSendCompletion(sdkCallbackInfoDecl: SwiftDecl) throws -> SwiftFunction {

        if let function = linked(.functionSendCompletion) as? SwiftFunction {
            return function
        }

        let functionParm = SwiftFunctionParm(
            label: nil,
            name: SwiftName.sdkCallbackInfoPointer,
            type: SwiftPointerType(pointeeType: sdkCallbackInfoDecl.declRefType(), isMutable: false, qual: .optional))

        let function = SwiftFunction(
            name: "sendCompletion",
            isAsync: false,
            isOptional: false,
            isThrowing: false,
            returnType: .void,
            inner: [functionParm],
            comment: .init("Send completion using the pointer to C callback info provided"))

        function.attributes.formUnion(["static"])

        link(.functionSendCompletion, ref: function)

        let statements: [SwiftExpr] = [
            SwiftTempExpr { swift in
            swift.write(name: "guard")
            swift.write(name: "let")
            swift.write(name: SwiftName.sdkCallbackInfoPointer)
            swift.write(token: "=")
            swift.write(name: SwiftName.sdkCallbackInfoPointer)
            swift.write(name: "else")
            swift.write(token: "{")
            swift.write(name: "return")
            swift.write(token: "}")
            swift.write(textIfNeeded: "\n")
            swift.write(name: "guard let callback = __SwiftEOS__CompletionCallback<Self>.from(pointer: \(SwiftName.sdkCallbackInfoPointer).pointee.ClientData) else { return }")
            swift.write(textIfNeeded: "\n")
            swift.write(name: "guard let callbackInfo = try? Self.init(sdkObject: \(SwiftName.sdkCallbackInfoPointer).pointee) else { return }")
        },
            .string("callback").member("completion").call([.string("callbackInfo").arg(nil)]),
        ]

        inner.append(function)

        function.code = SwiftCodeBlock(statements: statements)

        return function
    }

    func functionSendNotification(sdkCallbackInfoDecl: SwiftDecl) throws -> SwiftFunction {

        if let function = linked(.functionSendNotification) as? SwiftFunction {
            return function
        }

        let functionParm = SwiftFunctionParm(
            label: nil,
            name: SwiftName.sdkCallbackInfoPointer,
            type: SwiftPointerType(pointeeType: sdkCallbackInfoDecl.declRefType(), isMutable: false, qual: .optional))

        let function = SwiftFunction(
            name: "sendNotification",
            isAsync: false,
            isOptional: false,
            isThrowing: false,
            returnType: .void,
            inner: [functionParm],
            comment: .init("Send notification using the pointer to C callback info provided"))

        function.attributes.formUnion(["static"])

        link(.functionSendNotification, ref: function)

        let statements: [SwiftExpr] = [
            SwiftTempExpr { swift in
            swift.write(name: "guard")
            swift.write(name: "let")
            swift.write(name: SwiftName.sdkCallbackInfoPointer)
            swift.write(token: "=")
            swift.write(name: SwiftName.sdkCallbackInfoPointer)
            swift.write(name: "else")
            swift.write(token: "{")
            swift.write(name: "return")
            swift.write(token: "}")
            swift.write(textIfNeeded: "\n")
            swift.write(name: "guard let callback = __SwiftEOS__NotificationCallback<Self>.from(pointer: \(SwiftName.sdkCallbackInfoPointer).pointee.ClientData) else { return }")
            swift.write(textIfNeeded: "\n")
            swift.write(name: "guard let callbackInfo = try? Self.init(sdkObject: \(SwiftName.sdkCallbackInfoPointer).pointee) else { return }")
        },
            .string("callback").member("notify").call([.string("callbackInfo").arg(nil)]),
        ]

        inner.append(function)

        function.code = SwiftCodeBlock(statements: statements)

        return function
    }
}

//        public static func sendNotification(_ ptr: UnsafePointer<EOS_Achievements_OnAchievementsUnlockedCallbackInfo>?) {
//            guard let ptr = ptr else { return }
//            let callback = __SwiftEOS__NotificationCallback<Self>.from(pointer: ptr.pointee.ClientData)
//            let callbackInfo = Self.init(sdkObject: ptr.pointee)
//            callback?.notify(callbackInfo)
//        }
