
import Foundation
import SwiftAST


extension SwiftShims {

    static func byteArrayFromBytePointer(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        // `Array` = `Pointer array`
        if let lhsArray = lhs.type.canonical.asArray,
           let rhsPointer = rhs.type.canonical.asPointer {

            // Ensure pointer array has count specified
            guard let lhsArrayCount = lhs.linked(.arrayLength) as? SwiftVarDecl,
                  let rhsArrayCount = lhsArrayCount.linked(.sdk) as? SwiftVarDecl,
                  let rhsArrayBuffer = lhs.linked(.sdk) as? SwiftVarDecl,
                  rhs === rhsArrayBuffer else {
                      fatalError("unknown typecast: \(lhs.name) = \(rhs.name), \nlhs: \(lhs.type), \nrhs: \(rhs.type)")
                  }

            // `[UInt8]` = `Pointer<Void>`
            if lhsArray.elementType.asByte != nil,
               rhsPointer.pointeeType.isVoid {

                let rhsArrayCountExpr: SwiftExpr = .try(.function.safeNumericCast(exactly: nested.outer().map { $0.member(rhsArrayCount.expr) } ?? rhsArrayCount.expr))

                return .function.array(.function.unsafeRawBufferPointer(start: nested, count: rhsArrayCountExpr))
            }
        }

        return nil
    }
}
