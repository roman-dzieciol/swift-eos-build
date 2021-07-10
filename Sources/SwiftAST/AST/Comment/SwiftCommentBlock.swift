
import Foundation

public class SwiftCommentBlock: SwiftComment {

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
