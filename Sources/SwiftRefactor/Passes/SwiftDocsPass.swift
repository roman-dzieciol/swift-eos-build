
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

        // Remove empty comments
        if let textComment = ast as? SwiftCommentText {
            textComment.name = textComment.name.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if let comment = ast.comment {
            try super.visit(ast: comment)

            comment.inner.removeAll(where: { ($0 as? SwiftCommentParagraph)?.inner.isEmpty == true })
        }

        try super.visit(ast: ast)

        if let paragraphComment = ast as? SwiftCommentParagraph {
            paragraphComment.inner.removeAll(where: { ($0 as? SwiftCommentText)?.name.isEmpty == true })
        }
    }
}

