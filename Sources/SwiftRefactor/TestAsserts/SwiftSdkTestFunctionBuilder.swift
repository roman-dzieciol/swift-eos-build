
import Foundation
import SwiftAST

class SdkTestFunctionBuilder {

    let swiftFunction: SwiftFunction
    let swiftFunctionParms: [SwiftFunctionParm]

    let sdkFunction: SwiftFunction

    var swiftFunctionCallExpr: SwiftExpr = .string("")

    var preconditions: SwiftStatementsBuilder
    var statements: SwiftStatementsBuilder
    var postconditions: SwiftStatementsBuilder
    var postconditionsGroup: SwiftExpr
    var autoreleaseAsserts: SwiftStatementsBuilder

    var postconditionCalls: [String] = []
    var autoreleaseCalls: [String] = []

    init(swiftFunction: SwiftFunction) {
        self.swiftFunction = swiftFunction
        self.swiftFunctionParms = swiftFunction.parms

        self.sdkFunction = swiftFunction.sdk as! SwiftFunction

        self.preconditions = SwiftStatementsBuilder()
        self.statements = SwiftStatementsBuilder()
        self.postconditions = SwiftStatementsBuilder()
        self.postconditionsGroup = postconditions
        self.autoreleaseAsserts = SwiftStatementsBuilder()
    }

