
import Foundation

public class SwiftModule: SwiftDecl {

    public override func write(to swift: SwiftOutputStream) {
        swift.write(comment)
        swift.write(inner)
    }

    public override func copy() -> SwiftModule {
        let copy = SwiftModule(name: name, inner: inner.map { $0.copy() }, comment: comment?.copy())
        linkCopy(from: self, to: copy)
        return copy
    }

}

extension SwiftModule: SwiftDeclContext {

    public func evaluateType() -> SwiftType? {
        fatalError()
    }
}
