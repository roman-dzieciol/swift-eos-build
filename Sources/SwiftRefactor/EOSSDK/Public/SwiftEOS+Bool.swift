
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
