
import Foundation
import SwiftAST


extension SwiftExpr.function {

    static func withPointerManager(_ nest: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("withPointerManager", args: [ .closure(["pointerManager"], nest: nest) ])
    }

    static func managedPointer(copyingValueOrNilPointer: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("managedPointer", args: [ copyingValueOrNilPointer.arg("copyingValueOrNilPointer") ])
    }

    static func managedMutablePointer(copyingValueOrNilPointer: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("managedMutablePointer", args: [ copyingValueOrNilPointer.arg("copyingValueOrNilPointer") ])
    }

    static func managedMutablePointer(copyingValueOrUninitialized: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("managedMutablePointer", args: [ copyingValueOrUninitialized.arg("copyingValueOrUninitialized") ])
    }

    static func managedPointerToBuffer(copyingArray : SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("managedPointerToBuffer", args: [ copyingArray.arg("copyingArray") ])
    }

    static func managedMutablePointerToBuffer(copyingArray: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("managedMutablePointerToBuffer", args: [ copyingArray.arg("copyingArray") ])
    }

    static func managedBufferPointer(copyingArray: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("managedBufferPointer", args: [ copyingArray.arg("copyingArray") ])
    }

    static func managedMutableBufferPointer(copyingArray: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("managedMutableBufferPointer", args: [ copyingArray.arg("copyingArray") ])
    }

    static func managedMutablePointerToBufferOfPointers(copyingArray: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("managedMutablePointerToBufferOfPointers", args: [ copyingArray.arg("copyingArray") ])
    }
}
