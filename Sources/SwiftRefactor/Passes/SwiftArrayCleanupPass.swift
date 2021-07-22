

import Foundation
import SwiftAST

final public class SwiftArrayCleanupPass: SwiftRefactorPass {

    public override func refactor(module: SwiftModule) throws {
        try SwiftArrayCleanupPassVisitor().visit(ast: module)
    }
}

private class SwiftArrayCleanupPassVisitor: SwiftVisitor {

    override func visit(ast: SwiftAST) throws {

        if let object = ast as? SwiftObject, object.inSwiftEOS {
            object.removeArrayCounts()
        }

        try super.visit(ast: ast)
    }

    override func visit(type: SwiftType) throws -> SwiftType {
        return type
    }
}
