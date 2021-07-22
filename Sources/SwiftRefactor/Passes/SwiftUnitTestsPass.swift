
import Foundation
import SwiftAST

final public class SwiftUnitTestsPass: SwiftRefactorPass {

    let swiftTestsModule: SwiftModule
    let swiftSdkTestsModule: SwiftModule

    public init(swiftTestsModule: SwiftModule, swiftSdkTestsModule: SwiftModule) {
        self.swiftTestsModule = swiftTestsModule
        self.swiftSdkTestsModule = swiftSdkTestsModule
    }

    public override func refactor(module: SwiftModule) throws {
        try addFunctionTests(for: module)
        try addObjectTests(for: module)
    }

    func addObjectTests(for module: SwiftModule) throws {

        let testOptions: TestOptions = [.nilApiVersion, .nilClientData]

        try SwiftGatheringVisitor.decls(in: module, astFilter: { $0 is SwiftObject && $0.inSwiftEOS }, typeFilter: nil) { objects, types in
            objects
                .compactMap { $0 as? SwiftObject }
                .forEach { object in
                    if object.linked(.functionInitFromSdkObject) != nil, let sdkObject = object.sdk as? SwiftObject {

                        var statements: [SwiftStmt] = []
                        let testObject = SwiftObject(name: object.name + "Tests", tagName: "class", superTypes: ["XCTestCase"])
                        testObject.attributes.insert("final")
                        var asserts: [SwiftStmt] = []

                        asserts.append(TestAsserts.assertNil(object: sdkObject, lhsString: "cstruct", options: testOptions))

                        asserts.append(.string("let swiftObject = try XCTUnwrap(try \(object.name)(sdkObject: cstruct))"))

                        asserts.append(TestAsserts.assertNil(object: object, lhsString: "swiftObject", options: testOptions))

                        statements.append(.try(.function.withZeroInitializedCStruct(
                            type: .string(sdkObject.name).member("self"),
                            cstructVarName: "cstruct",
                            nest: SwiftStatementsBuilder(statements: asserts))))

                        let function = SwiftFunction(
                            name: "testItZeroInitializesFrom" + sdkObject.name,
                            returnType: .void,
                            code: SwiftStatementsBuilder(statements: statements))
                        function.isThrowing = true
                        testObject.append(function)
                        self.swiftTestsModule.append(testObject)

                    }
                }
        }
    }

    func addFunctionTests(for module: SwiftModule) throws {
        guard let sdkModule = module.sdk else { return }
        try SwiftGatheringVisitor.decls(in: sdkModule, astFilter: { $0 is SwiftFunction }, typeFilter: nil) { sdkFunctions, types in
            sdkFunctions
                .compactMap { $0 as? SwiftFunction }
                .forEach { sdkFunction in

                    guard sdkFunction.name != "EOS_Logging_SetCallback" else { return }

                    guard let function = sdkFunction.swifty as? SwiftFunction, function.inModule else { return }
                    let testObject = SwiftObject(name: "Swift" + sdkFunction.name + "Tests", tagName: "class", superTypes: ["XCTestCase"])
                    let result = SdkTestFunctionBuilder(swiftFunction: function, valueType: .null).build()
                    testObject.append(result)
                    testObject.attributes.insert("final")
                    self.swiftSdkTestsModule.append(testObject)
                }
        }
    }

}
