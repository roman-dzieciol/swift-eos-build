
import Foundation

/// Returns exact value of Int as another Int type, or throws error
public func safeNumericCast<LHS: BinaryInteger, RHS: BinaryInteger>(
    exactly rhs: @autoclosure () throws -> RHS
) throws -> LHS {
    if let lhs = LHS(exactly: try rhs()) {
        return lhs
    } else {
        throw SwiftEOSError.intResultNotTypecastable
    }
}

/// With `Pointer<Int>` from `inout Int`
public func withIntPointerFromInOutInt<Pointee: BinaryInteger, Integer: BinaryInteger, R>(
    _ inoutInteger: inout Integer,
    nested: (UnsafeMutablePointer<Pointee>?) throws -> R
) rethrows -> R {
    var integer = inoutInteger
    let result = try withTransformedInOut(inoutValue: &integer) { value in
        try safeNumericCast(exactly: value)
    } valueFromTransformed: { transformed in
        try safeNumericCast(exactly: transformed)
    } nested: { transformed in
        try withUnsafeMutablePointer(to: &transformed, nested)
    }
    inoutInteger = integer
    return result
}

/// With `Pointer<Int>` from `inout Optional<Int>`
public func withIntPointerFromInOutOptionalInt<Pointee: BinaryInteger, Integer: BinaryInteger, R>(
    _ inoutOptionalInteger: inout Optional<Integer>,
    nested: (UnsafeMutablePointer<Pointee>?) throws -> R
) rethrows -> R {
    guard var integer = inoutOptionalInteger else {
        return try nested(nil)
    }
    let result = try withTransformedInOut(inoutValue: &integer) { value in
        try safeNumericCast(exactly: value)
    } valueFromTransformed: { transformed in
        try safeNumericCast(exactly: transformed)
    } nested: { transformed in
        try withUnsafeMutablePointer(to: &transformed, nested)
    }
    inoutOptionalInteger = integer
    return result
}

public func withIntegerPointerReturnedAsInteger<Pointee: BinaryInteger, Integer: BinaryInteger>(
    nested: (UnsafeMutablePointer<Pointee>?) throws -> Void
) throws -> Integer {
    var pointee: Pointee = .zero
    try withUnsafeMutablePointer(to: &pointee, nested)
    return try safeNumericCast(exactly: pointee)
}
