
import Foundation


#if canImport(EOSSDK)
import EOSSDK
#endif

/// With `Bool` result from`() -> EOS_Bool`
public func withBoolResult(
    _ nested: () throws -> Int32
) throws -> Bool {
    try swiftBoolFromEosBool(nested())
}

/// `(EOS_Bool) -> Bool`
public func swiftBoolFromEosBool(
    _ eosBool: EOS_Bool
) throws -> Bool {
    switch eosBool {
    case EOS_TRUE:
        return true
    case EOS_FALSE:
        return false
    default:
        throw SwiftEOSError.unexpectedBoolResult
    }
}

/// `(Bool) -> EOS_Bool`
public func eosBoolFromSwiftBool(
    _ swiftBool: Bool
) -> EOS_Bool {
    return swiftBool ? EOS_TRUE : EOS_FALSE
}

/// With `Pointer<EOS_Bool>` from `inout Bool`
public func withEosBoolPointerFromInOutSwiftBool<R>(
    _ inoutBool: inout Bool,
    nested: (UnsafeMutablePointer<EOS_Bool>?) throws -> R
) rethrows -> R {
    var bValue = inoutBool
    let result = try withTransformedInOut(inoutValue: &bValue) { value in
        eosBoolFromSwiftBool(value)
    } valueFromTransformed: { transformed in
        try swiftBoolFromEosBool(transformed)
    } nested: { transformed in
        try withUnsafeMutablePointer(to: &transformed, nested)
    }
    inoutBool = bValue
    return result
}

/// With `Pointer<EOS_Bool>` from `inout Optional<Bool>`
public func withEosBoolPointerFromInOutOptionalSwiftBool<R>(
    _ inoutOptionalBool: inout Optional<Bool>,
    nested: (UnsafeMutablePointer<EOS_Bool>?) throws -> R
) rethrows -> R {
    guard var bValue = inoutOptionalBool else {
        return try nested(nil)
    }
    let result = try withEosBoolPointerFromInOutSwiftBool(&bValue, nested: nested)
    inoutOptionalBool = bValue
    return result
}

