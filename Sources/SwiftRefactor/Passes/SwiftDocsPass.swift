
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

            if !textComment.name.isEmpty {
                textComment.name = textWithSourceCodeMarkers(text: textComment.name)
            }
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

    private func textWithSourceCodeMarkers(text: String) -> String {

        var output = ""
        output.reserveCapacity(text.count + 10)
        var readCursor: String.Index = text.startIndex
        let identifierChars = CharacterSet.alphanumerics

        while(readCursor != text.endIndex) {

            if let identifierRange = text[readCursor...].rangeOfCharacter(from: identifierChars) {

                output += text[readCursor..<identifierRange.lowerBound]

                readCursor = identifierRange.lowerBound
                var isIdentifier = false

                while(readCursor != text.endIndex) {

                    let char = text[readCursor]
                    if char == "_" {
                        isIdentifier = true
                    }
                    else if !(char.isLetter || char.isNumber) {
                        break
                    }

                    readCursor = text.index(after: readCursor)
                }

                if isIdentifier {
                    output += "`"
                }
                output += text[identifierRange.lowerBound..<readCursor]
                if isIdentifier {
                    output += "`"
                }
            } else {
                output += text[readCursor...]
                readCursor = text.endIndex
            }
        }

        return output
    }
}

