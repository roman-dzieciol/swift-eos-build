
import Foundation
import SwiftAST

public class SwiftTypesPass: SwiftRefactorPass {

    public override func refactor(module: SwiftModule) throws {
        try SwiftTypesTypePassVisitor().visit(ast: module)
        try SwiftTypesDeclPassVisitor().visit(ast: module)
    }
}

private class SwiftTypesTypePassVisitor: SwiftVisitor {

    override func visit(type: SwiftType) throws -> SwiftType {

        let canonical = type.canonical

        // A const char ** is an [String]?
        if canonical.asPointer?.isMutable == false,
           canonical.asPointer?.pointeeType.asPointer?.pointeeType.asCChar != nil {
            let builtinType = SwiftBuiltinType(name: "String", qual: type.qual)
            return SwiftArrayType(elementType: builtinType, qual: type.qual.optional)
        }

        // A const char * is a String?
        if canonical.asPointer?.isMutable == false,
            canonical.asPointer?.pointeeType.asCChar != nil {
            return SwiftBuiltinType(name: "String", qual: type.qual.optional)
        }

        // An immutable pointer to SwiftEOS object is object
        if let declType = canonical.asPointer?.pointeeType.asDeclRef,
           declType.decl.canonical is SwiftObject,
           declType.decl.canonical.inSwiftEOS,
           canonical.asPointer?.isMutable == false {
            return SwiftDeclRefType(decl: declType.decl, qual: type.qual.explicitlyOptional)
        }

        // An EOS_Bool is Bool
        if canonical.isInt,
           let declType = type.asDeclRef,
           declType.decl.canonical.name == "EOS_Bool" {
            return SwiftBuiltinType(name: "Bool", qual: type.qual.explicitlyOptional)
        }

        // An typealias to Swift Object is Swift Object
        if let declType = canonical.asPointer?.pointeeType.asDeclRef,
           declType.decl.canonical is SwiftObject,
           declType.decl.canonical.inSwiftEOS,
           canonical.asPointer?.isMutable == false {
            return SwiftDeclRefType(decl: declType.decl, qual: type.qual.explicitlyOptional)
        }

        // Word plus sized integers are represented as 64-bit Int in user facing API
        // Signed Int is the Swift standard for all values that do not represent bits or masks
        // This is due to checked numeric type casts that require verbose implementation
        // All the verbose safe type casts required are implemented inside of the framework in automated way
        if let builtinType = canonical.asBuiltin,
           SwiftBuiltinType.intTypesExactlyConvertibleToInt.contains(builtinType.builtinName),
           SwiftBuiltinType.intTypes32BitPlus.contains(builtinType.builtinName) {
            return SwiftBuiltinType(name: "Int", qual: type.qual.explicitlyOptional)
        }

        return try super.visit(type: type)
    }

    override func visit(ast: SwiftAST) throws {

        // Keep ApiVersion Int32 type so that constants are compatible
        if ast.name == "ApiVersion" {
            return
        }

        try super.visit(ast: ast)
    }
}

private class SwiftTypesDeclPassVisitor: SwiftVisitor {

    override func visit(ast: SwiftAST) throws {

        // opaque members are optional
        if let varDecl = ast as? SwiftMember,
           varDecl.type.canonical.baseType.isOpaque,
           varDecl.type.isOptional != true {
            print("---- \(varDecl.name)")
            varDecl.type = varDecl.type.optional
        }


        // function type members are optional
        if let member = ast as? SwiftMember,
           member.type.canonical.isFunction,
           member.type.isOptional != true {
            member.type = member.type.optional
        }

        // WORKAROUND: RequestedChannel has optional UInt8 type
        if ast.name == "RequestedChannel",
           let varDecl = ast as? SwiftVarDecl,
           varDecl.type.canonical.asPointer?.pointeeType.asBuiltin?.builtinName == "UInt8" {
            varDecl.type = SwiftBuiltinType(name: "UInt8", qual: .optional)
        }

        // Change non-array var decls only
        else if let varDecl = ast as? SwiftVarDecl, varDecl.linked(.arrayLength) == nil, varDecl.linked(.arrayBuffer) == nil {

            let canonical = varDecl.type.canonical
            let qual = varDecl.type.qual.explicitlyOptional

            // A mutable pointer to mutable pointer to SwiftEOS object is inout object
            if let pointer = canonical.asPointer,
               let innerPointer = pointer.pointeeType.asPointer,
               let declType = innerPointer.pointeeType.asDeclRef,
               pointer.isMutable,
               innerPointer.isMutable {
                varDecl.type = SwiftDeclRefType(decl: declType.decl, qual: qual)
                varDecl.isMutable = pointer.isMutable
            }

            // char * is inout String
            else if let pointer = canonical.asPointer,
                    pointer.isMutable == true,
                    pointer.pointeeType.asCChar != nil {

                varDecl.type = .string
                varDecl.isMutable = pointer.isMutable

            }

            // A mutable pointer to declRef is inout declRef
            else if let pointer = canonical.asPointer,
                    let declType = pointer.pointeeType.asDeclRef,
                    pointer.isMutable {
                varDecl.type = SwiftDeclRefType(decl: declType.decl, qual: qual)
                varDecl.isMutable = pointer.isMutable
            }

            // A mutable pointer to builtin Int is inout Int
            else if let pointer = canonical.asPointer,
                    let builtin = pointer.pointeeType.asBuiltin,
                    builtin.isNumeric,
                    pointer.isMutable {
                varDecl.type = SwiftBuiltinType(name: builtin.builtinName, qual: qual)
                varDecl.isMutable = pointer.isMutable
            }

            // A mutable pointer to opaque pointer is inout opaque pointer
            else if let pointer = canonical.asPointer,
                    let innerPointer = pointer.pointeeType.asPointer,
                    innerPointer.pointeeType is SwiftOpaqueType,
                    pointer.isMutable {

                // Opaque types are optional
                // Use typealias of opaque type if present
                if let outerTypealias = varDecl.type.outerTypealias(type: innerPointer.pointeeType) {
                    varDecl.type = outerTypealias.copy { $0.with(isOptional: true) }
                } else {
                    varDecl.type = innerPointer.pointeeType.copy { $0.with(isOptional: true) }
                }
                varDecl.isMutable = pointer.isMutable
            }
        }

        // WORKAROUND: [char *] in Options is [String]
        else if let varDecl = ast as? SwiftVarDecl {

            let canonical = varDecl.type.canonical

            if canonical.asArrayElement?.asPointer?.pointeeType.asCChar != nil {
                varDecl.type = SwiftArrayType(elementType: .string, qual: varDecl.type.qual.explicitlyOptional)
            }
        }

        // inout var decl types are optional
        if let varDecl = ast as? SwiftVarDecl,
           varDecl.isMutable,
           varDecl.type.isOptional != true {
            varDecl.type = varDecl.type.optional
        }


        try super.visit(ast: ast)
    }

    override func visit(type: SwiftType) throws -> SwiftType {
        return type
    }
}
