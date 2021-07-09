

import Foundation
import SwiftAST


typealias SwiftShimFunc = (_ lhs: SwiftVarDecl, _ rhs: SwiftVarDecl, _ nested: SwiftExpr) throws -> SwiftExpr?

typealias SwiftShims = Array<SwiftShimFunc>

extension SwiftShims {

    static let nestedOutShims: SwiftShims = [
        SwiftShims.withSdkObjectPointerPointerReturnedAsSwiftObject,
        SwiftShims.withCCharPointerPointersReturnedAsOptionalString,
        SwiftShims.withHandleReturned,
        SwiftShims.withBytePointerPointersReturnedAsByteArray,
    ]

    static let nestedInOutShims: SwiftShims = [
        SwiftShims.withHandlePointerFromInOutHandle,
        SwiftShims.withCCharPointerPointersFromInOutString,
        SwiftShims.withSdkObjectPointerPointerFromInOutSwiftObject,
        SwiftShims.withBytesPointerFromInOutBytesArray,
        SwiftShims.withSdkObjectPointerFromInOutSwiftObject,
        SwiftShims.withSdkObjectPointerFromInOutSdkObject,
        SwiftShims.withIntPointerFromInOutInt,
        SwiftShims.withEosBoolPointerFromInOutSwiftBool,
        SwiftShims.withTrivialMutablePointerFromInOutTrivial,
    ]

    static let nestedShims: SwiftShims = [
        SwiftShims.withTrivialPointersFromOptionalTrivialArray,
        SwiftShims.withSdkObjectPointerFromSwiftObject,
        SwiftShims.withTransformed,
    ]

    static let functionResultShims: SwiftShims = [
        SwiftShims.returningActorFromHandle,
        SwiftShims.returningTransformedResult,
    ]

    static let implicitPointerShims: SwiftShims = [
//        SwiftShims.opaquePointerPointerFromInOutOpaquePointer,
//        SwiftShims.trivialMutablePointerFromInOutTrivial,
    ]

    static let inplaceShims: SwiftShims = [

        SwiftShims.assignable,
        SwiftShims.intFromAnotherInt,

        SwiftShims.voidPointerWorkarounds,
        SwiftShims.handlePointers,

        SwiftShims.cCharPointerFromString,
        SwiftShims.cCharPointerPointerFromStringArray,
        SwiftShims.stringFromCCharPointer,
        SwiftShims.stringArrayFromCCharPointerPointer,

        SwiftShims.byteArrayFromBytePointer,
        SwiftShims.bytePointerFromByteArray,

        SwiftShims.trivialFromTrivialPointer,
        SwiftShims.trivialPointerOrNilPointerFromTrivial,
        SwiftShims.trivialArrayFromTrivialPointer,
        SwiftShims.trivialPointerFromTrivialArray,

//        SwiftShims.opaquePointerArrayFromOpaquePointerPointer,
//        SwiftShims.opaquePointerPointerFromOpaquePointerArray,

        SwiftShims.sdkObjectFromSwiftObject,
        SwiftShims.sdkObjectPointerOrNilPointerFromSwiftObject,
        SwiftShims.sdkObjectPointerFromSwiftObjectArray,
        SwiftShims.swiftObjectFromSdkObject,
        SwiftShims.swiftObjectFromSdkObjectPointer,
        SwiftShims.swiftObjectArrayFromSdkObjectPointer,

        SwiftShims.eosBoolFromSwiftBool,
        SwiftShims.swiftBoolFromEosBool,

        SwiftShims.sdkUnionFromSwiftUnion,
        SwiftShims.swiftUnionFromSdkUnion,

        SwiftShims.tuples,
    ]

    static let immutableShims: SwiftShims = .inplaceShims
}

extension SwiftExpr {

    func shimmed(_ shimFunctions: SwiftShims, lhs: SwiftVarDecl, rhs: SwiftVarDecl) throws -> SwiftExpr? {
        for shim in shimFunctions {
            if let shimmed = try shim(lhs, rhs, self) {
                return shimmed
            }
        }
        return nil
    }
}
