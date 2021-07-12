
import Foundation


#if canImport(EOSSDK)
import EOSSDK
#endif


public func withPointer<R>(toStringsCopy strings: [String], _ body: (UnsafePointer<UnsafePointer<CChar>?>) throws -> R) rethrows -> R {
    let charPtrs = strings.map { strdup($0) }
    defer {
        charPtrs.forEach { free($0) }
    }
    return try body(charPtrs.map { UnsafePointer($0) })
}


public func withPointers<R>(toStringsCopy strings: [String], _ body: (UnsafePointer<UnsafePointer<CChar>?>, Int) throws -> R) rethrows -> R {
    let charPtrs = strings.map { strdup($0) }
    defer {
        charPtrs.forEach { free($0) }
    }
    return try body(charPtrs.map { UnsafePointer($0) }, charPtrs.count)
}

public func withStringBuffer<LengthType: BinaryInteger>(
    capacity: Int? = nil,
    _ nested: (UnsafeMutablePointer<CChar>?, UnsafeMutablePointer<LengthType>?) throws -> Void) rethrows -> String
{
    String(cString: try withArrayBuffer(capacity: capacity, nested))
}

public func withPointer(
    outString: inout String,
    capacity: Int,
    _ nested: (UnsafeMutablePointer<CChar>?) throws -> Void) rethrows
{
    let array = try Array<CChar>(unsafeUninitializedCapacity: capacity) { buffer, initializedCount in
        try nested(buffer.baseAddress)
        guard let indexOfZero = buffer.firstIndex(of: .zero) else { fatalError() }
        guard indexOfZero <= capacity else { fatalError() }
        initializedCount = indexOfZero + 1
    }
    outString = String(cString: array)
}


/// With nested `Pointer<CChar>` from `inout String`
public func withCCharPointerFromInOutString<R>(
    inoutString: inout String,
    capacity: Int,
    nested: (UnsafeMutablePointer<CChar>?) throws -> R) rethrows -> R
{

    assert(inoutString.count >= capacity)

    var utf8Array = Array(inoutString.utf8CString)

    let result = try nested(&utf8Array)

    inoutString = String(cString: utf8Array)

    return result
}

/// With nested `Pointer<CChar>` from `inout Optional<String>`
public func withCCharPointerFromInOutOptionalString<R>(
    inoutOptionalString: inout String?,
    capacity: Int,
    nested: (UnsafeMutablePointer<CChar>?) throws -> R) rethrows -> R
{
    if let inoutString = inoutOptionalString {

        assert(inoutString.count >= capacity)

        var utf8Array = Array(inoutString.utf8CString)

        let result = try nested(&utf8Array)

        inoutOptionalString = String(cString: utf8Array)

        return result
    } else {

        var utf8Array = Array<CChar>.init(repeating: 0, count: capacity)

        let result = try nested(&utf8Array)

        inoutOptionalString = String(cString: utf8Array)

        return result
    }
}

/// With nested `Pointer<Pointer<CChar>>, Int` from `inout Optional<String>`
public func withCCharPointerPointersFromInOutOptionalString<LengthType: BinaryInteger, R>(
    inoutOptionalString: inout String?,
    nested: (UnsafeMutablePointer<CChar>?, UnsafeMutablePointer<LengthType>?) throws -> R) rethrows -> R
{
    guard let string = inoutOptionalString else {
        return try nested(nil, nil)
    }
    var utf8Array = Array(string.utf8CString)
    let result = try withPointerForInOut(array: &utf8Array, capacity: utf8Array.capacity, nested)
    inoutOptionalString = String(cString: utf8Array)
    return result
}

/// `[String]` = `Pointer<Pointer<CChar>>`
public func stringArrayFromCCharPointerPointer<Integer: BinaryInteger>(
    pointer: UnsafePointer<UnsafePointer<CChar>?>?,
    count: Integer
) throws -> [String]? {
    UnsafeBufferPointer(start: pointer,
                        count: try safeNumericCast(exactly: count))
        .compactMap { $0 }
        .map { String(cString: $0) }
}

public func withCCharPointerPointersReturnedAsOptionalString<LengthType: BinaryInteger>(
    nested: (UnsafeMutablePointer<CChar>?, UnsafeMutablePointer<LengthType>?) throws -> Void) rethrows -> Optional<String>
{
    var capacity: LengthType = .zero
    do {
        try nested(nil, &capacity)
        return ""
    } catch SwiftEOSError.result(.EOS_LimitExceeded) {
        let utf8Array = try Array<CChar>(unsafeUninitializedCapacity: safeNumericCast(exactly: capacity)) { buffer, initializedCount in
            try nested(buffer.baseAddress,  &capacity)
            initializedCount = try safeNumericCast(exactly: capacity)
        }
        return String(cString: utf8Array)
    }
}

public func stringFromOptionalCStringPointer(_ cString: UnsafePointer<CChar>?) -> String? {
    guard let cString = cString else { return nil }
    return String(cString: cString)
}

public func stringFromOptionalCStringPointer(_ cString: UnsafePointer<UInt8>?) -> String? {
    guard let cString = cString else { return nil }
    return String(cString: cString)
}

