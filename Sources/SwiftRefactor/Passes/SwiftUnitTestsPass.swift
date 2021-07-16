
import Foundation
import SwiftAST

public class SwiftUnitTestsPass: SwiftRefactorPass {

    public override init() {}

    public override func refactor(module: SwiftModule) throws {

        try SwiftGatheringVisitor.decls(in: module, astFilter: { $0 is SwiftObject && $0.inSwiftEOS }, typeFilter: nil) { objects, types in
            objects
                .compactMap { $0 as? SwiftObject }
                .forEach { object in
                    if object.linked(.functionInitFromSdkObject) != nil, let sdkObject = object.sdk as? SwiftObject {
                        var statements: [SwiftStmt] = []
                        let testObject = SwiftObject(name: object.name + "Tests", tagName: "class", superTypes: ["XCTestCase"])
                        var asserts: [SwiftStmt] = []

                        sdkObject.members.forEach { sdkMember in
                            let lhsText = "cstruct.\(sdkMember.name)"
                            let canonical = sdkMember.type.canonical
                            let declCanonical = canonical.asDeclRef?.decl.canonical
                            let assertExpr = self.assertNil(
                                lhsText: lhsText,
                                type: sdkMember.type,
                                canonical: canonical,
                                declCanonical: declCanonical
                            )
                            asserts.append(assertExpr)
                        }

                        asserts.append(.string("let swiftObject = try XCTUnwrap(try \(object.name)(sdkObject: cstruct))"))

                        object.members.forEach { member in
                            let lhsText = "swiftObject.\(member.name)"
                            let canonical = member.type.canonical
                            let declCanonical = canonical.asDeclRef?.decl.canonical
                            let assertExpr = self.assertNil(
                                lhsText: lhsText,
                                type: member.type,
                                canonical: canonical,
                                declCanonical: declCanonical
                            )
                            asserts.append(assertExpr)
                        }

                        statements.append(.try(.function.withZeroInitializedCStruct(
                            type: .string(sdkObject.name).member("self"),
                            cstructVarName: "cstruct",
                            nest: SwiftCodeBlock(statements: asserts))))

                        let code = SwiftCodeBlock(statements: statements)
                        let function = SwiftFunction(
                            name: "testItZeroInitializesFrom" + sdkObject.name,
                            returnType: .void,
                            code: code)
                        function.isThrowing = true
                        testObject.append(function)
                        module.append(testObject)
                        
                    }
            }
        }
    }

    func assertNil(lhsText: String, type: SwiftType, canonical: SwiftType, declCanonical: SwiftAST?) -> SwiftExpr {

        if canonical.isOptional != false ||
            canonical.isPointer ||
            canonical.isFunction {
            return .string("XCTAssertNil(\(lhsText))")
        } else {
            if declCanonical is SwiftEnum {
                return .string("XCTAssertEqual(\(lhsText), .init(rawValue: .zero)!)")
            } else if canonical.isTuple || canonical.isUnion || declCanonical is SwiftObject {
                return .string("XCTFail(\"TODO: \(lhsText)\")")
            } else if canonical.isBool {
                return .string("XCTAssertEqual(\(lhsText), false)")
            } else {
                return .string("XCTAssertEqual(\(lhsText), .zero)")
            }
        }
    }
}
