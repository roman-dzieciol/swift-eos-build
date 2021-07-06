
import Foundation
import SwiftAST
import ClangAST

public class SwiftFromClang {

    let clangAST: TranslationUnitDecl

    let resolver: TypeResolver

    public init(ast clangAST: ClangAST) {
        self.clangAST = clangAST as! TranslationUnitDecl
        self.resolver = TypeResolver(clangAST: self.clangAST)
    }

    public func swiftModule() throws -> SwiftModule {

        return try swiftAST(from: clangAST, stack: []) as! SwiftModule
    }

    public func swiftAST(from ast: ClangAST, stack: [SwiftAST]) throws -> SwiftAST? {

        switch ast {
        case let ast as TranslationUnitDecl:
            return SwiftModule(name: "EOS", inner: try ast.inner.compactMap { decl in
                let ast = try swiftAST(from: decl, stack: stack)
                ast.map { resolver.add(swiftAST: $0) }
                return ast
            })

        case let ast as EnumDecl:
            return try swiftEnum(from: ast, stack: stack)

        case let ast as TypedefDecl:
            guard ast.name.contains("EOS") else { return nil }
            return try swiftTypealias(from: ast, stack: stack)

        case let ast as FunctionDecl:
            return try swiftFunction(from: ast, stack: stack)

        case let ast as RecordDecl:
            return try swiftRecord(from: ast, stack: stack)

        case let ast as FieldDecl:
            return try swiftField(from: ast, stack: stack)

        case is EmptyDecl:
            return nil

        default:
            //            fatalError("\(ast)")
            return nil
        }
    }

    func swiftEnum(from clangAST: EnumDecl, stack: [SwiftAST]) throws -> SwiftEnum {
        let comment = try swiftComment(from: clangAST, stack: stack)
        let cases = try clangAST.inner
            .compactMap { $0 as? EnumConstantDecl }
            .compactMap { try swiftEnumCase(from: $0, stack: stack) }
        return SwiftEnum(name: clangAST.name, superTypes: ["UInt32"], inner: cases, comment: comment)
    }

    func swiftCommentElement(from clangAST: ClangAST, stack: [SwiftAST]) throws -> SwiftComment? {

        switch clangAST {
        case let clangAST as TextComment:
            return SwiftCommentText(comment: clangAST.text)

        case let clangAST as ParagraphComment:
            let comments = try clangAST.inner.compactMap { try swiftCommentElement(from: $0, stack: stack) }
            return SwiftCommentParagraph(comments: comments)

        case let clangAST as BlockCommandComment:
            let comments = try clangAST.inner.compactMap { try swiftCommentElement(from: $0, stack: stack) }
            return SwiftCommentBlock(name: clangAST.name, comments: comments)

        case let clangAST as ParamCommandComment:
            let comments = try clangAST.inner.compactMap { try swiftCommentElement(from: $0, stack: stack) }
            return SwiftCommentParam(name: clangAST.param, comments: comments)

        default:
            fatalError("\(clangAST)")
        }
    }

    func swiftComment(from clangAST: Decl, stack: [SwiftAST]) throws -> SwiftComment? {
        guard let comments = try clangAST.comment?
                .inner
                .compactMap({ try swiftCommentElement(from: $0, stack: stack) }), !comments.isEmpty else { return nil }
        return SwiftComment(comments: comments)
    }

    func swiftEnumCase(from clangAST: EnumConstantDecl, stack: [SwiftAST]) throws -> SwiftEnumCase? {
        let comment = try swiftComment(from: clangAST, stack: stack)
        return SwiftEnumCase(name: clangAST.name, valueTokens: clangAST.valueTokens(), comment: comment)
    }

    func swiftTypealias(from clangAST: TypedefDecl, stack: [SwiftAST]) throws -> SwiftTypealias? {
        let comment = try swiftComment(from: clangAST, stack: stack)
        let type = swiftType(from: clangAST.innerType, stack: stack)!
        return SwiftTypealias(name: clangAST.name, type: type, comment: comment)
    }

