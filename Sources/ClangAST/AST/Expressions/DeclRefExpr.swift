import Foundation


public class DeclRefExpr: Expr {

    public lazy var referencedDecl: BareDeclRef = {
        BareDeclRef(dictionary(key: "referencedDecl")!)
    }()

    public override func tokens() -> [String] {
        [referencedDecl.name]
    }
}
