
import Foundation

public class Operator: ClangAST {

    public lazy var opcode: String = {
        string(key: "opcode")!
    }()
}
