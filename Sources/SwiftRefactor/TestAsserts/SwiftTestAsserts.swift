
import Foundation
import SwiftAST


public struct TestOptions: OptionSet {

    public static let nilApiVersion = TestOptions(rawValue: 1 << 0)
    public static let nilClientData = TestOptions(rawValue: 1 << 1)

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}


struct TestAsserts {

    static func nilInitialize(object: SwiftObject, passthrough: Set<String> = []) -> SwiftFunctionCallExpr {
        let args = object.members.map { member -> SwiftFunctionCallArgExpr in

            if member.name == "ApiVersion", let apiVersionExpr = (member.linked(.apiVersion) as? SwiftExprRef)?.expr {
                return .arg(member.name, apiVersionExpr)
            }
            else if passthrough.contains(member.name) {
                return .arg(member.name, member.expr)
            }
            else {
                return TestAsserts.nilArg(varDecl: member)
            }
        }
        return object.expr.call(args)
    }

    static func assertNil(object: SwiftObject, lhsString: String = "", options: TestOptions = []) -> SwiftExpr {
        var asserts: [SwiftStmt] = []
        object.members.forEach { member in
            let assertExpr = self.assertNil(
                varDecl: member,
                lhsString: lhsString,
                options: options
            )
            asserts.append(assertExpr)
        }
        return SwiftCodeBlock(statements: asserts)
    }

    static func assertNil(sdkParam: SwiftVarDecl, swiftFunction: SwiftFunction, sdkFunction: SwiftFunction) -> SwiftExpr {
//        if swiftFunction.parms.contains(where: {
//            $0.name == sdkParam.name
//            && $0.type.canonical.optional == sdkParam.type.canonical.asPointer?.pointeeType.optional
//        }) {
//            return .string("XCTAssertEqual(\(sdkParam.name), \(TestAsserts.nilOrSomeExpr(sdkParam.type)))")
//        }

        return assertNil(varDecl: sdkParam)
    }

    static func assertNil(swiftParam: SwiftVarDecl, swiftFunction: SwiftFunction, sdkFunction: SwiftFunction) -> SwiftExpr {
//        if sdkFunction.parms.contains(where: {
//            $0.name == swiftParam.name
//            && $0.type.canonical.asPointer?.pointeeType.optional == swiftParam.type.canonical.optional
//        }) {
//            return .string("XCTAssertEqual(\(swiftParam.name), \(TestAsserts.nilOrSomeExpr(swiftParam.type)))")
//        }

        return assertNil(varDecl: swiftParam)
    }

    static func assertNil(varDecl: SwiftVarDecl, lhsString: String = "", options: TestOptions = []) -> SwiftExpr {

        let lhsMemberString = lhsString.isEmpty ? varDecl.name : "\(lhsString).\(varDecl.name)"
        let canonical = varDecl.type.canonical
        let declCanonical = canonical.asDeclRef?.decl.canonical
        let swiftVarDecl: SwiftVarDecl? = varDecl.inSwiftEOS ? varDecl : (varDecl.swifty as? SwiftVarDecl)
        let isInOut = (swiftVarDecl as? SwiftFunctionParm)?.isInOutParm == true

        if isInOut {
            if swiftVarDecl?.type.canonical.isString == true {
                if varDecl.inSwiftEOS {
                    return .string("XCTAssertEqual(\(lhsMemberString), \"\")")
                } else {
                    return .string("XCTAssertNil(\(lhsMemberString))")
                }
            }

            if canonical.asDeclRef?.decl.canonical is SwiftEnum {
                return .string("XCTAssertEqual(\(lhsMemberString), .zero)")
            }

            return .string("XCTAssertNotNil(\(lhsMemberString))")
        }

        if varDecl.name == "ApiVersion" {
            if !options.contains(.nilApiVersion), let apiVersionExpr = (varDecl.linked(.apiVersion) as? SwiftExprRef)?.expr {
                return .string("XCTAssertEqual(\(lhsMemberString), \(SwiftWriterString.description(for: apiVersionExpr)))")
            } else {
                return .string("XCTAssertEqual(\(lhsMemberString), .zero)")
            }
        }

        if let declCanonical = canonical.asPointer?.pointeeType.asDeclRef?.decl.canonical,
           let object = declCanonical as? SwiftObject,
           object.name.contains("CallbackInfo"),
           !object.inSwiftEOS {
            return assertNil(object: object, lhsString: lhsMemberString + "!.pointee")
        }

        if varDecl.name == "ClientData" {
            if options.contains(.nilClientData) {
                return .string("XCTAssertNil(\(lhsMemberString))")
            } else {
                return .string("XCTAssertNotNil(\(lhsMemberString))")
            }
        }

        if canonical.isOptional == false {
            if canonical.isFixedWidthString, let builtin = canonical.asBuiltin {
                if varDecl.inSwiftEOS {
                    return .string("XCTAssertEqual(\(lhsMemberString), .zero)")
                } else {
                    return .string("XCTAssertEqual(\(builtin.builtinName)(tuple: \(lhsMemberString)), .zero)")
                }
            }
            if let swiftObject = declCanonical as? SwiftObject, !(swiftObject is SwiftEnum) {
                return assertNil(object: swiftObject, lhsString: lhsMemberString)
            }
            if canonical.isUnion, let sdkMember = varDecl.sdk as? SwiftMember {
                return assertNil(varDecl: sdkMember, lhsString: lhsString)
            }
        }

        if let nilExpr = canonical.nilExpr {
            if nilExpr === SwiftExpr.nil {
                return .string("XCTAssertNil(\(lhsMemberString))")
            }
            return .string("XCTAssertEqual(\(lhsMemberString), \(nilExpr.description))")
        }

        if canonical.isPointer {
            return .string("XCTAssertNil(\(lhsMemberString))")
        }

        if canonical.isFunction {
            return .string("XCTAssertNil(\(lhsMemberString))")
        }

        if canonical.asDeclRef?.decl.canonical is SwiftEnum {
            return .string("XCTAssertEqual(\(lhsMemberString), .zero)")
        }

        return .string("XCTFail(\" TODO: \(lhsMemberString) \(canonical)\")")

    }


