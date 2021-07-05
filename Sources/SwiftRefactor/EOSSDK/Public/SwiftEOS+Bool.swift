
import Foundation


#if canImport(EOSSDK)
import EOSSDK
#endif

public func typecastBoolResult(
    _ nested: () throws -> Int32
) throws -> Bool {
    switch try nested() {
    case EOS_TRUE:
        return true
    case EOS_FALSE:
        return false
    default:
        throw SwiftEOSError.unexpectedBoolResult
    }
}


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

public func eosBoolFromSwiftBool(
    _ swiftBool: Bool
) -> EOS_Bool {
    return swiftBool ? EOS_TRUE : EOS_FALSE
}
