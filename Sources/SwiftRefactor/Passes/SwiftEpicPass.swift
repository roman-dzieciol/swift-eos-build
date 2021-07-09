
import Foundation
import SwiftAST

public class SwiftEpicPass: SwiftRefactorPass {

    public override init() {}

    public override func refactor(module: SwiftModule) throws {
        try SwiftModuleEpicPassVisitor().visit(ast: module)
    }
}

class SwiftModuleEpicPassVisitor: SwiftVisitor {

    private func adjust(name: inout String)  {
        if name.hasPrefix("EOS_") {
            name = "Swift" + name
        }
    }

    public override func visit(ast: SwiftAST) throws {
        guard ast.inSwiftEOS else { return }
        adjust(name: &ast.name)
        try super.visit(ast: ast)
    }
}
