
import Foundation

final public class SwiftFunctionParm: SwiftVarDecl {

    public var label: String?

    public var defaultValue: String?

    public init(label: String? = nil, name: String, type: SwiftType, isMutable: Bool = false, attributes: Set<String> = [], comment: SwiftComment? = nil) {
        self.label = label
        super.init(name: name, inner: [], attributes: attributes, type: type, isMutable: isMutable, comment: comment)
    }

    public override func handle(visitor: SwiftVisitor) throws {
        try visitor.visitReplacing(type: &type)
        try super.handle(visitor: visitor)
    }

    public func parmType() -> SwiftFunctionParmType {
        SwiftFunctionParmType(label: label, isMutable: isMutable, parmType: type)
    }

    public override func declType() -> SwiftType? {
        type
    }

    public override func copy() -> SwiftFunctionParm {
        let copy = SwiftFunctionParm(label: label, name: name, type: type, isMutable: isMutable, attributes: attributes, comment: comment?.copy())
        linkCopy(from: self, to: copy)
        return copy
    }

    public override func write(to swift: SwiftOutputStream) {
        if let label = label, label != name {
            swift.write(name: label)
        } else if label == nil {
            swift.write(name: "_")
        }
        swift.write(name: name)
        swift.write(token: ":")
        if isMutable {
            swift.write(name: "inout")
        }
        swift.write(name: attributes.joined(separator: " "))
        swift.write(type)
        if let defaultValue = defaultValue {
            swift.write(token: "=")
            swift.write(name: defaultValue)
        }
    }
}

extension SwiftFunctionParm {

    public convenience init(member: SwiftMember) {
        self.init(label: member.name, name: member.name, type: member.type, isMutable: member.isMutable, comment: member.comment)
        link(.sdk, ref: member)
    }

    public var toMember: SwiftMember {
        SwiftMember(name: name, type: type, isMutable: isMutable, getter: nil, comment: nil)
    }

    public var toVar: SwiftVar {
        SwiftVar(name: name, type: type, isMutable: isMutable)
    }
}

extension SwiftOutputStream {

    public func write(parmCall member: SwiftMember, code: @escaping (SwiftOutputStream) -> Void) {
        write(textIfNeeded: "\n")
        write(name: member.name)
        write(token: ": ")
        code(self)
    }

    public func write(parmCall parm: SwiftFunctionParm, code: @escaping (SwiftOutputStream) -> Void) {
        write(textIfNeeded: "\n")
        if let label = parm.label {
            write(name: label)
            write(token: ": ")
        }
        if parm.isMutable {
            write(token: "&")
        }
        code(self)
    }

    public func write(call lhs: SwiftOutputStreamable, label: SwiftOutputStreamable?, with rhs: SwiftOutputStreamable) {
        write(lhs)
        write(nested: "(", ")") {
            if let label = label {
                write(label)
                write(token: ": ")
            }
            write(rhs)
        }
    }
}
