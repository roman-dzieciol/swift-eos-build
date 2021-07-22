
import Foundation

final public class RecordType: ASTType {

    public lazy var decl: BareDeclRef = {
        BareDeclRef(dictionary(key: "decl")!)
    }()
}
