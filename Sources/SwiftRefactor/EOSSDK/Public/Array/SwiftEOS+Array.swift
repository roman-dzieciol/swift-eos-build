
import Foundation

#if canImport(EOSSDK)
import EOSSDK
#endif


/// `inout Array<Value>` ->` Pointer<Value>, Pointer<Int>`
public func withPointersToInOutArray<SdkInteger: BinaryInteger, Element, R>(
    inoutOptionalArray: inout Array<Element>?,
    nested: (UnsafeMutablePointer<Element>?, UnsafeMutablePointer<SdkInteger>?) throws -> R) throws -> R
{
    // Initialize capacity to zero
    var sdkCapacity: SdkInteger = .zero

    do {
        // If array is provided
        if var array = inoutOptionalArray {

            // Initialize capacity to array capacity
            sdkCapacity = try safeNumericCast(exactly: array.count)

            // With nested closure receiving pointer to array
            let result = try nested(&array, &sdkCapacity)

            // Update capacity
            let swiftCapacity: Int = try safeNumericCast(exactly: sdkCapacity)

            // Update result
            inoutOptionalArray = Array(array.prefix(swiftCapacity))

            // Return result of nested closure
            return result
        }

        // If new array should be allocated
        else {

            // With nested closure receiving nil buffer and zero capacity
            let result = try nested(nil, &sdkCapacity)

            // Fallback if nested closure does not update capacity & throw EOS_LimitExceeded
//            inoutOptionalArray = []

            // Return result of nested closure
            return result
        }
    }
    catch SwiftEOSError.result(.EOS_LimitExceeded) {

        // Nested closure result
        var result: R!

        // Update array from pointers
        inoutOptionalArray = try Array<Element>(unsafeUninitializedCapacity: safeNumericCast(exactly: sdkCapacity)) { buffer, initializedCount in

            // If buffer is empty or capacity still zero, rethrow
            guard let baseAddress = buffer.baseAddress, sdkCapacity != .zero else {
                throw SwiftEOSError.result(.EOS_LimitExceeded)
            }

            // With nested closure receiving pointer to buffer
            result = try nested(baseAddress, &sdkCapacity)

            // Update capacity
            initializedCount = try safeNumericCast(exactly: sdkCapacity)
        }

        // Return result of nested closure
        return result
    }
}

public func byteArray(from buffer: UnsafeRawBufferPointer) -> [UInt8]? {
    guard buffer.baseAddress != nil else { return nil }
    return Array(buffer)
}
