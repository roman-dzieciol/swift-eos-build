
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

                        asserts.append(self.assertNil(object: sdkObject, lhsString: "cstruct"))

                        asserts.append(.string("let swiftObject = try XCTUnwrap(try \(object.name)(sdkObject: cstruct))"))

                        asserts.append(self.assertNil(object: object, lhsString: "swiftObject"))

                        statements.append(.try(.function.withZeroInitializedCStruct(
                            type: .string(sdkObject.name).member("self"),
                            cstructVarName: "cstruct",
                            nest: SwiftCodeBlock(statements: asserts))))

                        let function = SwiftFunction(
                            name: "testItZeroInitializesFrom" + sdkObject.name,
                            returnType: .void,
                            code: SwiftCodeBlock(statements: statements))
                        function.isThrowing = true
                        testObject.append(function)
                        module.append(testObject)
                        
                    }
            }
        }
    }

    func assertNil(object: SwiftObject, lhsString: String) -> SwiftExpr {
        var asserts: [SwiftStmt] = []
        object.members.forEach { member in
            let assertExpr = self.assertNil(
                member: member,
                lhsString: lhsString
            )
            asserts.append(assertExpr)
        }
        return SwiftCodeBlock(statements: asserts)
    }

    func assertNil(member: SwiftMember, lhsString: String) -> SwiftExpr {

        let lhsString = "\(lhsString).\(member.name)"
        let canonical = member.type.canonical
        let declCanonical = canonical.asDeclRef?.decl.canonical

        if canonical.isOptional != false ||
            canonical.isPointer ||
            canonical.isFunction {
            return .string("XCTAssertNil(\(lhsString))")
        }
        if declCanonical is SwiftEnum {
            return .string("XCTAssertEqual(\(lhsString), .init(rawValue: .zero)!)")
        }
        if let swiftObject = declCanonical as? SwiftObject {
            return assertNil(object: swiftObject, lhsString: lhsString)
        }
        if canonical.isUnion, let sdkMember = member.sdk as? SwiftMember {
            return assertNil(member: sdkMember, lhsString: lhsString)
        }
        if canonical.isBool {
            return .string("XCTAssertEqual(\(lhsString), false)")
        }
        if !canonical.isTuple {
            return .string("XCTAssertEqual(\(lhsString), .zero)")
        }

        return .string("XCTFail(\"TODO: \(lhsString)\")")
    }
}
