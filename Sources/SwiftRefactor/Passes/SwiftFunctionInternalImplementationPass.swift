

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

                var args: [SwiftFunctionCallArgExpr] = []

                for parm in function.parms {
                    if parm.name.hasSuffix("Options"),
                       let optionsObject = parm.type.canonical.asDeclRef?.decl.canonical as? SwiftObject,
                       let initFunc = optionsObject.linked(.functionInitMemberwise) as? SwiftFunction {

                        let optionsArgs = initFunc.parms
                            .filter { $0.defaultValue == nil }
                            .map { $0.copy() }

                        function.replace(parm: parm, with: optionsArgs)

                        let optionsInit = SwiftExpr.string(".init").call(optionsArgs.map { optionArg in
                            if let label = optionArg.label {
                                return optionArg.expr.arg(label)
                            } else {
                                return optionArg.expr.arg(nil)
                            }
                        })
                        args.append(optionsInit.arg(nil))

                    } else {
                        if parm.isInOutParm {
                            args.append(.inout(parm.expr).arg(nil))
                        } else {
                            args.append(parm.expr.arg(nil))
                        }
                    }
                }

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
