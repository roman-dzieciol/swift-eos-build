
import Foundation
import SwiftAST

final class SdkTestFunctionBuilder {

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

    let valueType: TestValueType

    init(swiftFunction: SwiftFunction, valueType: TestValueType) {
        self.swiftFunction = swiftFunction
        self.swiftFunctionParms = swiftFunction.parms

        self.sdkFunction = swiftFunction.sdk as! SwiftFunction

        self.preconditions = SwiftStatementsBuilder()
        self.statements = SwiftStatementsBuilder()
        self.postconditions = SwiftStatementsBuilder()
        self.postconditionsGroup = postconditions
        self.autoreleaseAsserts = SwiftStatementsBuilder()
        self.valueType = valueType
    }

    func build() -> SwiftFunction {

        preconditions += [.string("GTest.current.reset()")]

        let swiftFunctionCall = buildSwiftFunctionCall()
        swiftFunctionCallExpr = swiftFunctionCall

        statements += [
            .string(""),
            .string("// Given implementation for SDK function"),
            buildSdkImplementation(sdkFunction: sdkFunction, calls: &postconditionCalls),
            .string("defer { __on_\(sdkFunction.name) = nil }"),
        ]

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
            code: SwiftStatementsBuilder(statements: testFunctionImpl))
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
                postconditions += [TestAsserts.assertNil(swiftParam: parm, swiftFunction: swiftFunction, sdkFunction: sdkFunction)]
                swiftFunctionArgs += [parm.expr.inout.arg(parm.label.map { .string($0) })]
            } else {
                swiftFunctionArgs += [TestAsserts.nilArg(varDecl: parm)]
            }
        }

        return swiftFunction.call(swiftFunctionArgs, useTrailingClosures: false)
    }

    func buildSdkImplementation(sdkFunction: SwiftFunction, calls: inout [String]) -> SwiftExpr {

        let sdkFunctionParms = sdkFunction.parms

        var implementation: [SwiftExpr] = []
        let sdkParamNames = sdkFunctionParms.map({ $0.name })

        implementation += [.string("GTest.current.sdkReceived.append(\(sdkFunction.name.quoted))")]
        calls += [sdkFunction.name]

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

                let lhsString = "\(sdkParam.name)!.pointee"

                optionsObject.members.forEach { member in
                    if let functionType = member.type.canonical.asFunction {
                        let args = functionType.paramTypes.map { paramType -> SwiftFunctionCallArgExpr in

                            if let object = paramType.canonical.asPointer?.pointeeType.asDeclRef?.decl.canonical as? SwiftObject {
                                let objectInit = TestAsserts.nilInitialize(object: object, passthrough: ["ClientData"])
                                return .arg(nil, .function.pointerToTestObject(objectInit, type: paramType))
                            }

                            return TestAsserts.nilOrSomeExpr(paramType).arg(nil)
                        }

                        let invocation: SwiftExpr = .string(lhsString).member(member.expr.optional).call(args)

                        if !functionType.returnType.isVoid {
                            let resultVarName = "resultOf\(sdkParam.name)\(member.name)"
                            implementation += [
                                .string("let \(resultVarName)").assign(invocation),
                                TestAsserts.assertNil(varDecl: functionType.returnType.toVar(named: resultVarName)),
                            ]
                        } else {
                            implementation += [
                                invocation,
                            ]
                        }

                        if functionType.qual.attributes.contains("@convention(c)") {
                            calls += [member.name]
                        }
                    }
                    else {
                        let assertExpr = TestAsserts.assertNil(
                            varDecl: member,
                            lhsString: lhsString
                        )
                        implementation += [assertExpr]
                    }
                }
            }

            else {
                implementation += [TestAsserts.assertNil(sdkParam: sdkParam, swiftFunction: swiftFunction, sdkFunction: sdkFunction)]
            }
        }

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
            statements: SwiftStatementsBuilder(statements: implementation)
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
                        buildSdkImplementation(sdkFunction: releaseFunc, calls: &autoreleaseCalls),
                    ]
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

        swiftFunctionParms
            .filter(\.type.canonical.isFunction)
            .forEach { param in

                if param.type.canonical.asFunction?.qual.attributes.contains("@convention(c)") == true {
//                    self.postconditionCalls += [param.name]
                } else {
                    preconditions += [
                        .string("let waitFor\(param.name) = expectation(description: \"waitFor\(param.name)\")")
                    ]
                    postconditions += [.string("wait(for: [waitFor\(param.name)], timeout: 0.5)")]
                }
            }

        postconditions += [sdkReceivedAssert(self.postconditionCalls)]

        if !swiftFunction.returnType.isVoid {

            if (swiftFunction.linked(.implementation) as? SwiftFunction)?.isThrowingNilResult() == true {
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
                        buildSdkImplementation(sdkFunction: removeNotifyFunc, calls: &autoreleaseCalls)
                    ]

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

extension SwiftFunction {

    func isThrowingNilResult() -> Bool {
        let isThrowingNilResult: Bool? = code?.perform { expr in
            if let functionCall = expr as? SwiftFunctionCallExpr,
               let literalIdentifier = functionCall.expr as? SwiftLiteralExpr,
               literalIdentifier.literalType == .string,
               literalIdentifier.literal() == "throwingNilResult"
            {
                return true
            }
            return nil
        }
        return isThrowingNilResult == true
    }

}
