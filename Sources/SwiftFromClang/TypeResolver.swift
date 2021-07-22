
import Foundation
import SwiftAST
import ClangAST


final public class TypeResolver {

    var allTypes: [SwiftDecl]
    let incompleteTypes: [RecordDecl]
    let clangAST: TranslationUnitDecl

    public init(clangAST: TranslationUnitDecl) {
        self.clangAST = clangAST
        self.allTypes = []
        self.incompleteTypes = self.clangAST.inner
            .compactMap { $0 as? RecordDecl }
            .filter { $0.completeDefinition != true }
    }

    public func type(named name: String, qual: SwiftQual, stack: [SwiftAST]) -> SwiftType {

        if let decl = allTypes.first(where: { $0.name == name }) {
            return SwiftDeclRefType(decl: decl, qual: qual)
        }

        if incompleteTypes.contains(where: { $0.name == name }) {
            return SwiftOpaqueType(name: name, qual: qual)
        }

        if name.contains("anonymous union") {
            if let ancestorRecord = stack.last(where: { $0 is SwiftObject }) {
                if let swiftUnion = ancestorRecord.inner.last as? SwiftUnion {
                    swiftUnion.name = "__Unnamed_union_\(stack.last?.name ?? "")"
                    return SwiftDeclRefType(decl: swiftUnion, qual: qual)
                }
            }

        }

        fatalError("Unknown type \(name)")
    }

    public func add(swiftAST: SwiftAST) {
        if let decl = swiftAST as? SwiftDecl {
            allTypes.append(decl)
        }
    }

}
