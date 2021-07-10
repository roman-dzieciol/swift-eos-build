

import Foundation
import SwiftAST

public class SwiftFunctionsPass: SwiftRefactorPass {

    public override func refactor(module: SwiftModule) throws {
        try SwiftFunctionsPassVisitor().visit(ast: module)
    }
}

private class SwiftFunctionsPassVisitor: SwiftVisitor {

    override func visit(ast: SwiftAST) throws {

        guard ast.inSwiftEOS else { return }

        // For each function copied from SDK module
        if let function = ast as? SwiftFunction, let sdkFunction = function.sdk as? SwiftFunction {

            // Add labels to parms
            for parm in function.parms {
                if parm.label == nil {
                    parm.label = parm.name
                }
            }

            // Add SDK call
            if function.code == nil {
                function.code = try SwiftSDKCall(function: function, sdkFunction: sdkFunction, outer: stack.last as! SwiftDecl).functionCode()
            }
        }

        // function type parms are @escaping
        if let parm = ast as? SwiftFunctionParm,
           parm.type.canonical.isFunction,
           !parm.attributes.contains("@escaping") {
            parm.attributes.formUnion(["@escaping"])
        }

        try super.visit(ast: ast)
    }

    override func visit(type: SwiftType) throws -> SwiftType {

        // function type parms are not @convention(c)
        if  type.isFunction,
            type.qual.attributes.contains("@convention(c)"),
           stack.contains(where: { $0 is SwiftFunction }) {
            return try type
                .copy({ $0.with(attributes: type.qual.attributes.subtracting(["@convention(c)"]))})
                .handle(visitor: self)
        }


        return try super.visit(type: type)
    }
}

