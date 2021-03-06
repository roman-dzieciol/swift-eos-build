
import Foundation

final public class SwiftCommentParam: SwiftComment {

    public override func copy() -> SwiftCommentParam {
        let copy = SwiftCommentParam(name: name, comments: comments.map { $0.copy() })
        linkCopy(from: self, to: copy)
        return copy
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(token: "- Parameter")
        swift.write(name: name)
        swift.write(token: ":")
        swift.write(inner)
    }
}

extension SwiftCommentParam {
    
    final public func link(param: SwiftFunctionParm) {
        link(.commented, ref: param)
        param.link(.comment, ref: self)
    }
}
