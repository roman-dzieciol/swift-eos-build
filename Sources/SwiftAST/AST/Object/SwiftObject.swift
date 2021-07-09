
import Foundation
import Algorithms

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

        var sortedInner = inner
        let split = sortedInner.stablePartition {
            $0.name.hasPrefix("__") &&
            ($0 as? SwiftDecl)?.access == "private"
        }

        let publicImpl = sortedInner[..<split]

        swift.write(nested: "{", "}") {
            for ast in publicImpl {
                swift.write(ast)
            }
        }

        let privateImpl = sortedInner[split...]
        if !privateImpl.isEmpty {
            swift.write(text: "\n")
            swift.write(text: "\n")
            swift.write(name: "extension")
            swift.write(name: name)
            swift.write(nested: "{", "}") {
                for ast in privateImpl {
                    swift.write(ast)
                }
            }
        }
    }
}

extension SwiftObject: SwiftDeclContext {

    public func evaluateType() -> SwiftType? {
        SwiftDeclRefType(decl: self)
    }
}
