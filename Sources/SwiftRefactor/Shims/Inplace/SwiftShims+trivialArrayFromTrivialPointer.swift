
import Foundation
import SwiftAST


extension SwiftShims {

    /// `[Trivial]` = `Pointer<Trivial>, Int`
    /// `Optional<[Trivial]>` = `Pointer<Optional<Trivial>>, Int`
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

            if lhsArray.elementType.isTrivial,
               rhsPointer.pointeeType.isTrivial,
               lhsArray.elementType == rhsPointer.pointeeType {

                let rhsArrayCountExpr: SwiftExpr = nested.outer().map { $0.member(rhsArrayCount.expr) } ?? rhsArrayCount.expr

                if rhsPointer.pointeeType.isOptional != false || rhsPointer.pointeeType.isOpaquePointer() {
                    return .try(.function.trivialOptionalArrayFromTrivialOptionalPointer(start: nested, count: rhsArrayCountExpr))
                } else {
                    return .try(.function.trivialArrayFromTrivialPointer(start: nested, count: rhsArrayCountExpr))
                }
            }
        }
        return nil
    }
}

extension SwiftExpr.function {

    /// `Optional<[Trivial]>` = `Pointer<Optional<Trivial>>, Int`
    static func trivialOptionalArrayFromTrivialOptionalPointer(start: SwiftExpr, count: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("trivialOptionalArrayFromTrivialOptionalPointer", args: [ start.arg("start"), count.arg("count") ])
    }

    /// `[Trivial]` = `Pointer<Trivial>, Int`
    static func trivialArrayFromTrivialPointer(start: SwiftExpr, count: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("trivialArrayFromTrivialPointer", args: [ start.arg("start"), count.arg("count") ])
    }
}
