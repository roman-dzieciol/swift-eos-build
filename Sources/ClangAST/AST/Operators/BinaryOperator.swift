import Foundation

public class BinaryOperator: Operator {

    public override func tokens() -> [String] {
        assert(inner.count == 2)
        return inner.first!.tokens() + [opcode] + inner.last!.tokens()
    }
}
