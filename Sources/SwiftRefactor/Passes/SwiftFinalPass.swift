
import Foundation
import SwiftAST

final public class SwiftFinalPass: SwiftRefactorPass {

    public override init() {}

    public override func refactor(module: SwiftModule) throws {
        try SwiftGatheringVisitor.decls(in: module, astFilter: { ($0 as? SwiftObject)?.tagName == "class" }, typeFilter: nil, results: { decls, types in
            for decl in decls {
                decl.attributes.insert("final")
            }
        })
    }
}
