import Foundation

final public class TypedefType: ASTType {

    public lazy var decl: BareDeclRef = {
        BareDeclRef(dictionary(key: "decl")!)
    }()

    public lazy var innerType: ASTType = {
        inner[0] as! ASTType
    }()
}
