import Foundation

public class ParenType: ASTType {


    public lazy var innerType: ASTType = {
        inner[0] as! ASTType
    }()
}
