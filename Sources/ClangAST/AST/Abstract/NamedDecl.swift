
import Foundation

public class NamedDecl: Decl {

    final public lazy var name: String = {
        string(key: "name")!
    }()

    public override var debugDescription: String {
        "\(kind)(\(name))"
    }
}

public typealias TagDecl = NamedDecl
