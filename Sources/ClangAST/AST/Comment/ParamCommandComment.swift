import Foundation

public class ParamCommandComment: Comment {

    public lazy var param: String = {
        string(key: "param")!
    }()

}
