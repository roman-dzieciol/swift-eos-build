

import Foundation
import SwiftAST
import os.log

extension SwiftAST {

    public func replace(refs transform: @escaping (SwiftAST) -> SwiftAST) {
        try! SwiftDeclReplacePassVisitor.replace(in: self, transform: transform)
    }

    public func replace(refs decls: [SwiftAST], with linked: SwiftASTLinkType) {
        let declIds = Set(decls.map { ObjectIdentifier($0) })
        replace { decl in
            if declIds.contains(ObjectIdentifier(decl)) {
                return decl.linked(linked)!
            }
            return decl
        }
    }

    func replaceWithSdkRefs(_ filter: @escaping (SwiftAST) -> Bool?) {
        try! SwiftGatheringVisitor.decls(in: self, astFilter: filter) { decls, types in
            assert(!decls.isEmpty)
            self.replace(refs: decls, with: .sdk)
            self.removeAll(decls)
        }
    }
}

class SwiftDeclReplacePassVisitor: SwiftVisitor {

    let transform: (SwiftAST) -> SwiftAST

    init(transform: @escaping (SwiftAST) -> SwiftAST) {
        self.transform = transform
    }

    static func replace(`in` decl: SwiftAST, transform: @escaping (SwiftAST) -> SwiftAST) throws {
        try SwiftDeclReplacePassVisitor(transform: transform).visit(ast: decl)
    }

    override func visit(type: SwiftType) throws -> SwiftType {

        if let swiftDecl = type.asDeclRef?.decl {
            let newDecl = transform(swiftDecl) as! SwiftDecl
            if newDecl !== swiftDecl {
                os_log("replacing ref to %{public}s with %{public}s in %{public}s", swiftDecl.name, newDecl.name, stackPath)
                return SwiftDeclRefType(decl: newDecl, qual: type.qual)
            }
        }

        return try super.visit(type: type)
    }
}
