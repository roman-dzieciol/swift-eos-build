import Foundation

final public class TextComment: Comment {

    public lazy var text: String = {
        string(key: "text")!
    }()

}
