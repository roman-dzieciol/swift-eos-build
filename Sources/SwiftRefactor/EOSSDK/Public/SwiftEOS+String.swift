
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

public func withStringResult(
    _ nested: () throws -> UnsafePointer<CChar>) rethrows -> String
{
    String(cString: try nested())
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


//public func withPointerForInOutString<LengthType: BinaryInteger>(
//    _ string: inout String,
//    capacity: Int? = nil,
//    _ nested: (UnsafeMutablePointer<CChar>?, UnsafeMutablePointer<LengthType>?) throws -> Void) rethrows
//{
//    string = String(cString: try withArrayBuffer(capacity: capacity, nested))
//}

//



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


//public func cCharPointerPointerFromInOutStringArray<LengthType: BinaryInteger, R>(
//    inoutArray: inout [String]?,
//    nested: (UnsafeMutablePointer<CChar>?, UnsafeMutablePointer<LengthType>?) throws -> R) rethrows -> R
//{
//    guard let array = inoutArray else {
//        return try nested(nil, nil)
//    }
//    var utf8Array = Array(string.utf8CString)
//    let result = try withPointerForInOut(array: &utf8Array, capacity: utf8Array.capacity, nested)
//    inoutString = String(cString: utf8Array)
//    return result
//}



public func stringArrayFromCCharPointerPointer<Integer: BinaryInteger>(
    pointer: UnsafePointer<UnsafePointer<CChar>?>?,
    count: Integer
) throws -> [String]? {
    UnsafeBufferPointer(start: pointer,
                        count: try safeNumericCast(exactly: count))
        .compactMap { $0 }
        .map { String(cString: $0) }
}


extension Array where Element == String {

    public func withCharPtrArray<R>(_ body: ([UnsafePointer<CChar>?]) throws -> R) rethrows -> R {
        let charPtrs = map { strdup($0) }
        defer {
            charPtrs.forEach { free($0) }
        }
        return try body(charPtrs)
    }

    public func withMutbleCharPtrArray<R>(_ body: (inout [UnsafeMutablePointer<CChar>?]) throws -> R) rethrows -> R {
        var charPtrs = map { strdup($0) }
        defer {
            charPtrs.forEach { free($0) }
        }
        return try body(&charPtrs)
    }
}
