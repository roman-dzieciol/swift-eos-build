
import Foundation
import os.log

public enum SwiftASTLinkType {
    case arrayBuffer
    case arrayLength
    case code
    case copiedFrom
    case copiedTo
    case expr
    case functionDeinit
    case functionInitFromSdkObject
    case functionBuildSdkObject
    case functionInitMemberwise
    case functionSendCompletionResult
    case functionSendCompletion
    case functionSendNotification
    case invocation
    case member
    case module
    case releaseFunc
    case sdk
    case swifty
}

public struct SwiftASTLink {
    public let type: SwiftASTLinkType
    public let ref: SwiftAST
}

public class SwiftAST: SwiftOutputStreamable, CustomStringConvertible, CustomDebugStringConvertible {

    public var links: [SwiftASTLink] = []

    public func linkedRefs(_ linkType: SwiftASTLinkType) -> [SwiftAST] {
        links
            .filter { $0.type == linkType }
            .compactMap { $0.ref }
    }

    public func linked(_ linkType: SwiftASTLinkType) -> SwiftAST? {
        let linkedRefs = linkedRefs(linkType)
//        if linkedRefs.count > 1 {
//            fatalError()
//        }
        return linkedRefs.first
    }

    public func link(_ linkType: SwiftASTLinkType, ref: SwiftAST) {
        links.append(.init(type: linkType, ref: ref))
    }

    func linkCopy(from: SwiftAST, to: SwiftAST) {
        from.link(.copiedTo, ref: to)
        to.link(.copiedFrom, ref: from)
    }

    public func unlink(all linkType: SwiftASTLinkType) {
        links.removeAll(where: { $0.type == linkType })
    }

    public func removeCode() {
        linkedRefs(.code).forEach { ref in
            if let codeAst = ref as? SwiftCodeAST {
                codeAst.output.output = nil
            }
        }
        linkedRefs(.expr).forEach { ref in
            if let exprRef = ref as? SwiftExprRef,
               let exprBuilder = exprRef.expr as? SwiftExprBuilder {
                exprBuilder.expr = nil
            }
        }
        unlink(all: .code)
        unlink(all: .expr)
    }

    public var sdk: SwiftAST? {
        linked(.sdk)
    }

    public var swifty: SwiftAST? {
        linked(.swifty)
    }

    public var name: String
    public var comment: SwiftComment?
    public var inner: [SwiftAST]
    public var access: String = "public"
    public var attributes: Set<String>

    public weak var otherAST: SwiftAST?

    public weak var copiedAST: SwiftAST? {
        linked(.swifty)
    }

    public weak var sourceAST: SwiftAST? {
        linked(.sdk)
    }

    public weak var origAST: SwiftAST? {
        if let sourceAST = sourceAST {
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
        if let sourceAST = sourceAST as? Self, sourceAST !== self {
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
        SwiftWriterString.description(for: self)
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
}
