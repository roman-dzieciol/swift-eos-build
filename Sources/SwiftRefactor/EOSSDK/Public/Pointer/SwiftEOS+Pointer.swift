
import Foundation

#if canImport(EOSSDK)
import EOSSDK
#endif

extension UnsafeMutablePointer {

    /// Zero initialize pointee
    @inlinable
    public func zeroInitialize() {
        withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Pointee>.stride) { bytePointer in
            bytePointer.assign(repeating: .zero, count: MemoryLayout<Pointee>.stride)
        }
    }
}

public func withPointeeReturned<Pointee>(
    managedBy pointerManager: SwiftEOS__PointerManager,
    nested: (UnsafeMutablePointer<Pointee>) throws -> Void
) rethrows -> Pointee {

    // Allocate space for pointee
    let pointer = UnsafeMutablePointer<Pointee>.allocate(capacity: 1)

    // Store deallocation, after deinitialization
    defer {
        pointerManager.onDeinit {
            pointer.deallocate()
        }
    }

    // Zero initialize
    pointer.zeroInitialize()

    // With nested closure receiving pointer to allocated and zero initialized space
    try nested(pointer)

    // Return pointee
    return pointer.pointee
}

/// Alias for withPointeeReturned
@inlinable
public func withTrivialPointerReturnedAsTrivial<Pointee>(
    managedBy pointerManager: SwiftEOS__PointerManager,
    nested: (UnsafeMutablePointer<Pointee>) throws -> Void
) rethrows -> Pointee {
    return try withPointeeReturned(managedBy: pointerManager, nested: nested)
}

/// Alias for withPointeeReturned
@inlinable
public func withSdkObjectPointerReturnedAsSdkObject<Pointee>(
    managedBy pointerManager: SwiftEOS__PointerManager,
    nested: (UnsafeMutablePointer<Pointee>) throws -> Void
) rethrows -> Pointee {
    return try withPointeeReturned(managedBy: pointerManager, nested: nested)
}

/// Alias for withPointeeReturned
@inlinable
public func withHandleReturned<Pointee>(
    managedBy pointerManager: SwiftEOS__PointerManager,
    nested: (UnsafeMutablePointer<Pointee>) throws -> Void
) rethrows -> Pointee {
    return try withPointeeReturned(managedBy: pointerManager, nested: nested)
}


extension UnsafePointer where Pointee == UInt8 {

    @inlinable
    public var asCChar: UnsafePointer<CChar> {
        @inline(__always) get {
            return UnsafeRawPointer(self).assumingMemoryBound(to: CChar.self)
        }
    }
}

extension UnsafePointer where Pointee == CChar {

    @inlinable
    public var asUInt8: UnsafePointer<UInt8> {
        @inline(__always) get {
            return UnsafeRawPointer(self).assumingMemoryBound(to: UInt8.self)
        }
    }
}

extension UnsafePointer {

    @inlinable
    public func array(_ count: Int) -> [Self] {
        (0..<count).map { advanced(by: $0) }
    }
}

extension UnsafeMutablePointer {

    @inlinable
    public func array(_ count: Int) -> [Self] {
        (0..<count).map { advanced(by: $0) }
    }
}

public func withPointerForInOut<Pointee, R>(
    _ parm: inout R,
    _ factory: (UnsafePointer<Pointee>) throws -> R,
    _ nested: (UnsafeMutablePointer<UnsafeMutablePointer<Pointee>?>) throws -> Void
) rethrows {
    var pointerFromNested: UnsafeMutablePointer<Pointee>? = nil
    try nested(&pointerFromNested)
    parm = try factory(pointerFromNested!)
}
