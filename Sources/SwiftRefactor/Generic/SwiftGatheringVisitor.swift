
import Foundation
import SwiftAST

public class SwiftGatheringVisitor: SwiftVisitor {

    public let astFilter: (SwiftAST) -> Bool
    public let typeFilter: ((SwiftType) -> Bool)?

    public var astList: [SwiftAST] = []
    public var typeList: [SwiftType] = []

    public static func decls(
        in decl: SwiftAST,
        astFilter: @escaping (SwiftAST) -> Bool,
        typeFilter: ((SwiftType) -> Bool)? = nil,
        results: @escaping (_ decls: [SwiftAST], _ types: Set<SwiftType>) -> Void
    ) throws {
        let visitor = SwiftGatheringVisitor(astFilter: astFilter, typeFilter: typeFilter)
        try visitor.visit(ast: decl)
        results(visitor.astList, Set(visitor.typeList))
    }

    public init(astFilter: @escaping (SwiftAST) -> Bool, typeFilter: ((SwiftType) -> Bool)?) {
        self.astFilter = astFilter
        self.typeFilter = typeFilter
    }

    public override func visit(type: SwiftType) throws -> SwiftType {
        guard let typeFilter = typeFilter else { return type }

        if typeFilter(type) {
            typeList.append(type)
        }

        return try super.visit(type: type)
    }

    public override func visit(ast: SwiftAST) throws {
        if astFilter(ast) {
            astList.append(ast)
        }

        return try super.visit(ast: ast)
    }
}
