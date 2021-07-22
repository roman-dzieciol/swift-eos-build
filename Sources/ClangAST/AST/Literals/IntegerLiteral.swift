import Foundation

final public class IntegerLiteral: Literal {

    public lazy var value: String = {
        string(key: "value")!
    }()

    public override func tokens() -> [String] {
        [value]
    }

}
