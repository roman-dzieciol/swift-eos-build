
import Foundation
import SwiftAST
import os.log

final public class SwiftRefactor {

    public struct Modules {
        public let sdkModule: SwiftModule
        public let swiftModule: SwiftModule
        public let swiftTestsModule: SwiftModule
        public let swiftSdkTestsModule: SwiftModule
    }

    public static let sdkNamespace = "EOSSDK"

    var passes: [SwiftRefactorPass]

    public init() {
        self.passes = []

    }

    public func refactor(module sdkModule: SwiftModule, apiNotesURLs: [URL]) throws -> Modules {

        let swiftTestsModule = SwiftModule(name: "SwiftEOSTests")
        let swiftSdkTestsModule = SwiftModule(name: "SwiftEOSWithTestableSDKTests")

        try SwiftApiNotesPass().refactor(module: sdkModule, apiNotesURLs: apiNotesURLs)

        os_log("Copying module for refactoring...")
        let module = try copy(sdkModule: sdkModule)
        os_log("Copied module for refactoring")

        try SwiftReleaseFuncsPass().refactor(module: sdkModule)

        passes = [
            SwiftDocsPass(),
            SwiftCommentLinkerPass(),
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
            SwiftArrayCleanupPass(),
            SwiftInitPass(),
            SwiftApiVersionPass(),
            SwiftFunctionInternalImplementationPass(),
            SwiftCleanupPass(),
            SwiftNamespacePass(),
            SwiftUnitTestsPass(swiftTestsModule: swiftTestsModule, swiftSdkTestsModule: swiftSdkTestsModule),
            SwiftFinalPass(),
        ]


        try passes.forEach {
            os_log("Refactoring with %{public}s...", "\(type(of: $0))")
            try $0.refactor(module: module)
            os_log("Refactored with %{public}s", "\(type(of: $0))")
        }

        try SwiftToStringPass().refactor(module: sdkModule)

        return Modules(
            sdkModule: sdkModule,
            swiftModule: module,
            swiftTestsModule: swiftTestsModule,
            swiftSdkTestsModule: swiftSdkTestsModule
        )
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

        sdkModule.inner.forEach { ast in
            ast.unlink(all: .outer)
            ast.link(.outer, ref: sdkModule)
        }

        module.inner.forEach { ast in
            ast.unlink(all: .outer)
            ast.link(.outer, ref: module)
        }

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

        if let resolvedType = type as? SwiftDeclRefType, let swiftAST = resolvedType.decl.swifty as? SwiftDecl {
            return SwiftDeclRefType(decl: swiftAST, qual: resolvedType.qual)
        }

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

