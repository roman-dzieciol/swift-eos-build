
import Foundation

public class SwiftDecl: SwiftAST {

    public var access: String = "public"
    
    public var expr: SwiftDeclRefExpr {
        self.declRefType(qual: .none).declRefExpr
    }
    
    public func declRefType(qual: SwiftQual = .none) -> SwiftDeclRefType {
        SwiftDeclRefType(decl: self, qual: qual)
    }


    public func declType() -> SwiftType? {
        nil
    }

}