    func swiftFunction(from clangAST: FunctionDecl, stack: [SwiftAST]) throws -> SwiftFunction? {
        let comment = try swiftComment(from: clangAST, stack: stack)
        let parms = try clangAST.inner
            .compactMap { $0 as? ParmVarDecl }
            .compactMap { try swiftFunctionParm(from: $0, stack: stack) }
        return SwiftFunction(name: clangAST.name, returnType: swiftType(from: clangAST.returnType, stack: stack), inner: parms, comment: comment, code: nil)
    }

    func swiftFunctionParm(from clangAST: ParmVarDecl, stack: [SwiftAST]) throws -> SwiftFunctionParm? {
        let type = swiftType(from: clangAST.type, stack: stack)
        return SwiftFunctionParm(name: clangAST.name, type: type, isMutable: false)
    }

    func swiftRecord(from clangAST: RecordDecl, stack: [SwiftAST]) throws -> SwiftObject? {
        guard clangAST.name?.contains("EOS") == true ||
                (clangAST.tagUsed == "union" && stack.last(where: { $0.name.contains("EOS") == true }) != nil)
        else { return nil }
        guard clangAST.completeDefinition == true else { return nil }


        let comment = try swiftComment(from: clangAST, stack: stack)

        let record: SwiftObject? = {

            if let name = clangAST.name, clangAST.tagUsed == "struct" {
                return SwiftStruct(name: name, superTypes: [], comment: comment)
            } else if clangAST.tagUsed == "union" {
                return SwiftUnion(name: clangAST.name ?? "", superTypes: [], comment: comment)
            } else {
                return nil
            }
        }()

        guard let record = record else { return nil }

        for innerAST in clangAST.inner {
            guard !(innerAST is FullComment) else { continue }
            if let innerSwift: SwiftAST = try swiftAST(from: innerAST, stack: stack + [record]) {
                record.inner.append(innerSwift)
            }
        }

        return record
    }

    func swiftField(from clangAST: FieldDecl, stack: [SwiftAST]) throws -> SwiftMember? {
        let comment = try swiftComment(from: clangAST, stack: stack)
        let member = SwiftMember(name: clangAST.name, type: .void, isMutable: false, comment: comment)
        let type = swiftType(from: clangAST.type, stack: stack + [member])
        member.type = type
        return member
    }

    func swiftType(from clangType: ASTType, stack: [SwiftAST]) -> SwiftType? {

        switch clangType {
        case let clangType as RecordType:
            return swiftType(from: clangType.decl.name, stack: stack)

        case let clangType as EnumType:
            return swiftType(from: clangType.decl.name, stack: stack)

        case let clangType as BuiltinType:
            return swiftType(from: clangType.type, stack: stack)

        case let clangType as PointerType:
            let innerType = swiftType(from: clangType.innerType, stack: stack)
            if innerType is SwiftFunctionType {
                return innerType
            } else {
                return SwiftPointerType(pointeeType: innerType ?? .void, isMutable: true, qual: .with(isOptional: nil))
            }

        case let clangType as QualType:
            let innerType = swiftType(from: clangType.innerType, stack: stack)
            return clangType.isConst ? innerType?.immutable : innerType?.mutable

        case let clangType as TypedefType:
            return swiftType(from: clangType.decl.name, stack: stack)
            //            return from(clangType: clangType.innerType)

        case let clangType as ElaboratedType:
            return swiftType(from: clangType.innerType, stack: stack)

        case let clangType as ParenType:
            return swiftType(from: clangType.innerType, stack: stack)

        case let clangType as FunctionProtoType:
            let returnType = swiftType(from: clangType.returnType, stack: stack)!
            let paramTypes = clangType.paramTypes.map { swiftType(from: $0, stack: stack)! }
            let attributes: [String?] = [callingConvention(from: clangType.cc)]
            return SwiftFunctionType(paramTypes: paramTypes,
                                     returnType: returnType,
                                     qual: .with(attributes: Set(attributes.compactMap { $0 })))

        default:
            fatalError("no swift type for \(clangType)")
        }
    }

