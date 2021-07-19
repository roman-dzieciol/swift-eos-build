
import Foundation
import SwiftAST

struct TestAsserts {

    static func nilInitialize(object: SwiftObject, passthrough: Set<String> = []) -> SwiftFunctionCallExpr {
        let args = object.members.map { member -> SwiftFunctionCallArgExpr in
            if passthrough.contains(member.name) {
                return .arg(member.name, member.expr)
            } else {
                return TestAsserts.nilArg(varDecl: member)
            }
        }
        return object.expr.call(args)
    }

    static func assertNil(object: SwiftObject, lhsString: String = "") -> SwiftExpr {
        var asserts: [SwiftStmt] = []
        object.members.forEach { member in
            let assertExpr = self.assertNil(
                varDecl: member,
                lhsString: lhsString
            )
            asserts.append(assertExpr)
        }
        return SwiftCodeBlock(statements: asserts)
    }

    static func assertNil(varDecl: SwiftVarDecl, lhsString: String = "") -> SwiftExpr {

        let lhsMemberString = lhsString.isEmpty ? varDecl.name : "\(lhsString).\(varDecl.name)"
        let canonical = varDecl.type.canonical
        let declCanonical = canonical.asDeclRef?.decl.canonical

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

        if let nilExpr = canonical.nilExpr {
            return nilExpr.arg(labelExpr)
        }

        else if canonical.isOpaquePointer() {
            return .string(".nonZeroPointer").arg(labelExpr)
        }

        else if let declCanonical = canonical.asDeclRef?.decl.canonical, let object = declCanonical as? SwiftObject {
            let args = object.members.map { nilArg(varDecl: $0) }
            return object.expr.call(args).arg(labelExpr)
        }

        else if let functionType = canonical.asFunction {

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

            closureStatements += [
                .string("waitFor\(varDecl.name).fulfill()")
            ]

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

        if canonical.isOpaquePointer(), canonical.isOptional == false {
            return .string(".nonZeroPointer")
        }
        return .string("TODO: \(canonical)")
    }
}
