
import Foundation
import SwiftAST

class SdkTestFunctionBuilder {

    let swiftFunction: SwiftFunction
    let swiftFunctionParms: [SwiftFunctionParm]

    let sdkFunction: SwiftFunction
    let sdkFunctionParms: [SwiftFunctionParm]

    var swiftFunctionCallExpr: SwiftExpr = .string("")

    var preconditions: [SwiftExpr] = []
    var statements: [SwiftExpr] = []
    var postconditions: [SwiftExpr] = []


    init(swiftFunction: SwiftFunction) {
        self.swiftFunction = swiftFunction
        self.swiftFunctionParms = swiftFunction.parms

        self.sdkFunction = swiftFunction.sdk as! SwiftFunction
        self.sdkFunctionParms = sdkFunction.parms
    }

    func build() -> SwiftFunction {

        preconditions += [.string("TestGlobals.reset()")]

        let swiftFunctionCall = buildSwiftFunctionCall()
        swiftFunctionCallExpr = swiftFunctionCall

        statements += [buildSdkImplementation()]

        addActorReference()
        addReturnTypeAssert()
        addFunctionCallAsserts()

        let testFunction = SwiftFunction(
            name: "test" + sdkFunction.name + "_Null",
            returnType: .void,
            code: SwiftCodeBlock(statements: preconditions + statements + [swiftFunctionCallExpr] + postconditions))
        testFunction.isThrowing = true

        return testFunction
    }


    func buildSwiftFunctionCall() -> SwiftFunctionCallExpr {

        var swiftFunctionArgs: [SwiftFunctionCallArgExpr] = []
        swiftFunctionArgs.reserveCapacity(swiftFunctionParms.count)

        for parm in swiftFunctionParms {
            if parm.isInOutParm {
                let nilExpr = TestAsserts.nilOrSomeExpr(parm.type)
                preconditions += [.var(parm.name, type: parm.type).assign(nilExpr)]
                postconditions += [TestAsserts.assertNil(varDecl: parm)]
                swiftFunctionArgs += [parm.expr.inout.arg(parm.label.map { .string($0) })]
            } else {
                swiftFunctionArgs += [TestAsserts.nilArg(varDecl: parm)]
            }
        }

        return swiftFunction.call(swiftFunctionArgs, useTrailingClosures: false)
    }

    func buildSdkImplementation() -> SwiftExpr {

        var implementation: [SwiftExpr] = []
        let sdkParamNames = sdkFunctionParms.map({ $0.name })

        for sdkParam in sdkFunctionParms {

            if sdkParam.name == "Handle" {
                implementation += [.string("XCTAssertEqual(\(sdkParam.name), OpaquePointer(bitPattern: Int(1))!)")]
            }

            else if let functionType = sdkParam.type.canonical.asFunction {
                let args = functionType.paramTypes.map { paramType -> SwiftFunctionCallArgExpr in
                    TestAsserts.nilOrSomeExpr(paramType).arg(nil)
                }

                implementation += [
                    sdkParam.expr.optional.call(args)
                ]
            }

            else if sdkParam.name.hasSuffix("Options"), let optionsObject = sdkParam.type.canonical.asPointer?.pointeeType.asDeclRef?.decl.canonical as? SwiftObject {
                implementation += [TestAsserts.assertNil(object: optionsObject, lhsString: "\(sdkParam.name)!.pointee")]
            }

            else {
                implementation += [TestAsserts.assertNil(varDecl: sdkParam)]
            }
        }

        implementation += [.string("TestGlobals.sdkReceived.append(\"\(sdkFunction.name)\")")]

        if !sdkFunction.returnType.isVoid {
            let nilExpr = TestAsserts.nilOrSomeExpr(sdkFunction.returnType)
            implementation += [.string("return \(nilExpr.description)")]
        }

        let implementationClosure = SwiftClosureExpr(
            captures: [],
            params: sdkParamNames,
            omitParams: false,
            resultType: nil,
            omitResultType: false,
            isThrowing: false,
            statements: SwiftCodeBlock(statements: implementation)
        )

        return .string("__on_\(sdkFunction.name)").assign(implementationClosure)

    }

    func addActorReference() {
        if let outer = swiftFunction.linked(.outer) as? SwiftObject {
            let outerInit = outer.expr.call([.string("OpaquePointer(bitPattern: Int(1))!").arg("Handle")])
            statements += [.let("object", type: outer.declRefType()).assign(outerInit)]
            swiftFunctionCallExpr = .string("object").member(swiftFunctionCallExpr)
        }
    }

    func addReturnTypeAssert() {

        if swiftFunction.isThrowing {
            swiftFunctionCallExpr = .try(swiftFunctionCallExpr)
        }

        if !swiftFunction.returnType.isVoid {
            let resultVar: SwiftVarDeclRefExpr = .let("result", type: swiftFunction.returnType)
            swiftFunctionCallExpr = resultVar.assign(swiftFunctionCallExpr)
            postconditions += [TestAsserts.assertNil(varDecl: resultVar.varDecl)]
        }
    }

    func addFunctionCallAsserts() {

        postconditions += [.string("XCTAssertEqual(TestGlobals.sdkReceived, [\"\(sdkFunction.name)\"])")]

        let functionTypeParmNames = swiftFunctionParms
            .filter(\.type.canonical.isFunction)
            .map { "\"\($0.name)\"" }
            .joined(separator: ", ")
        postconditions += [.string("XCTAssertEqual(TestGlobals.swiftReceived, [\(functionTypeParmNames)])")]
    }

}
