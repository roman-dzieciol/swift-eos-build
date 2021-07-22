
import Foundation

final public class TypedefDecl: NamedDecl {

    public lazy var type: String = {
        let type = info["type"] as! [String: Any]
        return type["qualType"] as! String
    }()

    public lazy var innerType: ASTType = {
        inner[0] as! ASTType
    }()

}
