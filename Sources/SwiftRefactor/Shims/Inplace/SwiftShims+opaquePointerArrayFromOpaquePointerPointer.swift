
import Foundation
import SwiftAST


extension SwiftShims {

    /// `[Pointer<Opaque>]` = `Pointer<Pointer<Opaque>>`
    static func opaquePointerArrayFromOpaquePointerPointer(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        // `Array` = `Pointer array`
        if let lhsArray = lhs.type.canonical.asArray,
           let rhsPointer = rhs.type.canonical.asPointer,
           !(lhs is SwiftFunctionParm && rhs.linked(.arrayLength) != nil) {

            // Ensure pointer array has count specified
            guard let lhsArrayCount = lhs.linked(.arrayLength) as? SwiftVarDecl,
                  let rhsArrayCount = lhsArrayCount.linked(.sdk) as? SwiftVarDecl,
                  let rhsArrayBuffer = lhs.linked(.sdk) as? SwiftVarDecl,
                  rhs === rhsArrayBuffer else {
                      fatalError("unknown typecast: \(lhs.name) = \(rhs.name), \nlhs: \(lhs.type), \nrhs: \(rhs.type)")
                  }

            if let lhsOpaquePtr = lhsArray.elementType.asOpaquePointer,
               let rhsOpaquePtr = rhsPointer.pointeeType.asOpaquePointer,
               lhsOpaquePtr == rhsOpaquePtr {

                let rhsArrayCountExpr: SwiftExpr = .function.safeNumericCast(exactly: nested.outer().map { $0.member(rhsArrayCount.expr) } ?? rhsArrayCount.expr)

                return .function.array(.function.unsafeBufferPointer(start: nested, count: rhsArrayCountExpr))
            }
        }

        return nil
    }
}
