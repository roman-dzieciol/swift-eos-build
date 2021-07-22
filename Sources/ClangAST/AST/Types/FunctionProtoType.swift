import Foundation

final public class FunctionProtoType: ASTType {

    public lazy var cc: String? = {
        validated(cc: string(key: "cc"))
    }()

    public lazy var returnType: ASTType = {
        inner[0] as! ASTType
    }()

    public lazy var paramTypes: [ASTType] = {
        Array(inner.dropFirst().map { $0 as! ASTType })
    }()

    private func validated(cc: String?) -> String? {
        guard cc == nil ||
                cc == "cdecl" else {
                    fatalError("\(cc ?? "")")
                }
        return cc
    }
}