    func callingConvention(from clangCC: String?) -> String? {
        switch clangCC {
        case "cdecl": return "@convention(c)"
        default: return nil
        }
    }

    func swiftType(from text: String, stack: [SwiftAST]) -> SwiftType {
        switch text {
        case "void": return SwiftBuiltinType(name: "Void", qual: .none)
        case "char": return SwiftBuiltinType(name: "CChar", qual: .none)
        case "float": return SwiftBuiltinType(name: "Float", qual: .none)
        case "double": return SwiftBuiltinType(name: "Double", qual: .none)
        case "size_t": return SwiftBuiltinType(name: "Int", qual: .none)
        case "int8_t": return SwiftBuiltinType(name: "Int8", qual: .none)
        case "uint8_t": return SwiftBuiltinType(name: "UInt8", qual: .none)
        case "int16_t": return SwiftBuiltinType(name: "Int16", qual: .none)
        case "uint16_t": return SwiftBuiltinType(name: "UInt16", qual: .none)
        case "int32_t": return SwiftBuiltinType(name: "Int32", qual: .none)
        case "uint32_t": return SwiftBuiltinType(name: "UInt32", qual: .none)
        case "int64_t": return SwiftBuiltinType(name: "Int64", qual: .none)
        case "uint64_t": return SwiftBuiltinType(name: "UInt64", qual: .none)
        case "char [33]":
            // TODO
            return SwiftBuiltinType(name: "(\(Array<String>(repeating: "CChar", count: 33).joined(separator: ", ")))", qual: .with(isOptional: false))
        default:
            let tokens = text.split(separator: " ")
            if tokens.count == 3, tokens[0] == "const", tokens[2] == "*" {
                let baseType = swiftType(from: String(tokens[1]), stack: stack)
                let pointerType = SwiftPointerType(pointeeType: baseType, isMutable: false, qual: .with(isOptional: nil))
                return pointerType
            }
            else if tokens.count == 3, tokens[0] == "const", tokens[2] == "**" {
                let baseType = swiftType(from: String(tokens[1]), stack: stack)
                let pointerType = SwiftPointerType(pointeeType: baseType, isMutable: false, qual: .optional)
                let arrayType = SwiftPointerType(pointeeType: pointerType, isMutable: true, qual: .with(isOptional: nil))
                return arrayType
            }
            else if tokens.count == 4, tokens[0] == "const", tokens[2] == "*const", tokens[3] == "*" {
                let baseType = swiftType(from: String(tokens[1]), stack: stack)
                let pointerType = SwiftPointerType(pointeeType: baseType, isMutable: false, qual: .optional)
                let arrayType = SwiftPointerType(pointeeType: pointerType, isMutable: false, qual: .with(isOptional: nil))
                return arrayType
            }
            else if tokens.count == 2, tokens[1] == "**" {
                let baseType = swiftType(from: String(tokens[0]), stack: stack)
                let pointerType = SwiftPointerType(pointeeType: baseType, isMutable: true, qual: .optional)
                let arrayType = SwiftPointerType(pointeeType: pointerType, isMutable: true, qual: .with(isOptional: nil))
                return arrayType
            }
            else if tokens.count == 2, tokens[1] == "*" {
                let baseType = swiftType(from: String(tokens[0]), stack: stack)
                let pointerType = SwiftPointerType(pointeeType: baseType, isMutable: true, qual: .with(isOptional: nil))
                return pointerType
            }
            else if tokens.count == 2, tokens[0] == "const" {
                return swiftType(from: String(tokens[1]), stack: stack).immutable
            }
            return resolver.type(named: text, qual: .none, stack: stack)
        }
    }
}

