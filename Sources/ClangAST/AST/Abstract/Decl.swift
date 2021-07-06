
import Foundation

public class Decl: ClangAST {

    public lazy var loc: SourceLocation = {
        SourceLocation(dictionary(key: "loc")!)
    }()

    public lazy var comment: FullComment? = {
        let comments = inner.compactMap { $0 as? FullComment }
        assert(comments.count <= 1)
        return comments.first
    }()

}
