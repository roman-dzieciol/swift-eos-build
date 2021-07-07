

import Foundation
import SwiftAST

extension SwiftExpr.function {

    /// Returns exact value of Int as another Int type, or throws error
    static func safeNumericCast(exactly: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("safeNumericCast", args: [ exactly.arg("exactly") ])
    }
}

