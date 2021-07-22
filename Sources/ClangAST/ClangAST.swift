
import Foundation
import os.log

public class ClangAST: ClangJSON, CustomDebugStringConvertible {

    final public lazy var kind: String = {
        string(key: "kind")!
    }()

    final public lazy var inner: [ClangAST] = {
        let infoArray = info["inner"] as? [[String: Any]] ?? []
        return infoArray.map { ClangAST.from(info: $0) }
    }()

    public var debugDescription: String {
        "\(kind)"
    }

    public static func from(info: [String: Any]) -> ClangAST {
        switch info["kind"] as? String {
        case "BinaryOperator": return BinaryOperator(info)
        case "BlockCommandComment": return BlockCommandComment(info)
        case "BuiltinType": return BuiltinType(info)
        case "ConstantArrayType": return ConstantArrayType(info)
        case "ConstantExpr": return ConstantExpr(info)
        case "DeclRefExpr": return DeclRefExpr(info)
        case "ElaboratedType": return ElaboratedType(info)
        case "EmptyDecl": return EmptyDecl(info)
        case "EnumConstantDecl": return EnumConstantDecl(info)
        case "EnumDecl": return EnumDecl(info)
        case "EnumType": return EnumType(info)
        case "FieldDecl": return FieldDecl(info)
        case "FullComment": return FullComment(info)
        case "FunctionDecl": return FunctionDecl(info)
        case "FunctionProtoType": return FunctionProtoType(info)
        case "IntegerLiteral": return IntegerLiteral(info)
        case "MaxFieldAlignmentAttr": return MaxFieldAlignmentAttr(info)
        case "ParagraphComment": return ParagraphComment(info)
        case "ParamCommandComment": return ParamCommandComment(info)
        case "ParenExpr": return ParenExpr(info)
        case "ParenType": return ParenType(info)
        case "ParmVarDecl": return ParmVarDecl(info)
        case "PointerType": return PointerType(info)
        case "QualType": return QualType(info)
        case "RecordDecl": return RecordDecl(info)
        case "RecordType": return RecordType(info)
        case "TextComment": return TextComment(info)
        case "TranslationUnitDecl": return TranslationUnitDecl(info)
        case "TypedefDecl": return TypedefDecl(info)
        case "TypedefType": return TypedefType(info)
        case "UnaryOperator": return UnaryOperator(info)
        case "VisibilityAttr": return VisibilityAttr(info)

        default: fatalError("\(info)")
        }
    }

    public static func from(url: URL) throws -> ClangAST {

        os_log("Loading %{public}s", url.relativePath)
        let data = try Data(contentsOf: url)

        os_log("Parsing %{public}s", url.relativePath)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]

        os_log("Preloading ClangAST...")
        let clangAST = from(info: json)
        clangAST.preloadAST()
        os_log("Preloaded ClangAST")

        return clangAST
    }

    final public func preloadAST() {
        inner.forEach { $0.preloadAST() }
    }

    public func tokens() -> [String] {
        Array(inner
                .map { $0.tokens() }
                .joined())
    }
}

