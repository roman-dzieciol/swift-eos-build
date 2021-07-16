
import Foundation

#if canImport(EOSSDK)
import EOSSDK
#endif

/// `Array<Value>` ->` Pointer<Value>, Pointer<Int>`
public func withArrayBuffer<Element, LengthType: BinaryInteger>(
    capacity: Int? = nil,
    _ nested: (UnsafeMutablePointer<Element>?, UnsafeMutablePointer<LengthType>?) throws -> Void) rethrows -> Array<Element>
{
    let bufferCapacity = capacity ?? .zero

    return try Array<Element>(unsafeUninitializedCapacity: bufferCapacity) { buffer, initializedCount in

        var bufferLength: LengthType = LengthType(exactly: bufferCapacity)!

        do {
            try nested(buffer.baseAddress,
                       &bufferLength)
        } catch SwiftEOSError.result(.EOS_LimitExceeded) where capacity == nil {
            try nested(buffer.baseAddress,
                       &bufferLength)
        }

        initializedCount = Int(exactly: bufferLength)!
    }
}


/// `inout Array<Value>` ->` Pointer<Value>, Pointer<Int>`
public func withPointersToInOutArray<LengthType: BinaryInteger, Element, R>(
    inoutArray: inout Array<Element>?,
    nested: (UnsafeMutablePointer<Element>?, UnsafeMutablePointer<LengthType>?) throws -> R) rethrows -> R
{
    guard var array = inoutArray else {
        return try nested(nil, nil)
    }
    let result = try withPointerForInOut(array: &array, capacity: array.capacity, nested)
    inoutArray = array
    return result
}

/// `inout Array<Value>` ->` Pointer<Value>, Pointer<Int>`
public func withPointerForInOut<Element, LengthType: BinaryInteger, R>(
    array: inout Array<Element>,
    capacity: Int? = nil,
    _ nested: (UnsafeMutablePointer<Element>?, UnsafeMutablePointer<LengthType>?) throws -> R) rethrows -> R
{
    let bufferCapacity = capacity ?? .zero

    var returnValue: R!

    array = try Array<Element>(unsafeUninitializedCapacity: bufferCapacity) { buffer, initializedCount in

        var bufferLength: LengthType = LengthType(exactly: bufferCapacity)!

        do {
            returnValue = try nested(buffer.baseAddress,
                                     &bufferLength)
        } catch SwiftEOSError.result(.EOS_LimitExceeded) where capacity == nil {
            returnValue = try nested(buffer.baseAddress,
                                     &bufferLength)
        }

        initializedCount = Int(exactly: bufferLength)!
    }

    return returnValue
}

/// `inout Array<Value>` ->` Pointer<Value>, Pointer<Int>`
public func withPointerForInOut<Element, LengthType: BinaryInteger, R>(
    array: inout Array<Element>,
    count: inout Int,
    capacity: Int? = nil,
    _ nested: (UnsafeMutablePointer<Element>?, UnsafeMutablePointer<LengthType>?) throws -> R) rethrows -> R
{
    let bufferCapacity = capacity ?? .zero

    var returnValue: R!

    array = try Array<Element>(unsafeUninitializedCapacity: bufferCapacity) { buffer, initializedCount in

        var bufferLength: LengthType = LengthType(exactly: bufferCapacity)!

        do {
            returnValue = try nested(buffer.baseAddress,
                                     &bufferLength)
        } catch SwiftEOSError.result(.EOS_LimitExceeded) where capacity == nil {
            returnValue = try nested(buffer.baseAddress,
                                     &bufferLength)
        }

        initializedCount = Int(exactly: bufferLength)!
    }

    count = array.count
    return returnValue
}

public func withElementPointerPointersReturnedAsArray<LengthType: BinaryInteger, Element>(
    nested: (UnsafeMutablePointer<Element>?, UnsafeMutablePointer<LengthType>?) throws -> Void) rethrows -> Array<Element>
{
    var array = Array<Element>()
    try withPointerForInOut(array: &array, capacity: array.capacity, nested)
    return array
}

public func byteArray(from buffer: UnsafeRawBufferPointer) -> [UInt8]? {
    guard buffer.baseAddress != nil else { return nil }
    return Array(buffer)
}
