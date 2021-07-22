import Foundation

final public class PointerType: ASTType {

    public lazy var innerType: ASTType = {
        inner.first as! ASTType
    }()
}
