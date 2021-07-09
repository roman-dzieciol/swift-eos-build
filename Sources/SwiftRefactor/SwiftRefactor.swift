
import Foundation
import SwiftAST
import os.log

public class SwiftRefactor {

    public static let sdkNamespace = "EOSSDK"

    var passes: [SwiftRefactorPass]

    public init() {
        self.passes = []

    }

    public func refactor(module sdkModule: SwiftModule) throws -> SwiftModule {

        try SwiftOpaquePass().refactor(module: sdkModule)

        os_log("Copying module for refactoring...")
        let module = try copy(sdkModule: sdkModule)
        os_log("Copied module for refactoring")

        try SwiftReleaseFuncsPass().refactor(module: sdkModule)

        passes = [
            SwiftDocsPass(),
            SwiftRemoveTagsPass(),
            SwiftEpicPass(),
            SwiftSdkTypesPass(),
            SwiftOptionalsPass(),
            SwiftArraysPass(),
            SwiftTypesPass(),
            SwiftSdkObjectBuilderPass(),
            SwiftFunctionsPass(),
//            //            SwiftUnionsPass(),
            SwiftActorsPass(),
            SwiftFunctionInternalImplementationPass(),
            SwiftInitPass(),
            SwiftApiVersionPass(),
            SwiftCleanupPass(),
            SwiftNamespacePass(),
        ]


        try passes.forEach {
            os_log("Refactoring with %{public}s...", "\(type(of: $0))")
            try $0.refactor(module: module)
            os_log("Refactored with %{public}s", "\(type(of: $0))")
        }

        return module
    }

    private func copy(sdkModule: SwiftModule) throws -> SwiftModule {

        sdkModule.inner = sdkModule.inner.sorted(by: { $0.name < $1.name })

        // Copy AST
        // SwiftDeclRefType.decl references in copied AST still point to original AST
        let module = sdkModule.copy()
        module.name = "SwiftEOS"

        try SwiftCopyLinksVisitor(from: .copiedFrom, to: .sdk).visit(ast: module)
        try SwiftCopyLinksVisitor(from: .copiedTo, to: .swifty).visit(ast: sdkModule)
        try link(module: sdkModule)
        try link(module: module)

        // After all decls are copied, update SwiftResolvedType's so that they point to copied decls
        try SwiftUpdateDeclsInTypesVisitor().visit(ast: module)

        return module
    }

    func link(module: SwiftModule) throws {
        try SwiftForEachVisitor.in(module) { decl in
            decl.link(.module, ref: module)
            return true
        } forEachType: { type in
            type
        }

    }
}

private class SwiftUpdateDeclsInTypesVisitor: SwiftVisitor {

    public override func visit(type: SwiftType) throws -> SwiftType {

        if let resolvedType = type as? SwiftDeclRefType {
            guard let copiedAST = resolvedType.decl.linked(.swifty) as? SwiftDecl else { fatalError() }
            return SwiftDeclRefType(decl: copiedAST, qual: resolvedType.qual)
        }

//        if let genericType = type as? SwiftGenericType {
//            guard let copiedAST = genericType.decl.copiedAST as? SwiftDecl else { fatalError() }
//            let types = try genericType.types.compactMap {
//                try super.visit(type: $0, stack: stack, typeStack: typeStack + [])
//            }
//            return SwiftGenericType(decl: copiedAST, types: types, qual: genericType.qual)
//        }

        return try super.visit(type: type)
    }
}


private class SwiftCopyLinksVisitor: SwiftVisitor {

    let from: SwiftASTLinkType
    let to: SwiftASTLinkType

    init(from: SwiftASTLinkType, to: SwiftASTLinkType) {
        self.from = from
        self.to = to
    }

    override func visit(ast: SwiftAST) throws {

        if let ref = ast.linked(from) {
            ast.link(to, ref: ref)
        }

        try super.visit(ast: ast)
    }
}

