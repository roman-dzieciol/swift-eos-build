
import Foundation

public class SwiftVarDecl: SwiftTypeDecl, SwiftVar {

    public var isMutable: Bool

    public var isInOutParm: Bool {
        isMutable && self is SwiftFunctionParm
    }

    public var sdkVarDecl: SwiftVarDecl {
        linked(.sdk) as! SwiftVarDecl
    }

    public init(name: String, inner: [SwiftAST] = [], attributes: Set<String> = [], type: SwiftType, isMutable: Bool, comment: SwiftComment? = nil) {
        self.isMutable = isMutable
        super.init(name: name, inner: inner, attributes: attributes, type: type, comment: comment)
    }

}

extension SwiftType {

    public func tempVar(named: SwiftVarDecl? = nil, attributes: Set<String> = [], isMutable: Bool = false) -> SwiftVarDecl {
        SwiftVarDecl(name: named?.name ?? "TEMP", inner: [], attributes: attributes, type: self, isMutable: isMutable, comment: nil)
    }
}
