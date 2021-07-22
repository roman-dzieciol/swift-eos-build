
import Foundation

public class VarDecl: NamedDecl {

    final public lazy var type: String = {
        let type = info["type"] as! [String: Any]
        return type["qualType"] as! String
    }()

    public override var debugDescription: String {
        "\(kind)(\(name) \(type)"
    }
}
