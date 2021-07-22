import Foundation

final public class ParenType: ASTType {

    public lazy var innerType: ASTType = {
        inner.first as! ASTType
    }()
}
