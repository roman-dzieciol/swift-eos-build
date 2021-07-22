
import Foundation

final public class SwiftCommentBlock: SwiftComment {

    public override func copy() -> SwiftCommentBlock {
        let copy = SwiftCommentBlock(name: name, comments: comments.map { $0.copy() })
        linkCopy(from: self, to: copy)
        return copy
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(token: "- ")
        swift.write(name: adjusted(name: name))
        swift.write(token: ":")
        swift.write(inner)
    }

    private func adjusted(name: String) -> String {
        switch name.lowercased() {
        case "note":
            return "Note"
        case "see":
            return "SeeAlso"
        case "return":
            return "Returns"
        default:
            return name
        }
    }
}

extension SwiftCommentBlock {
    public func fixEosResultComment() {

        if let paragraph = paragraphComments.first, let text = paragraph.textComments.first {
            if let successRange = text.name.range(of: "EOS_Success") {
                if let subsequentRange = text.name[successRange.upperBound...].range(of: "EOS_") {
                    text.name = String(text.name[subsequentRange.lowerBound...])
                } else {
                    paragraph.removeAll([text])
                    if paragraph.comments.isEmpty || paragraph.textComments.allSatisfy({ $0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                        removeAll([paragraph])
                    }
                }
            }
        }
    }
}
