import Foundation

final public class PointerType: ASTType {

    public lazy var innerType: ASTType = {
        inner[0] as! ASTType
    }()
}
