
import Foundation
import SwiftAST

final public class SwiftNamespacePass: SwiftRefactorPass {

    public override init() {}

    public override func refactor(module: SwiftModule) throws {

//        let objects = SwiftGatheringVisitor(astFilter: { $0 is SwiftObject}, typeFilter: nil).visit(ast: module)

        let visitor = SwiftModuleNamespacePassVisitor()
        try visitor.visit(ast: module)
    }
}

private class SwiftModuleNamespacePassVisitor: SwiftVisitor {

    var objectsByName: [String: SwiftObject] = [:]
    var functionsByName: [String: SwiftFunction] = [:]
    var aliasesByName: [String: SwiftTypealias] = [:]

    private func adjust(name: inout String)  {


    }

    public override func visit(ast: SwiftAST) throws {
//        adjust(name: &ast.name)
        try super.visit(ast: ast)
    }
}
