
import Foundation


#if canImport(EOSSDK)
import EOSSDK
#endif

extension String {

    public static func eos_repairing(cString: UnsafePointer<CChar>?) -> String? {
        return eos_repairing(cString: cString?.asUInt8)
    }

    public static func eos_repairing(cString: UnsafePointer<UInt8>?) -> String? {

        guard let cString = cString else { return nil }

        if let decoded = String.decodeCString(cString, as: UTF8.self, repairingInvalidCodeUnits: true) {
            if decoded.repairsMade {
                print("repaired UTF8 in: " + decoded.result)
            }
            return decoded.result
        }
        return nil
    }
}


/// With nested `Pointer<CChar>` from `inout String`
public func eos_withCCharPointerForOutString<R>(
    outString: inout String,
    capacity: Int,
    nested: (UnsafeMutablePointer<CChar>?) throws -> R) rethrows -> R
{
    do {
        var outOptionalString: String? = outString
        let result = try eos_withCCharPointerForOutOptionalString(outOptionalString: &outOptionalString, capacity: capacity, nested: nested)
        outString = outOptionalString ?? ""
        return result
    }
    catch {

        // Set out string to empty on error and rethrow
        outString = ""
        throw error
    }
}

/// With nested `Pointer<CChar>` from `inout String?`
public func eos_withCCharPointerForOutOptionalString<R>(
    outOptionalString: inout String?,
    capacity: Int,
    nested: (UnsafeMutablePointer<CChar>?) throws -> R) rethrows -> R
{
    do {
        // Nested closure result
        var result: R!

        // Set out string to string from pointer
        outOptionalString = try String(unsafeUninitializedCapacity: capacity) { (buffer: UnsafeMutableBufferPointer<UInt8>) throws -> Int in

            // If buffer is empty or capacity zero
            guard let baseAddress = buffer.baseAddress, capacity != .zero else {

                // With nested closure receiving nil pointer when no buffer or capacity zero
                result = try nested(nil)

                // Return length of C string without NUL character
                return .zero
            }

            // Rebind as CChar
            // Return length of C string without NUL character
            return try baseAddress.withMemoryRebound(to: CChar.self, capacity: buffer.count) { (charPointer: UnsafeMutablePointer<CChar>) throws -> Int in

                // With nested closure receiving pointer to buffer
                result = try nested(charPointer)

                // Return length of C string without NUL character
                return strnlen(charPointer, buffer.count)
            }
        }

        // Return result of nested closure
        return result
    }
    catch {

        // Set out string to empty on error and rethrow
        outOptionalString = ""
        throw error
    }
}

public func withCCharPointerPointersReturnedAsString<SdkInteger: BinaryInteger>(
    nested: (UnsafeMutablePointer<CChar>?, UnsafeMutablePointer<SdkInteger>?) throws -> Void) rethrows -> String
{
    // Initialize capacity to zero
    var sdkCapacity: SdkInteger = .zero

    // SDK will update capacity and throw EOS_LimitExceeded
    do {
        // With nested closure receiving nil pointer and zero capacity
        try nested(nil, &sdkCapacity)

        // Fallback if nested closure does not update capacity & throw EOS_LimitExceeded
        return ""
    }
    catch SwiftEOSError.result(.EOS_LimitExceeded) {

        // Return string from pointers
        return try String(unsafeUninitializedCapacity: safeNumericCast(exactly: sdkCapacity)) { (buffer: UnsafeMutableBufferPointer<UInt8>) throws -> Int in

            // If buffer is empty or capacity still zero, rethrow
            guard let baseAddress = buffer.baseAddress, sdkCapacity != .zero else {
                throw SwiftEOSError.result(.EOS_LimitExceeded)
            }

            // Rebind as CChar
            // Return length of C string without NUL character
            return try baseAddress.withMemoryRebound(to: CChar.self, capacity: buffer.count) { (charPointer: UnsafeMutablePointer<CChar>) throws -> Int in

                // Update capacity if needed
                sdkCapacity = try safeNumericCast(exactly: buffer.count)

                // With nested closure receiving pointer to buffer
                try nested(charPointer, &sdkCapacity)

                // Return length of C string without NUL character
                return strnlen(charPointer, buffer.count)
            }
        }
    }
}

/// `[String]` = `Pointer<Pointer<CChar>>`
public func stringArrayFromCCharPointerPointer<Integer: BinaryInteger>(
    pointer: UnsafePointer<UnsafePointer<CChar>?>?,
    count: Integer
) throws -> [String]? {
    guard let pointer = pointer else { return nil }
    return UnsafeBufferPointer(start: pointer, count: try safeNumericCast(exactly: count))
        .compactMap { $0 }
        .map { String.eos_repairing(cString: $0) ?? "" }
}

public func stringFromOptionalCStringPointer(_ cString: UnsafePointer<CChar>?) -> String? {
    guard let cString = cString else { return nil }
    return String.eos_repairing(cString: cString)
}

public func stringFromOptionalCStringPointer(_ cString: UnsafePointer<UInt8>?) -> String? {
    guard let cString = cString else { return nil }
    return String.eos_repairing(cString: cString)
}
