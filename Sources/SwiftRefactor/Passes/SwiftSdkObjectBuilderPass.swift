

import Foundation
import SwiftAST

public class SwiftSdkObjectBuilderPass: SwiftRefactorPass {

    public override func refactor(module: SwiftModule) throws {
        try SwiftSdkObjectBuilderPassVisitor().visit(ast: module)
    }
}

private class SwiftSdkObjectBuilderPassVisitor: SwiftVisitor {

    override func visit(ast: SwiftAST) throws {

        guard ast.inSwiftEOS else { return }

        // For each function copied from SDK module
        if let function = ast as? SwiftFunction, function.sdk != nil {
            for parm in function.parms {
                if let swiftObject = parm.type.canonical.asDeclRef?.decl.canonical as? SwiftObject,
                   swiftObject.inSwiftEOS,
                   swiftObject.sdk != nil {
                    try swiftObject.addSdkObjectFactory()
                }
            }
        }

        try super.visit(ast: ast)
    }

    override func visit(type: SwiftType) throws -> SwiftType {
        return type
    }
}
