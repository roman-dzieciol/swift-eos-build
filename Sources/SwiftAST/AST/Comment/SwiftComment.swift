
import Foundation

public class SwiftComment: SwiftAST {

    public var comments: [SwiftComment] { inner.compactMap { $0 as? SwiftComment } }
    public var paramComments: [SwiftCommentParam] { inner.compactMap { $0 as? SwiftCommentParam } }

    public init(name: String = "", comments: [SwiftComment]) {
        super.init(name: name, inner: comments)
    }

    public init(_ topComment: String, comments: [SwiftComment] = []) {
        super.init(name: "", inner: [SwiftCommentParagraph(comments: [topComment])] + comments)
    }

    public override func copy() -> SwiftComment {
        let copy = SwiftComment(name: name, comments: comments.map { $0.copy() })
        linkCopy(from: self, to: copy)
        return copy
    }

    public var isOneLine: Bool {
        inner.isEmpty || (inner.count == 1 && (inner.first as? SwiftComment)?.isOneLine == true)
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(inner)
    }

    public override func add(comment: String) {
        inner.append(SwiftCommentParagraph(comments: [comment]))
    }
}

extension SwiftComment {

    func paramComment(named: String) -> SwiftCommentParam? {
        paramComments.first(where: { $0.name == named })
    }

}
