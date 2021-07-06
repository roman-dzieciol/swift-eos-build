
import Foundation
import SwiftAST

extension SwiftExpr.function {

    static func withActorFromHandle(
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withActorFromHandle", args: [.closure([], nest: nest) ])
    }
}
