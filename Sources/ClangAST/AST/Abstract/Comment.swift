
import Foundation

public class Comment: ClangAST {


    final public lazy var loc: SourceLocation = {
        SourceLocation(dictionary(key: "loc")!)
    }()

}
