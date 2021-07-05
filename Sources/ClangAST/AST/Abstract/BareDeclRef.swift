
import Foundation

public class BareDeclRef: ClangAST {

    public lazy var name: String = {
        string(key: "name")!
    }()

    public lazy var type: String? = {
        let type = info["type"] as? [String: Any]
        return type?["qualType"] as? String
    }()

    public override var debugDescription: String {
        "\(kind)(\(name) \(type ?? "")"
    }
}
