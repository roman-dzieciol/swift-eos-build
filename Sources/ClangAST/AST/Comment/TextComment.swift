import Foundation

public class TextComment: Comment {

    public lazy var text: String = {
        string(key: "text")!
    }()

}
