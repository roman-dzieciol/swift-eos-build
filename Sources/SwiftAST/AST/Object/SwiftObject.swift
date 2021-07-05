
import Foundation

public class SwiftObject: SwiftDecl {

    public var tagName: String
    public var superTypes: [String]
    public var members: [SwiftMember] { inner.compactMap { $0 as? SwiftMember } }

    public init(name: String, tagName: String, superTypes: [String], inner: [SwiftAST] = [], comment: SwiftComment? = nil) {
        self.tagName = tagName
        self.superTypes = superTypes
        super.init(name: name, inner: inner, comment: comment)
    }

    public override func copy() -> SwiftObject {
        let copy = SwiftObject(name: name, tagName: tagName, superTypes: superTypes, inner: inner.map { $0.copy() }, comment: comment?.copy())
        linkCopy(from: self, to: copy)
        return copy
    }

    public func membersAsFunctionParms() -> [SwiftFunctionParm] {
        members.compactMap { member in
            SwiftFunctionParm(member: member)
        }
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(comment)
        swift.write(name: access)
        attributes.forEach { swift.write(name: $0) }
        swift.write(name: tagName)
        swift.write(name: name)
        if !superTypes.isEmpty {
            swift.write(token: ":")
            swift.write(superTypes.map { SwiftBuiltinType(name: $0, qual: .none) }, separated: ",")
        }
        swift.write(nested: "{", "}") {
            swift.write(inner)
        }
    }
}

extension SwiftObject: SwiftDeclContext {

    public func evaluateType() -> SwiftType? {
        SwiftDeclRefType(decl: self)
    }
}
