
import Foundation

public class SwiftComment: SwiftAST {

    final public var comments: [SwiftComment] { inner.compactMap { $0 as? SwiftComment } }
    final public var paramComments: [SwiftCommentParam] { inner.compactMap { $0 as? SwiftCommentParam } }
    final public var blockComments: [SwiftCommentBlock] { inner.compactMap { $0 as? SwiftCommentBlock } }
    final public var paragraphComments: [SwiftCommentParagraph] { inner.compactMap { $0 as? SwiftCommentParagraph } }
    final public var textComments: [SwiftCommentText] { inner.compactMap { $0 as? SwiftCommentText } }

    final public var isTopLevel: Bool { type(of: self) == SwiftComment.self }

    public init(name: String = "", comments: [SwiftComment]) {
        super.init(name: name, inner: comments)
    }

    public init(_ topComment: String, comments: [SwiftComment] = []) {
        super.init(name: "", inner: [SwiftCommentParagraph(text: [topComment])] + comments)
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

    final public override func add(comment: String) {
        inner.append(SwiftCommentParagraph(text: [comment]))
    }
}

extension SwiftComment {

    final func paramComment(named: String) -> SwiftCommentParam? {
        paramComments.first(where: { $0.name == named })
    }

    public static func paragraph(text: [String]) -> SwiftCommentParagraph {
        SwiftCommentParagraph(text: text)
    }

    public static func paragraph(comments: [SwiftCommentText]) -> SwiftCommentParagraph {
        SwiftCommentParagraph(comments: comments)
    }

}
