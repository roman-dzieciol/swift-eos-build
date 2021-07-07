
import Foundation

/// `Optional<[Trivial]>` = `Pointer<Optional<Trivial>>, Int`
public func trivialOptionalArrayFromTrivialOptionalPointer<Element, Integer: BinaryInteger>(
    start: UnsafePointer<Optional<Element>>?,
    count: Integer
) throws -> [Element]? {
    guard let start = start else { return nil }
    return Array(UnsafeBufferPointer(
        start: start,
        count: try safeNumericCast(exactly: count)))
        .compactMap { $0 }
}

/// `[Trivial]` = `Pointer<Trivial>, Int`
public func trivialArrayFromTrivialPointer<Element, Integer: BinaryInteger>(
    start: UnsafePointer<Element>?,
    count: Integer
) throws -> [Element] {
    return Array(UnsafeBufferPointer(
        start: start,
        count: try safeNumericCast(exactly: count)))
        .compactMap { $0 }
}

/// With nested `Pointer<Trivial>` from `inout Trivial`
public func withTrivialMutablePointerFromInOutTrivial<Value, R>(
    _ inoutValue: inout Value,
    managedBy pointerManager: SwiftEOS__PointerManager,
    nested: (UnsafeMutablePointer<Value>) throws -> R
) rethrows -> R {

    let pointer = UnsafeMutablePointer<Value>.allocate(capacity: 1)
    defer {
        pointerManager.onDeinit {
            pointer.deallocate()
        }
    }

    pointer.initialize(to: inoutValue)
    pointerManager.onDeinit {
        pointer.deinitialize(count: 1)
    }

    let result = try nested(pointer)

    inoutValue = pointer.pointee

    return result
}

/// With nested `Pointer<Optional<Trivial>>` from `inout Optional<Trivial>`
public func withOptionalTrivialMutablePointerFromInOutOptionalTrivial<Value, R>(
    _ inoutOptionalValue: inout Optional<Value>,
    managedBy pointerManager: SwiftEOS__PointerManager,
    nested: (UnsafeMutablePointer<Optional<Value>>) throws -> R
) rethrows -> R {

    let pointer = UnsafeMutablePointer<Optional<Value>>.allocate(capacity: 1)
    defer {
        pointerManager.onDeinit {
            pointer.deallocate()
        }
    }

    if let value = inoutOptionalValue {
        pointer.initialize(to: value)
        pointerManager.onDeinit {
            pointer.deinitialize(count: 1)
        }
    }

    let result = try nested(pointer)

    inoutOptionalValue = pointer.pointee

    return result
}

/// With nested `Pointer<Trivial>` from `inout Optional<Trivial>`
public func withTrivialMutablePointerFromInOutOptionalTrivial<Value, R>(
    _ inoutOptionalValue: inout Optional<Value>,
    managedBy pointerManager: SwiftEOS__PointerManager,
    nested: (UnsafeMutablePointer<Value>) throws -> R
) rethrows -> R {

    let pointer = UnsafeMutablePointer<Value>.allocate(capacity: 1)
    defer {
        pointerManager.onDeinit {
            pointer.deallocate()
        }
    }

    if let value = inoutOptionalValue {
        pointer.initialize(to: value)
        pointerManager.onDeinit {
            pointer.deinitialize(count: 1)
        }
    }

    let result = try nested(pointer)

    inoutOptionalValue = pointer.pointee

    return result
}

/// With nested `Pointer<Trivial>, Int` from `Optional<[Trivial]>`
public func withTrivialPointersFromOptionalTrivialArray<Value, Integer: BinaryInteger, R>(
    _ optionalValue: Optional<Array<Value>>,
    managedBy pointerManager: SwiftEOS__PointerManager,
    nested: (UnsafeMutablePointer<Value>?, Integer) throws -> R
) throws -> R {

    if var value = optionalValue {
        return try nested(&value, try safeNumericCast(exactly: value.count))
    } else {
        return try nested(nil, .zero)
    }
}


