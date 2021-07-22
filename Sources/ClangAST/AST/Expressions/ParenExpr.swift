import Foundation

final public class ParenExpr: Expr {

    public override func tokens() -> [String] {
        ["("] + super.tokens() + [")"]
    }
}
