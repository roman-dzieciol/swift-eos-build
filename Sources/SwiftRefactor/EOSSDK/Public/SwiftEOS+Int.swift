
import Foundation

public func safeNumericCast<LHS: BinaryInteger, RHS: BinaryInteger>(
    exactly rhs: @autoclosure () throws -> RHS
) throws -> LHS {
    if let lhs = LHS(exactly: try rhs()) {
        return lhs
    } else {
        throw SwiftEOSError.intResultNotTypecastable
    }
}


public func intFromPointerToInt<Pointee: BinaryInteger, R: BinaryInteger>(
    _ transform: (Pointee) -> R = { R(exactly: $0)! },
    _ nested: (UnsafeMutablePointer<Pointee>) throws -> Void
) rethrows -> R {
    var value: Pointee = .zero
    try nested(&value)
    return transform(value)
}
public func typecastIntResult<LHS: BinaryInteger, RHS: BinaryInteger>(
    _ nested: () throws -> RHS
) throws -> LHS {
    return try safeNumericCast(exactly: try nested())
}
//public func withPointerForInOutInteger<Pointee: BinaryInteger, Integer: BinaryInteger, R>(
//    _ integer: inout Integer,
//    _ transform: (Pointee) -> Integer = { R(exactly: $0)! },
//    _ nested: (UnsafeMutablePointer<Pointee>) throws -> R
//) rethrows {
//    var value: Pointee = .zero
//    try nested(&value)
//    integer = transform(value)
//}


public func withIntPointerFromInOutInt<Pointee: BinaryInteger, Integer: BinaryInteger, R>(
    _ inoutInteger: inout Integer,
    nested: (UnsafeMutablePointer<Pointee>?) throws -> R
) rethrows -> R {
//    guard var integer = inoutInteger else {
//        return try nested(nil)
//    }
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
