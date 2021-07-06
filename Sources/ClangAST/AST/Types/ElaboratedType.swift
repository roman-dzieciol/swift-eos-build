import Foundation

public class ElaboratedType: ASTType {

    public lazy var ownedTagDecl: Decl? = {
        TagDecl(dictionary(key: "ownedTagDecl")!)
    }()

    public lazy var innerType: ASTType = {
        inner[0] as! ASTType
    }()
}
