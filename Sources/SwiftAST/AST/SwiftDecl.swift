
import Foundation

public class SwiftDecl: SwiftAST {

    final public var access: String = "public"
    
    public var expr: SwiftDeclRefExpr {
        self.declRefType(qual: .none).declRefExpr
    }
    
    final public func declRefType(qual: SwiftQual = .none) -> SwiftDeclRefType {
        SwiftDeclRefType(decl: self, qual: qual)
    }

}
