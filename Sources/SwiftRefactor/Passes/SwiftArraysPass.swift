
import Foundation
import SwiftAST

final public class SwiftArraysPass: SwiftRefactorPass {

    public override func refactor(module: SwiftModule) throws {

        // Link array buffer with array count variables
        DispatchQueue.concurrentPerform(iterations: module.inner.count) { index in
            if let ast = module.inner[index] as? SwiftDecl {
                try! SwiftyArrayLinker(in: ast).link()
            }
        }

        // Use Swift types for arrays
        try SwiftArraysPassVisitor().visit(ast: module)
    }
}


private class SwiftArraysPassVisitor: SwiftVisitor {

    override func visit(type: SwiftType) throws -> SwiftType {
        return type
    }

    override func visit(ast: SwiftAST) throws {

        if let varDecl = ast as? SwiftVarDecl, varDecl.linked(.arrayLength) != nil {

            let canonical = varDecl.type.canonical
            let qual = varDecl.type.qual.explicitlyOptional

            // A pointer
            if let pointer = canonical.asPointer {

                // Pointer<Void> is [UInt8]
                if pointer.asBuiltin?.isVoid == true {
                    varDecl.type = SwiftArrayType(elementType: SwiftBuiltinType(name: "UInt8"), qual: qual)
                }

                // Pointer<CChar> is String
                else if pointer.pointeeType.asCChar != nil {
                    varDecl.type = SwiftBuiltinType(name: "String", qual: qual)
                }

                // Pointer<Pointer<CChar>> is [String]
                else if let innerPointer = pointer.pointeeType.asPointer,
                        innerPointer.pointeeType.isCChar {
                    varDecl.type = SwiftArrayType(elementType: SwiftBuiltinType(name: "String"), qual: qual)
                }

                // Pointer<Pointer<Opaque>> is [Pointer<Opaque>]
                else if let innerPointer = pointer.pointeeType.asPointer,
                        let opaque = innerPointer.pointeeType.asOpaque,
                        let alias = varDecl.type.outer(type: opaque) {
                    varDecl.type = SwiftArrayType(elementType: alias.copy { $0.with(isOptional: innerPointer.isOptional).explicitlyOptional }, qual: qual)
                }

                // Pointer<Void> is [UInt8]
                else if pointer.pointeeType.isVoid == true {
                    varDecl.type = SwiftArrayType(elementType: SwiftBuiltinType(name: "UInt8"), qual: qual)
                }

                // Pointer<UInt8> is [UInt8]
                else if pointer.pointeeType.asBuiltin?.builtinName == "UInt8" {
                    varDecl.type = SwiftArrayType(elementType: SwiftBuiltinType(name: "UInt8"), qual: qual)
                }

                // Pointer<Int8> is [Int8]
                else if pointer.pointeeType.asBuiltin?.builtinName == "Int8" {
                    varDecl.type = SwiftArrayType(elementType: SwiftBuiltinType(name: "Int8"), qual: qual)
                }

                // Pointer<SwiftObject> is [SwiftObject]
                else if let declRef = pointer.pointeeType.asDeclRef, declRef.decl.canonical.inSwiftEOS {
                    varDecl.type = SwiftArrayType(elementType: declRef, qual: qual)
                }

                // Pointer<?> is [?]
                else {
                    var alias = pointer.pointeeType.withAlias(in: varDecl.type)
                    if alias == pointer {
                        alias = pointer.pointeeType
                    }
                    varDecl.type = SwiftArrayType(elementType: alias.explicitlyOptional, qual: qual)
                }

                varDecl.isMutable = pointer.isMutable
            }

            // An array
            else if canonical.asArray != nil {

                // [Void] is [UInt8]
                if canonical.asArray?.elementType.isVoid == true {
                    varDecl.type = SwiftArrayType(elementType: SwiftBuiltinType(name: "UInt8"), qual: qual)
                }

                else {
                    // Good already
                }
            }

            // Something else
            else {
                fatalError()
            }
        }

        else if let varDecl = ast as? SwiftVarDecl, varDecl.linked(.arrayBuffer) != nil {

            let canonical = varDecl.type.canonical

            // Pointer<?> is ?
            if let pointer = canonical.asPointer {
                varDecl.type = pointer.pointeeType
                varDecl.isMutable = pointer.isMutable
            }

            // An Int
            else if canonical.asBuiltin?.isInt == true {
                // Good already
            }

            // Something else
            else {
                fatalError()
            }
        }

        try super.visit(ast: ast)
    }
}
