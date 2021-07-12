

import Foundation
import SwiftAST


extension SwiftExpr.function {

    static func withElementPointerPointersReturnedAsArray(
        bufferPointerName: String,
        countPointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withElementPointerPointersReturnedAsArray", args: [
            .closure([bufferPointerName, countPointerName], nest: nest) ])
    }
}
