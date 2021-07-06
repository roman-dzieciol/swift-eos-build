

import Foundation
import SwiftAST


public class SwiftForEachVisitor: SwiftVisitor {

    public let declAction: (SwiftAST) throws -> Bool
    public let typeAction: (SwiftType) throws -> SwiftType

    public static func `in`(
        _ decl: SwiftAST,
        forEachDecl:  @escaping (SwiftAST) throws -> Bool,
        forEachType:  @escaping (SwiftType) throws -> SwiftType
    ) throws {
        let visitor = SwiftForEachVisitor(declAction: forEachDecl, typeAction: forEachType)
        try visitor.visit(ast: decl)
    }

    public init(
        declAction: @escaping (SwiftAST) throws -> Bool,
        typeAction:  @escaping (SwiftType) throws -> SwiftType
    ) {
        self.declAction = declAction
        self.typeAction = typeAction
    }

    public override func visit(type: SwiftType) throws -> SwiftType {
        let newType = try typeAction(type)
        if newType !== type {
            return newType
        }
        return try super.visit(type: type)
    }

    public override func visit(ast: SwiftAST) throws {
        if try declAction(ast) {
            try super.visit(ast: ast)
        }
    }
}