    func build() -> SwiftFunction {

        preconditions += [.string("GTest.current.reset()")]

        let swiftFunctionCall = buildSwiftFunctionCall()
        swiftFunctionCallExpr = swiftFunctionCall

        statements += [
            .string(""),
            .string("// Given implementation for SDK function"),
            buildSdkImplementation(sdkFunction: sdkFunction),
            .string("defer { __on_\(sdkFunction.name) = nil }"),
        ]

        postconditionCalls += [sdkFunction.name]

        addActorReference()
        addPostconditionAsserts()

        let innerStatements = [
            preconditions,
            statements,
            .string(""),
            .string("// When SDK function is called"),
            swiftFunctionCallExpr,
            .string(""),
            .string("// Then"),
            postconditionsGroup
        ]

        let autoreleasepoolExpr: SwiftExpr = .try(.string("autoreleasepool").call([
            .closure(nest: SwiftStatementsBuilder(statements: innerStatements))
        ], useTrailingClosures: true))

        var testFunctionImpl: [SwiftExpr] = [autoreleasepoolExpr]

        autoreleaseAsserts += [
            sdkReceivedAssert(self.postconditionCalls + self.autoreleaseCalls)
        ]

        if !autoreleaseAsserts.statements.isEmpty {
            testFunctionImpl += [
                .string(""),
                .string("// Then"),
                autoreleaseAsserts,
            ]
        }

        let testFunction = SwiftFunction(
            name: "test" + sdkFunction.name + "_Null",
            returnType: .void,
            code: SwiftCodeBlock(statements: testFunctionImpl))
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

    func buildSdkImplementation(sdkFunction: SwiftFunction ) -> SwiftExpr {

        let sdkFunctionParms = sdkFunction.parms

        var implementation: [SwiftExpr] = []
        let sdkParamNames = sdkFunctionParms.map({ $0.name })

        for sdkParam in sdkFunctionParms {

            if sdkParam.name == "ClientData" {
                implementation += [.string("XCTAssertNotNil(\(sdkParam.name))")]
            }

            else if let functionType = sdkParam.type.canonical.asFunction {
                let args = functionType.paramTypes.map { paramType -> SwiftFunctionCallArgExpr in

                    if let object = paramType.canonical.asPointer?.pointeeType.asDeclRef?.decl.canonical as? SwiftObject {
                        let objectInit = TestAsserts.nilInitialize(object: object, passthrough: ["ClientData"])
                        return .arg(nil, .function.pointerToTestObject(objectInit, type: paramType))
                    }

                    return TestAsserts.nilOrSomeExpr(paramType).arg(nil)
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

        implementation += [.string("GTest.current.sdkReceived.append(\(sdkFunction.name.quoted))")]

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
            let outerInit = outer.expr.call([.arg("Handle", .nil)])
            statements += [
                .string(""),
                .string("// Given Actor"),
                .let("object", type: outer.declRefType()).assign(outerInit)
            ]
            swiftFunctionCallExpr = .string("object").member(swiftFunctionCallExpr)

            outer.members.forEach { member in
                if let releaseFunc = member.type.asDeclRef?.decl.linked(.releaseFunc) as? SwiftFunction {
                    preconditions += [
                        .string(""),
                        .string("// Given implementation for SDK release function"),
                        buildSdkImplementation(sdkFunction: releaseFunc),
                    ]
                    autoreleaseCalls += [releaseFunc.name]
                    autoreleaseAsserts += [
                        .string("__on_\(releaseFunc.name) = nil"),
                    ]
                }
            }
        }
    }

    func addPostconditionAsserts() {

        if swiftFunction.isThrowing {
            swiftFunctionCallExpr = .try(swiftFunctionCallExpr)
        }

        postconditions += [sdkReceivedAssert(self.postconditionCalls)]

        swiftFunctionParms
            .filter(\.type.canonical.isFunction)
            .forEach { param in
                preconditions += [
                    .string("let waitFor\(param.name) = expectation(description: \"waitFor\(param.name)\")")
                ]
                postconditions += [.string("wait(for: [waitFor\(param.name)], timeout: 0.5)")]
            }

        if !swiftFunction.returnType.isVoid {
            if swiftFunction.returnType.canonical.isOptional == false,
               let object = swiftFunction.returnType.canonical.asDeclRef?.decl.canonical as? SwiftObject,
               !(object is SwiftEnum) {

                swiftFunctionCallExpr = SwiftFunctionCallExpr(
                    expr: .string("XCTAssertThrowsError"),
                    args: [
                        .arg(nil, swiftFunctionCallExpr),
                        .closure(
                            captures: [],
                            ["error"],
                            nest: .string("guard case SwiftEOSError.unexpectedNilResult = error else { return XCTFail(\"unexpected \\(error)\") }"),
                            identifier: nil
                        )
                    ],
                    useTrailingClosures: true
                )

            } else {

                let resultVar: SwiftVarDeclRefExpr = .let("result", type: swiftFunction.returnType)
                swiftFunctionCallExpr = resultVar.assign(swiftFunctionCallExpr)

                if swiftFunction.returnType.canonical.asGeneric?.genericType.asBuiltin?.builtinName.hasPrefix("SwiftEOS_Notification") == true {

                    guard let removeNotifyFunc = sdkFunction.linked(.removeNotifyFunc) as? SwiftFunction else { fatalError() }

                    postconditions += [
                        .string(""),
                        .string("// Given implementation for SDK remove notify function"),
                        buildSdkImplementation(sdkFunction: removeNotifyFunc)
                    ]
                    autoreleaseCalls += [removeNotifyFunc.name]

                    var notifyBuilder = SwiftStatementsBuilder()
                    notifyBuilder += [
                        .string("withExtendedLifetime").call([
                            .arg(nil, .string("result")),
                            .closure(captures: [], ["result"], nest: self.postconditionsGroup, identifier: nil)
                        ], useTrailingClosures: true),
                    ]
                    self.postconditionsGroup = notifyBuilder

                    autoreleaseAsserts += [
                        .string("__on_\(removeNotifyFunc.name) = nil"),
                    ]

                } else {

                    postconditions += [TestAsserts.assertNil(varDecl: resultVar.varDecl)]
                }
            }
        }
    }

    func sdkReceivedAssert(_ calls: @autoclosure @escaping () -> [String]) -> SwiftExpr {
        return .string("XCTAssertEqual(GTest.current.sdkReceived, [\(calls().map(\.quoted).joined(separator: ", "))])")
    }

}
