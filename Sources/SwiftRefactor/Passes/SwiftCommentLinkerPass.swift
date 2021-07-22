

import Foundation
import SwiftAST

final public class SwiftCommentLinkerPass: SwiftRefactorPass {

    public override func refactor(module: SwiftModule) throws {
        try SwiftCommentLinkerPassVisitor().visit(ast: module)
    }
}

private class SwiftCommentLinkerPassVisitor: SwiftVisitor {

    override func visit(ast: SwiftAST) throws {

        if let function = ast as? SwiftFunction,
           let paramComments = function.comment?.paramComments {

            for param in function.parms {
                if let paramComment = paramComments.first(where: { $0.name == param.name }) {
                    paramComment.link(param: param)
                }
            }
        }

        try super.visit(ast: ast)
    }

    override func visit(type: SwiftType) throws -> SwiftType {
        return type
    }
}
