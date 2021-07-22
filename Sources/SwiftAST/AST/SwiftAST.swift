
import Foundation
import os.log

public enum SwiftASTLinkType {
    case apiVersion
    case arrayBuffer
    case arrayLength
    case code
    case copiedFrom
    case copiedTo
    case comment
    case commented
    case expr
    case functionDeinit
    case functionInitFromSdkObject
    case functionBuildSdkObject
    case functionInitMemberwise
    case functionSendCompletionResult
    case functionSendCompletion
    case functionSendNotification
    case implementation
    case initializer
    case invocation
    case member
    case module
    case outer
    case releaseFunc
    case returnedOutParam
    case removeNotifyFunc
    case sdk
    case swifty
    case uniqueName
}

public struct SwiftASTLink {
    public let type: SwiftASTLinkType
    public let ref: SwiftAST
}

public class SwiftAST: SwiftOutputStreamable, CustomStringConvertible, CustomDebugStringConvertible {

    final public var name: String
    final public var attributes: Set<String>
    final public var comment: SwiftComment?
    final public let uuid: SwiftASTLinker.Key = SwiftASTLinker.shared.uuid()
    final public var inner: [SwiftAST]

    public var canonical: SwiftAST {
        self
    }

    public var canonicalType: SwiftType? {
        nil
    }

    public init(name: String, inner: [SwiftAST] = [], attributes: Set<String> = [], comment: SwiftComment? = nil) {
        self.name = name
        self.comment = comment
        self.inner = inner
        self.attributes = attributes
    }

    public func handle(visitor: SwiftVisitor) throws {
        try inner.forEach { innerAst in
            try visitor.visit(ast: innerAst)
        }
    }

    public var description: String {
        "\(type(of: self))(\(debugDescriptionDetails))"
    }

    public var debugDescription: String {
        "\(type(of: self))(\(debugDescriptionDetails))"
    }

    public var debugDescriptionDetails: String {
        "\(name)" +
        (sdk.map { " sdk: \($0.name)" } ?? "")
    }

    public func write(to swift: SwiftOutputStream) {
    }

    public func copy() -> SwiftAST {
        fatalError()
    }

    public func add(comment: String) {
        self.comment = self.comment ?? SwiftComment(comments:[])
        self.comment?.add(comment: comment)
    }
}

extension SwiftAST {

    final public func append(_ ast: SwiftAST) {
        inner.append(ast)
        ast.unlink(all: .outer)
        ast.link(.outer, ref: self)
    }

    final public func append(contentsOf array: [SwiftAST]) {
        for item in array {
            append(item)
        }
    }

    final public func removeAll(_ array: [SwiftAST]) {
        removeAll(Set(array.map { ObjectIdentifier($0) }) )
        let comments = array.compactMap { $0.linked(.comment) }
        if let decl = self as? SwiftDecl {
            decl.comment?.removeAll(comments)
        }
    }

    final public func removeAll(_ objects: Set<ObjectIdentifier>) {
        inner.removeAll { decl in
            if objects.contains(ObjectIdentifier(decl)) {
                decl.unlink(.outer, ref: self)
                os_log("removing %{public}s.%{public}s", log: .disabled, name, decl.name)
                return true
            }
            return false
        }
    }

    final public func removeFromOuter() {
        guard let outer = linked(.outer) else { fatalError() }
        outer.removeAll([self])
    }
}

extension SwiftAST {

    final public var sdk: SwiftAST? {
        linked(.sdk)
    }

    final public var swifty: SwiftAST? {
        linked(.swifty)
    }

    final public var inSwiftEOS: Bool {
        linked(.module)?.name != "EOS"
    }

    final public var inModule: Bool {
        if let outer = linked(.outer) {
            return outer.inModule
        }
        return self is SwiftModule
    }

    final public func linkedRefs(_ linkType: SwiftASTLinkType) -> [SwiftAST] {
        SwiftASTLinker.shared.linkedRefs(for: self, linkType)
    }

    final public func linked(_ linkType: SwiftASTLinkType) -> SwiftAST? {
        SwiftASTLinker.shared.linked(for: self, linkType)
    }

    final public func link(_ linkType: SwiftASTLinkType, ref: SwiftAST) {
        SwiftASTLinker.shared.link(for: self, linkType, ref: ref)
    }
    final public func unlink(_ linkType: SwiftASTLinkType, ref: SwiftAST) {
        SwiftASTLinker.shared.unlink(for: self, linkType, ref: ref)
    }

    final func linkCopy(from: SwiftAST, to: SwiftAST) {
        from.link(.copiedTo, ref: to)
        to.link(.copiedFrom, ref: from)
    }

    final public func unlink(all linkType: SwiftASTLinkType) {
        SwiftASTLinker.shared.unlink(for: self, all: linkType)
    }

    final public func removeCode() {
        SwiftASTLinker.shared.removeCode(for: self)
    }
}
