

import Foundation
import SwiftAST

public class SwiftFunctionInternalImplementationPass: SwiftRefactorPass {

    public override func refactor(module: SwiftModule) throws {
        try SwiftFunctionInternalImplementationPassVisitor().visit(ast: module)
    }
}

private class SwiftFunctionInternalImplementationPassVisitor: SwiftVisitor {

    override func visit(ast: SwiftAST) throws {

        if let object = ast as? SwiftObject {

            let funcs = object.inner
                .compactMap { $0 as? SwiftFunction }
                .filter { $0.sdk != nil }

            for function in funcs {

                let internalFunction = function.copy()

                internalFunction.name = "____" + internalFunction.name
                internalFunction.access = "private"
                for parm in internalFunction.parms {
                    parm.label = nil
                }

                let args = internalFunction.parms
                    .map { $0.isInOutParm ? SwiftInOutExpr(identifier: $0.expr).arg(nil) : $0.expr.arg(nil) }

                var internalFunctionCall = internalFunction.call(args)
                if function.isThrowing {
                    internalFunctionCall = .try(internalFunctionCall)
                }
                
                function.code = internalFunctionCall

                object.inner.append(internalFunction)
            }
        }

        try super.visit(ast: ast)
    }

    override func visit(type: SwiftType) throws -> SwiftType {
        return type
    }
}
