

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

    static func pointerToTestObject(
        _ object: SwiftExpr,
        type: SwiftType
    ) -> SwiftExpr {
            .string("TestGlobals.current").member(
                SwiftFunction(name: "pointer", returnType: type).call([.arg("object", object)])
            )
    }

    static func pointerToTestString(
        _ string: SwiftExpr,
        type: SwiftType
    ) -> SwiftExpr {
            .string("TestGlobals.current").member(
                SwiftFunction(name: "pointer", returnType: type).call([.arg("string", string)])
            )
    }
}
