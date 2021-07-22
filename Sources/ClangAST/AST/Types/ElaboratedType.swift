import Foundation

final public class ElaboratedType: ASTType {

    public lazy var ownedTagDecl: Decl? = {
        TagDecl(dictionary(key: "ownedTagDecl")!)
    }()

    public lazy var innerType: ASTType = {
        inner.first as! ASTType
    }()
}