    static func nilArg(varDecl: SwiftVarDecl) -> SwiftFunctionCallArgExpr {


        let canonical = varDecl.type.canonical

        let labelExpr: SwiftExpr? = {
            if let parm = varDecl as? SwiftFunctionParm {
                return parm.label.map { SwiftExpr.string($0) }
            } else {
                return varDecl.expr
            }
        }()

        if let functionType = canonical.asFunction {
            
            var closureStatements: [SwiftStmt] = []
            var argNames: [String] = []

            for (index, paramType) in functionType.paramTypes.enumerated() {
                let argName = "arg\(index)"
                argNames.append(argName)
                closureStatements.append(
                    self.assertNil(
                        varDecl: SwiftVarDecl(
                            name: argName,
                            inner: [],
                            attributes: [],
                            type: paramType,
                            isMutable: false,
                            comment: nil),
                        lhsString: ""))
            }

            if functionType.qual.attributes.contains("@convention(c)") {
                closureStatements += [
                    .string("GTest.current.sdkReceived.append(\(varDecl.name.quoted))")
                ]
            } else {
                closureStatements += [
                    .string("waitFor\(varDecl.name).fulfill()")
                ]
            }

            if !functionType.returnType.isVoid {
                let nilExpr = TestAsserts.nilOrSomeExpr(functionType.returnType)
                closureStatements += [
                    .string("return \(nilExpr.description)")
                ]
            }

            let closure = SwiftClosureExpr(
                captures: [],
                params: argNames,
                omitParams: false,
                resultType: nil,
                omitResultType: false,
                isThrowing: false,
                statements: SwiftCodeBlock(statements: closureStatements)
            )

            return closure.arg(labelExpr)
        }

        else if let nilExpr = canonical.nilExpr {
            return nilExpr.arg(labelExpr)
        }

        else if let declCanonical = canonical.asDeclRef?.decl.canonical, let object = declCanonical as? SwiftObject {

            let objectInit = TestAsserts.nilInitialize(object: object, passthrough: [])
            //            let args = object.members.map { nilArg(varDecl: $0) }
            return objectInit.arg(labelExpr)
        }

        else if canonical.isOpaquePointer, canonical.isOptional == false {
            return .string(".nonZeroPointer").arg(labelExpr)
        }

        else if canonical.asPointer?.pointeeType.isCChar == true {
            return .function.pointerToTestString(.string(".empty"), type: .string).arg(labelExpr)
        }

        else if canonical.isPointer == true {
            return .string(".nonZeroPointer").arg(labelExpr)
        }

        else {
            print(varDecl.type)
            return SwiftExpr.string("/* TODO */").arg(labelExpr)
        }
    }


    static func nilOrSomeExpr(_ type: SwiftType) -> SwiftExpr {
        let canonical = type.canonical
        if let nilExpr = canonical.nilExpr {
            return nilExpr
        }

        if canonical.isOpaquePointer, canonical.isOptional == false {
            return .string(".nonZeroPointer")
        }
        return .string("TODO: \(canonical)")
    }
}
