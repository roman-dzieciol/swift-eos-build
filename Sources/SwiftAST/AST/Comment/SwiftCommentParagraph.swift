
import Foundation

public class SwiftCommentParagraph: SwiftComment {

    public init(comments: [SwiftCommentText]) {
        super.init(name: "", comments: comments)
    }

    public init(text: [String]) {
        super.init(name: "", comments: text.map { SwiftCommentText(comment: $0) })
    }

    public override func copy() -> SwiftCommentParagraph {
        let copy = SwiftCommentParagraph(comments: textComments.map { $0.copy() })
        linkCopy(from: self, to: copy)
        return copy
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(inner)
    }
}
