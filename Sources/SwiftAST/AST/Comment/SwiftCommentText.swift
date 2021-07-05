
import Foundation

public class SwiftCommentText: SwiftComment {

    public init(comment: String) {
        let comment = comment.hasPrefix(" ") ? comment : " " + comment
        super.init(name: comment, comments: [])
    }

    public override func copy() -> SwiftCommentText {
        let copy = SwiftCommentText(comment: name)
        linkCopy(from: self, to: copy)
        return copy
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(text: name)
    }
}
