
import Foundation
import SwiftAST

public class SwiftCleanupPass: SwiftRefactorPass {

    public override init() {}

    public override func refactor(module: SwiftModule) throws {
        try SwiftCleanupPassVisitor().visit(ast: module)
    }
}

class SwiftCleanupPassVisitor: SwiftVisitor {

    override func visit(ast: SwiftAST) throws {

        // DEV: ensure functions have some code, for testing individual pass compilation
        if let function = ast as? SwiftFunction, function.code == nil {
            function.code = SwiftTempExpr { swift in
                swift.write(name: "fatalError()")
            }
        }

        if let function = ast as? SwiftFunction {
            function.parms.forEach { parm in
                if parm.comment != nil,
                   let parmComments = parm.comment?.comments,
                   function.comment?.comments.contains(where: { ($0 as? SwiftCommentParam)?.name == parm.name }) != true
                {
                    function.comment = function.comment ?? SwiftComment("")
                    function.comment?.inner.append(SwiftCommentParam(name: parm.name, comments: parmComments))
                }
            }
        }

        try super.visit(ast: ast)
    }

}
