
import Foundation
import os.log

public enum SwiftASTLinkType {
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
    case initializer
    case invocation
    case member
    case module
    case outer
    case releaseFunc
    case removeNotifyFunc
    case sdk
    case swifty
}

public struct SwiftASTLink {
    public let type: SwiftASTLinkType
    public let ref: SwiftAST
}

public class SwiftAST: SwiftOutputStreamable, CustomStringConvertible, CustomDebugStringConvertible {

    public func linkedRefs(_ linkType: SwiftASTLinkType) -> [SwiftAST] {
        SwiftASTLinker.shared.linkedRefs(for: self, linkType)
    }

    public func linked(_ linkType: SwiftASTLinkType) -> SwiftAST? {
        SwiftASTLinker.shared.linked(for: self, linkType)
    }

    public func link(_ linkType: SwiftASTLinkType, ref: SwiftAST) {
        SwiftASTLinker.shared.link(for: self, linkType, ref: ref)
    }
    public func unlink(_ linkType: SwiftASTLinkType, ref: SwiftAST) {
        SwiftASTLinker.shared.unlink(for: self, linkType, ref: ref)
    }

    func linkCopy(from: SwiftAST, to: SwiftAST) {
        from.link(.copiedTo, ref: to)
        to.link(.copiedFrom, ref: from)
    }

    public func unlink(all linkType: SwiftASTLinkType) {
        SwiftASTLinker.shared.unlink(for: self, all: linkType)
    }

    public func removeCode() {
        SwiftASTLinker.shared.removeCode(for: self)
    }

    public var sdk: SwiftAST? {
        linked(.sdk)
    }

    public var swifty: SwiftAST? {
        linked(.swifty)
    }

    public var name: String
    public var attributes: Set<String>
    public var comment: SwiftComment?
    public let uuid: SwiftASTLinker.Key = SwiftASTLinker.shared.uuid()
    public var inner: [SwiftAST]

    public weak var origAST: SwiftAST? {
        if let sourceAST = linked(.sdk) {
            return sourceAST.origAST
        } else {
            return self
        }
    }

    public var canonical: SwiftAST {
        self
    }

    public var canonicalType: SwiftType? {
        nil
    }

    public var innerType: SwiftType? {
        nil
    }

    public var inSwiftEOS: Bool {
        linked(.module)?.name == "SwiftEOS"
    }

    public var asSource: Self? {
        if let sourceAST = linked(.sdk) as? Self, sourceAST !== self {
            return sourceAST
        }
        return nil
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
        (origAST.map { " sdk: \($0.name)" } ?? "")

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

    public func function(matching function: SwiftFunction) -> SwiftFunction? {
        inner
            .compactMap { $0 as? SwiftFunction }
            .first(where: { innerFunction in
                innerFunction.name == function.name &&
                innerFunction.parms.map { $0.name } == function.parms.map { $0.name }
            })
    }

    public func append(_ ast: SwiftAST) {
        inner.append(ast)
        ast.link(.outer, ref: self)
    }

    public func removeAll(_ array: [SwiftAST]) {
        removeAll(Set(array.map { ObjectIdentifier($0) }) )
        let comments = array.compactMap { $0.linked(.comment) }
        if let decl = self as? SwiftDecl {
            decl.comment?.removeAll(comments)
        }
    }

    public func removeAll(_ objects: Set<ObjectIdentifier>) {
        inner.removeAll { decl in
            if objects.contains(ObjectIdentifier(decl)) {
                decl.unlink(.outer, ref: self)
                os_log("removing %{public}s.%{public}s", name, decl.name)
                return true
            }
            return false
        }
    }

    public func removeFromOuter() {
        guard let outer = linked(.outer) else { fatalError() }
        outer.removeAll([self])
    }
}
