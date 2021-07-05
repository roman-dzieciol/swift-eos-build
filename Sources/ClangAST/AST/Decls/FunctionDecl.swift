

import Foundation

public class FunctionDecl: NamedDecl {

    public lazy var type: String = {
        let type = info["type"] as! [String: Any]
        return type["qualType"] as! String
    }()

    public lazy var returnType: String = {
        type.prefix(while: { $0 != "("}).trimmingCharacters(in: .whitespaces)
    }()

    public override var debugDescription: String {
        "\(kind)(\(name) \(type))"
    }
}
