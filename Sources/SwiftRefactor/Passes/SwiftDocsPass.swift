
import Foundation
import SwiftAST
import NaturalLanguage

public class SwiftDocsPass: SwiftRefactorPass {

    public override init() {}

    public override func refactor(module: SwiftModule) throws {

        let allTypes = module.inner.filter {
            $0 is SwiftObject || $0 is SwiftFunction || $0 is SwiftTypealias || $0 is SwiftEnum
        }

        try SwiftDocPassVisitor(allTypes: allTypes).visit(ast: module)
    }
}

class SwiftDocPassVisitor: SwiftVisitor {

    let allTypes: [SwiftAST]
    let allTypeNames: Set<String>

    public init(allTypes: [SwiftAST]) {
        self.allTypes = allTypes
        self.allTypeNames = Set(allTypes.map { $0.name })
    }

    public override func visit(ast: SwiftAST) throws {

        // Fixup comments
        if let paraComment = ast.inner.first as? SwiftCommentParagraph,
           let textComment = paraComment.inner.last as? SwiftCommentText,
           textComment.name == " " {
            paraComment.inner.removeLast()
        }

        if let comment = ast.comment {
            try super.visit(ast: comment)
        }

        try super.visit(ast: ast)
    }
}

