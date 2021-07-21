

import Foundation
import SwiftAST


extension SwiftExpr.function {

    static func withBytePointersReturnedAsByteArray(
        bufferPointerName: String,
        countPointerName: String,
        nest: SwiftExpr
    ) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withBytePointersReturnedAsByteArray", args: [
            .closure([bufferPointerName, countPointerName], nest: nest) ])
    }

    static func pointerToTestObject(
        _ object: SwiftExpr,
        type: SwiftType
    ) -> SwiftExpr {
            .string("GTest.current").member(
                SwiftFunction(name: "pointer", returnType: type).call([.arg("object", object)])
            )
    }

    static func pointerToTestString(
        _ string: SwiftExpr,
        type: SwiftType
    ) -> SwiftExpr {
            .string("GTest.current").member(
                SwiftFunction(name: "pointer", returnType: type).call([.arg("string", string)])
            )
    }
}
