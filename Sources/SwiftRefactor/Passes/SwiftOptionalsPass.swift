
import Foundation
import SwiftAST

public class SwiftOptionalsPass: SwiftRefactorPass {

    public override func refactor(module: SwiftModule) throws {
        try SwiftOptionalsPassVisitor().visit(ast: module)
    }
}

private class SwiftOptionalsPassVisitor: SwiftVisitor {

    let nonOptionalFunctionParms = Set<String>([
        "Options",
        "Handle",
        "NotificationFn"
    ])

    override func visit(ast: SwiftAST) throws {
        try super.visit(ast: ast)
    }

    override func visit(type: SwiftType) throws -> SwiftType {

        // String are optional by default as they can be nil
        if type.isString {
            return type.optional
        }

        // Arrays are optional by default as they can be nil
        if type.isArray {
            return type.optional
        }

        // Pointers are optional by default as they can be nil
        if type.isPointer {

            for element in stack.reversed() {

                // Non optional function parms
                if let functionParm = element as? SwiftFunctionParm, nonOptionalFunctionParms.contains(functionParm.name) {
                    return type.nonOptional
                }
            }

            return type.optional
        }

        // Typealiases of pointers are optional, as pointer types in swift do not represent nullable pointers and C nullability is unspecified
        if type.asTypealiasRef != nil, type.canonical.isPointer {
            return type.optional
        }

        // Types with unspecified optionality are optional so that it can be handled explicitly
        if type.qual.isOptional == nil {
            return type.optional
        }

        return try super.visit(type: type)
    }
}
