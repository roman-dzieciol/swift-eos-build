
import Foundation

public class Operator: ClangAST {

    final public lazy var opcode: String = {
        string(key: "opcode")!
    }()
}
