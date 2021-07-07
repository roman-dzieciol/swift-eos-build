
import Foundation
import SwiftAST


extension SwiftShims {

    /// `[SwiftObject]` = `Pointer<SdkObject>`
    static func swiftObjectArrayFromSdkObjectPointer(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

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

            if let lhsObject = lhsArray.elementType.asDeclRef?.decl as? SwiftObject,
               let rhsObject = rhsPointer.pointeeType.asDeclRef?.decl as? SwiftObject,
               lhsObject.linked(.sdk)?.canonical === rhsObject.canonical {

                _ = try (lhsObject.canonical as! SwiftObject).functionInitFromSdkObject()

                let rhsArrayCountExpr: SwiftExpr = .function.safeNumericCast(exactly: nested.outer().map { $0.member(rhsArrayCount.expr) } ?? rhsArrayCount.expr)

                return .try(nested.member(.function.mapBufferToObjects(
                    arrayCount: rhsArrayCountExpr,
                    objectInit: .try(lhsObject.expr.member(.function.initFromSdkObject(.string("$0.pointee")))))))
            }
        }

        return nil
    }
}
