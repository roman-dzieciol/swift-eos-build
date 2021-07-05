
import Foundation

public class SwiftCommentParagraph: SwiftComment {

    public init(comments: [SwiftComment]) {
        super.init(name: "", comments: comments)
    }

    public init(comments: [String]) {
        super.init(name: "", comments: comments.map { SwiftCommentText(comment: $0) })
    }

    public override func copy() -> SwiftCommentParagraph {
        let copy = SwiftCommentParagraph(comments: comments.map { $0.copy() })
        linkCopy(from: self, to: copy)
        return copy
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(inner)
    }
}
