import Foundation

public class EnumType: ASTType {

    public lazy var decl: BareDeclRef = {
        BareDeclRef(dictionary(key: "decl")!)
    }()
}
