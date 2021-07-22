
import Foundation

final public class SwiftTypealias: SwiftTypeDecl {
    
    public override func copy() -> SwiftTypealias {
        let copy = SwiftTypealias(name: name, type: type, comment: comment?.copy())
        linkCopy(from: self, to: copy)
        return copy
    }
    
    public override func write(to swift: SwiftOutputStream) {
        swift.write(comment)
        swift.write(name: access)
        swift.write(name: "typealias")
        swift.write(name: name)
        swift.write(token: "=")
        swift.write(type)
    }
}
