
import Foundation
import SwiftAST

public class SwiftRemoveTagsPass: SwiftRefactorPass {

    static let tagPrefix = "_tag"

    public override func refactor(module: SwiftModule) throws {

        // Use tag structs without typealiases
        try SwiftUseStructsDirectlyVisitor().visit(ast: module)

        // Remove typealiases
        module.inner.removeAll(where: {
            ((($0 as? SwiftTypealias)?
                .type.withoutTypealias as? SwiftDeclRefType)?
                .decl as? SwiftObject)?
                .name.hasPrefix(Self.tagPrefix) == true
        })

        // Rename tag structs
        module.inner
            .compactMap { $0 as? SwiftObject }
            .filter { $0.name.hasPrefix(Self.tagPrefix) }
            .forEach { $0.name.removePrefix(Self.tagPrefix) }

    }
}

private class SwiftUseStructsDirectlyVisitor: SwiftVisitor {

    override func visit(type: SwiftType) throws -> SwiftType {

        if let declType = type.withoutTypealias as? SwiftDeclRefType,
           let swiftObject = declType.decl as? SwiftObject,
           declType !== type,
           swiftObject.name.hasPrefix(SwiftRemoveTagsPass.tagPrefix) {
            return declType
        }

        return try super.visit(type: type)
    }

    override func visit(ast: SwiftAST) throws {
        return try super.visit(ast: ast)
    }
}
