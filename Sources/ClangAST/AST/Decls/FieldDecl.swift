import Foundation

final public class FieldDecl: NamedDecl {

    public lazy var type: String = {
        let type = info["type"] as! [String: Any]
        return type["qualType"] as! String
    }()

    public override var debugDescription: String {
        "\(kind)(\(name) \(type))"
    }
}
