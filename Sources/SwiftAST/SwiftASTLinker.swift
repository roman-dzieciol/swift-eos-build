
import Foundation

final public class SwiftASTLinker {

    public static let shared = SwiftASTLinker()

    public typealias Key = UInt64

    private var _uuid: Key = 0

    private var links: [Key: [SwiftASTLink]] = [:]

    private init(){}

    public func links(for ast: SwiftAST) -> [SwiftASTLink] {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        return links[ast.uuid, default: []]
    }

    public func link(for ast: SwiftAST, _ linkType: SwiftASTLinkType, ref: SwiftAST) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        links[ast.uuid, default: []].append(.init(type: linkType, ref: ref))
    }

    public func unlink(for ast: SwiftAST, _ linkType: SwiftASTLinkType, ref: SwiftAST) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        links[ast.uuid]?.removeAll(where: { $0.type == linkType && $0.ref === ref })
    }

    public func linkedRefs(for ast: SwiftAST, _ linkType: SwiftASTLinkType) -> [SwiftAST] {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        return links(for: ast)
            .filter { $0.type == linkType }
            .compactMap { $0.ref }
    }

    public func linked(for ast: SwiftAST, _ linkType: SwiftASTLinkType) -> SwiftAST? {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        let linkedRefs = linkedRefs(for: ast, linkType)
        //        if linkedRefs.count > 1 {
        //            fatalError()
        //        }
        return linkedRefs.first
    }

    public func unlink(for ast: SwiftAST, all linkType: SwiftASTLinkType) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        links[ast.uuid]?.removeAll(where: { $0.type == linkType })
    }

    public func removeCode(for ast: SwiftAST) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        linkedRefs(for: ast, .expr).forEach { ref in
            if let exprRef = ref as? SwiftExprRef,
               let exprBuilder = exprRef.expr as? SwiftExprBuilder {
                exprBuilder.expr = nil
            }
        }
        unlink(for: ast, all: .code)
        unlink(for: ast, all: .expr)
    }

    public func uuid() -> Key {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        _uuid += 1
        let result = _uuid
        return result
    }

}
