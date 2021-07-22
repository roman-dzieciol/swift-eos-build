
import Foundation
import SwiftAST
import NaturalLanguage

final public class SwiftDocsPass: SwiftRefactorPass {

    public override init() {}

    public override func refactor(module: SwiftModule) throws {

        let allTypes = module.inner.filter {
            $0 is SwiftObject || $0 is SwiftFunction || $0 is SwiftTypealias || $0 is SwiftEnum
        }

        let allTypeNames = Set(allTypes.map { $0.name })

        DispatchQueue.concurrentPerform(iterations: module.inner.count) { index in
            try! SwiftDocPassVisitor(allTypes: allTypes, allTypeNames: allTypeNames).visit(ast: module.inner[index])
        }
    }
}

final private class SwiftDocPassVisitor: SwiftVisitor {

    let allTypes: [SwiftAST]
    let allTypeNames: Set<String>

    public init(allTypes: [SwiftAST], allTypeNames: Set<String>) {
        self.allTypes = allTypes
        self.allTypeNames = allTypeNames
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
                var addIdentifier = false

                while(readCursor != text.endIndex) {

                    let char = text[readCursor]
                    if char == "_" {
                        addIdentifier = true
                    } else if !(char.isLetter || char.isNumber) {
                        break
                    }
                    readCursor = text.index(after: readCursor)
                }
                if readCursor != text.endIndex && text[readCursor] == "`" {
                    addIdentifier = false
                }

                if addIdentifier {
                    output += "`"
                }
                output += text[identifierRange.lowerBound..<readCursor]
                if addIdentifier {
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

