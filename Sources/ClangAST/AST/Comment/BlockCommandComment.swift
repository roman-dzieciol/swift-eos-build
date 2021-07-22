import Foundation

final public class BlockCommandComment: Comment {

    public lazy var name: String = {
        string(key: "name")!
    }()

}
