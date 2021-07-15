
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

                            if canonical.isOptional != false ||
                                canonical.isPointer ||
                                canonical.isFunction {
                                asserts.append(.string("XCTAssertNil(\(lhsText))"))
                            } else {
                                if declCanonical is SwiftEnum {
                                    asserts.append(.string("XCTAssertEqual(\(lhsText), .init(rawValue: .zero)!)"))
                                } else if canonical.isTuple || declCanonical is SwiftUnion || declCanonical is SwiftObject {
                                    asserts.append(.string("XCTFail(\"TODO: \(lhsText)\")"))
                                } else {
                                    asserts.append(.string("XCTAssertEqual(\(lhsText), .zero)"))
                                }
                            }
                        }

                        asserts.append(.string("let swiftObject = try \(object.name)(sdkObject: cstruct)"))

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
}
