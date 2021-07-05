
import Foundation

public class Comment: ClangAST {


    public lazy var loc: SourceLocation = {
        SourceLocation(dictionary(key: "loc")!)
    }()

}
