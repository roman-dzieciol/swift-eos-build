import Foundation

final public class QualType: ASTType {

    public var isConst: Bool {
        qualifiers == "const"
    }

    public lazy var qualifiers: String? = {
        validated(qualifiers: string(key: "qualifiers"))
    }()

    public lazy var innerType: ASTType = {
        inner[0] as! ASTType
    }()

    private func validated(qualifiers: String?) -> String? {
        guard qualifiers == nil ||
                qualifiers == "const" else {
            fatalError("\(qualifiers ?? "")")
        }
        return qualifiers
    }
    
}
