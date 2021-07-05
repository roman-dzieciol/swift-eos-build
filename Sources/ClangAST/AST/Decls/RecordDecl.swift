
import Foundation


public class RecordDecl: Decl {

    public lazy var name: String? = {
        string(key: "name")
    }()

    public lazy var completeDefinition: Bool? = {
        bool(key: "completeDefinition")
    }()

    public lazy var tagUsed: String? = {
        string(key: "tagUsed")
    }()
}
