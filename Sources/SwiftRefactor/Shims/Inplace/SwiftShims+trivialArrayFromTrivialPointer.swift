
import Foundation
import SwiftAST


extension SwiftShims {

    static func trivialArrayFromTrivialPointer(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

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

            // `[Pointer<Opaque>]` = `Pointer<Pointer<Opaque>>`
            if lhsArray.elementType.isTrivial,
               rhsPointer.pointeeType.isTrivial,
               lhsArray.elementType == rhsPointer.pointeeType {

                let rhsArrayCountExpr: SwiftExpr = nested.outer().map { $0.member(rhsArrayCount.expr) } ?? rhsArrayCount.expr

                return .try(.function.trivialArrayFromTrivialPointer(start: nested, count: rhsArrayCountExpr))
//                return .function.array(.function.unsafeBufferPointer(start: nested, count: rhsArrayCountExpr))
            }
        }

        return nil
    }
}
