import Foundation


public class UnaryOperator: Operator {

    public lazy var isPostfix: Bool? = {
        info["isPostfix"] as? Bool
    }()

    public override func tokens() -> [String] {
        if isPostfix == true {
            return super.tokens() + [opcode]
        } else {
            return [opcode] + super.tokens()
        }
    }
}
