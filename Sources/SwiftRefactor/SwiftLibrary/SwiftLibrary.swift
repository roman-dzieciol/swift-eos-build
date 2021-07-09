

import Foundation
import SwiftAST


extension SwiftFunction {


    static func cString(from paramType: SwiftType) -> SwiftFunction {
        SwiftFunction(name: "String", isAsync: false, isThrowing: false, returnType: .string, inner: [
            SwiftFunctionParm(label: "cString", name: "cString", type: paramType, isMutable: false, comment: nil)
        ], comment: nil, code: { _ in })
    }
}

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
