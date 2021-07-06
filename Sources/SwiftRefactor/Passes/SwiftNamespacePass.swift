
import Foundation
import SwiftAST

public class SwiftNamespacePass: SwiftRefactorPass {

    public override init() {}

    public override func refactor(module: SwiftModule) throws {
        try SwiftModuleNamespacePassVisitor().visit(ast: module)
    }
}

class SwiftModuleNamespacePassVisitor: SwiftVisitor {

    private func adjust(name: inout String)  {

        // Use SwiftEOS_ prefix
        if name.hasPrefix("EOS_") {
            name = "Swift" + name
        }
    }

    public override func visit(ast: SwiftAST) throws {
        adjust(name: &ast.name)
        try super.visit(ast: ast)
    }
}
