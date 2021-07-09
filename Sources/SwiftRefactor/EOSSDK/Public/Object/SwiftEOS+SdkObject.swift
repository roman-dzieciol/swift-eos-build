
import Foundation

public func withSdkObjectPointerPointerFromInOutSwiftObject<SwiftObject: SwiftEOSObject, R>(
    _ inoutSwiftObject: inout SwiftObject?,
    managedBy pointerManager: SwiftEOS__PointerManager,
    nested: (UnsafeMutablePointer<UnsafeMutablePointer<SwiftObject.SdkObject>?>?) throws -> R
) throws -> R {

    guard let swiftObject = inoutSwiftObject else {
        return try nested(nil)
    }

    let sdkObject: SwiftObject.SdkObject = try swiftObject.buildSdkObject(pointerManager: pointerManager)

    let pointer = UnsafeMutablePointer<SwiftObject.SdkObject>.allocate(capacity: 1)
    defer {
        pointerManager.onDeinit {
            pointer.deallocate()
        }
    }

    pointer.initialize(to: sdkObject)
    pointerManager.onDeinit {
        pointer.deinitialize(count: 1)
    }

    let pointerPointer = UnsafeMutablePointer<UnsafeMutablePointer<SwiftObject.SdkObject>?>.allocate(capacity: 1)
    defer {
        pointerManager.onDeinit {
            pointerPointer.deallocate()
        }
    }

    pointerPointer.initialize(to: pointer)
    pointerManager.onDeinit {
        pointerPointer.deinitialize(count: 1)
    }

    let result = try nested(pointerPointer)

    guard let sdkObjectPointer = pointerPointer.pointee else {
        inoutSwiftObject = nil
        return result
    }

    inoutSwiftObject = try SwiftObject(sdkObject: sdkObjectPointer.pointee)
    return result
}

public func withSdkObjectPointerPointerReturnedAsSwiftObject<SwiftObject: SwiftEOSObject>(
    managedBy pointerManager: SwiftEOS__PointerManager,
    nest: (UnsafeMutablePointer<UnsafeMutablePointer<SwiftObject.SdkObject>?>?) throws -> Void,
    release: (UnsafeMutablePointer<SwiftObject.SdkObject>) -> Void
) throws -> SwiftObject? {

    let pointerPointer = UnsafeMutablePointer<UnsafeMutablePointer<SwiftObject.SdkObject>?>.allocate(capacity: 1)
    defer {
        pointerManager.onDeinit {
            pointerPointer.deallocate()
        }
    }

    pointerPointer.initialize(to: nil)

    try nest(pointerPointer)

    guard let sdkObjectPointer = pointerPointer.pointee else {
        return nil
    }

    let result = try SwiftObject(sdkObject: sdkObjectPointer.pointee)

    release(sdkObjectPointer)

    return result
}

public func withSdkObjectPointerFromInOutSwiftObject<SwiftObject: SwiftEOSObject, R>(
    _ inoutSwiftObject: inout SwiftObject?,
    managedBy pointerManager: SwiftEOS__PointerManager,
    nested: (UnsafeMutablePointer<SwiftObject.SdkObject>?) throws -> R
) throws -> R {

    guard let swiftObject = inoutSwiftObject else {
        return try nested(nil)
    }

    let sdkObject: SwiftObject.SdkObject = try swiftObject.buildSdkObject(pointerManager: pointerManager)

    let pointer = UnsafeMutablePointer<SwiftObject.SdkObject>.allocate(capacity: 1)
    defer {
        pointerManager.onDeinit {
            pointer.deallocate()
        }
    }

    pointer.initialize(to: sdkObject)
    pointerManager.onDeinit {
        pointer.deinitialize(count: 1)
    }

    let result = try nested(pointer)

    inoutSwiftObject = try SwiftObject(sdkObject: pointer.pointee)
    return result
}

public func withSdkObjectPointerFromSwiftObject<SwiftObject: SwiftEOSObject, R>(
    _ swiftObject: Optional<SwiftObject>,
    managedBy pointerManager: SwiftEOS__PointerManager,
    nested: (Optional<UnsafePointer<SwiftObject.SdkObject>>) throws -> R
) throws -> R {
    let sdkObjectPointer = try pointerManager.managedPointer(copyingValueOrNilPointer: swiftObject?.buildSdkObject(pointerManager: pointerManager))
//    Cannot convert value of type 'UnsafePointer<SwiftObject.SdkObject>?' to expected argument type 'Optional<UnsafePointer<Optional<SwiftObject.SdkObject>>>'
    return try nested(sdkObjectPointer)
}


public func withSdkObjectPointerFromInOutOptionalSdkObject<SdkObject, R>(
    _ inoutOptionalSdkObject: inout SdkObject?,
    managedBy pointerManager: SwiftEOS__PointerManager,
    nested: (UnsafeMutablePointer<SdkObject>?) throws -> R
) throws -> R {

    guard let sdkObject = inoutOptionalSdkObject else {
        return try nested(nil)
    }

    let pointer = UnsafeMutablePointer<SdkObject>.allocate(capacity: 1)
    defer {
        pointerManager.onDeinit {
            pointer.deallocate()
        }
    }

    pointer.initialize(to: sdkObject)
    pointerManager.onDeinit {
        pointer.deinitialize(count: 1)
    }

    let result = try nested(pointer)

    inoutOptionalSdkObject = pointer.pointee

    return result
}


public func withSdkObjectPointerFromInOutSdkObject<SdkObject, R>(
    _ inoutSdkObject: inout SdkObject,
    managedBy pointerManager: SwiftEOS__PointerManager,
    nested: (UnsafeMutablePointer<SdkObject>?) throws -> R
) throws -> R {

    let pointer = UnsafeMutablePointer<SdkObject>.allocate(capacity: 1)
    defer {
        pointerManager.onDeinit {
            pointer.deallocate()
        }
    }

    pointer.initialize(to: inoutSdkObject)
    pointerManager.onDeinit {
        pointer.deinitialize(count: 1)
    }

    let result = try nested(pointer)

    inoutSdkObject = pointer.pointee

    return result
}



//public func withPointer<SwiftObject, SdkObject, R>(
//    toSdkObjectFrom swiftyObject: SwiftObject,
//    _ nested: (UnsafePointer<SdkObject>) throws -> R
//) rethrows -> R {
//    swiftyObject.with
//    return try withUnsafeMutablePointer(to: &mutableOptions, nested)
//}
//
//
//protocol SwiftObject {
//    associatedtype SdkObject
//}
