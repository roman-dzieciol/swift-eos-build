
import Foundation
import SwiftAST


extension SwiftObject {

    func functionBuildSdkObject() throws -> SwiftFunction {

        if let function = linked(.functionBuildSdkObject) as? SwiftFunction {
            return function
        }

        let sdkObject = sdk as! SwiftObject

        let functionParm = SwiftFunctionParm(
            label: "pointerManager",
            name: "pointerManager",
            type: SwiftBuiltinType(name: "SwiftEOS__PointerManager")
        )

        let function = SwiftFunction(
            name: SwiftName.buildSdkObject,
            isAsync: false,
            isThrowing: true,
            returnType: SwiftDeclRefType(decl: sdkObject),
            inner: [functionParm])

        link(.functionBuildSdkObject, ref: function)

        function.add(comment: "Returns SDK Object initialized with values from this object")
        function.add(comment: "Pointers in the SDK object are managed by provided SwiftEOS__PointerManager object")

        inner.append(function)

        var args: [SwiftFunctionCallArgExpr] = []


        for sdkMember in sdkObject.members {

            guard let member = sdkMember.swifty as? SwiftMember else { continue }

            let lhs = sdkMember
            let rhs = member

            do {
                if let rhsArrayBuffer = rhs.linked(.arrayBuffer) as? SwiftMember {
                    let rhsExpr = rhsArrayBuffer.expr.member("count ?? .zero")
                    if let shimmed = try rhsExpr.shimmed(.immutableShims, lhs: lhs, rhs: rhs) {
                        args += [ shimmed.arg(.string(lhs.name)) ]
                        continue
                    }
                }
                else if let shimmed = try rhs.expr.shimmed(.immutableShims, lhs: lhs, rhs: rhs) {
                    args += [ shimmed.arg(.string(lhs.name)) ]
                    continue
                }
            } catch {
            }
            args += [ .string("/* TODO: */ \(lhs.name)").arg(.string(lhs.name)) ]
        }

        let sdkObjectInitCall = SwiftFunctionCallExpr(
            expr: .string(sdkObject.name),
            args: args,
            useTrailingClosures: true)

        function.code = sdkObjectInitCall

        return function
    }
}

