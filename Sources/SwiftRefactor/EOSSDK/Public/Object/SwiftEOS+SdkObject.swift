
import Foundation

public func withSdkObjectOptionalPointerToOptionalPointerFromInOutOptionalSwiftObject<SwiftObject: SwiftEOSObject, R>(
    _ inoutSwiftObject: inout SwiftObject?,
    managedBy pointerManager: SwiftEOS__PointerManager,
    nested: (UnsafeMutablePointer<UnsafeMutablePointer<SwiftObject.SdkObject>?>?) throws -> R
) throws -> R {

    // Allocate space for object that's independent from input
    let pointer = UnsafeMutablePointer<SwiftObject.SdkObject>.allocate(capacity: 1)

    // Store deallocation, after deinitialization
    defer {
        pointerManager.onDeinit {
            pointer.deallocate()
        }
    }

    // When input provided
    if let inoutValue = inoutSwiftObject {

        // Build sdk object
        let sdkObject: SwiftObject.SdkObject = try inoutValue.buildSdkObject(pointerManager: pointerManager)

        // Initialize to input
        pointer.initialize(to: sdkObject)

        // Store deintialization of pointer
        pointerManager.onDeinit {
            pointer.deinitialize(count: 1)
        }
    } else {

        // Zero initialize
        pointer.zeroInitialize()
    }

    // Allocate space for pointer to pointer that's independent from input
    let pointerToPointer = UnsafeMutablePointer<UnsafeMutablePointer<SwiftObject.SdkObject>?>.allocate(capacity: 1)

    // Store deallocation of pointer to pointer, after deinitialization
    defer {
        pointerManager.onDeinit {
            pointerToPointer.deallocate()
        }
    }

    // Initialize pointer to pointer
    pointerToPointer.initialize(to: pointer)

    // Store deintialization of pointer to pointer
    pointerManager.onDeinit {
        pointerToPointer.deinitialize(count: 1)
    }

    // With nested closure receiving pointer to allocated and initialized pointer
    let result = try nested(pointerToPointer)

    // Update to swift object
    inoutSwiftObject = try SwiftObject(sdkObject: pointerToPointer.pointee?.pointee)

    // Return result of nested closure
    return result
}

public func withSdkObjectOptionalPointerToOptionalPointerReturnedAsOptionalSwiftObject<SwiftObject: SwiftEOSObject>(
    managedBy pointerManager: SwiftEOS__PointerManager,
    nest: (UnsafeMutablePointer<UnsafeMutablePointer<SwiftObject.SdkObject>?>?) throws -> Void,
    release: (UnsafeMutablePointer<SwiftObject.SdkObject>) -> Void
) throws -> SwiftObject? {

    // Allocate space for object that's independent from input
    let pointer = UnsafeMutablePointer<SwiftObject.SdkObject>.allocate(capacity: 1)

    // Store deallocation, after deinitialization
    defer {
        pointerManager.onDeinit {
            pointer.deallocate()
        }
    }

    // Zero initialize
    pointer.zeroInitialize()

    // Allocate space for pointer to pointer that's independent from input
    let pointerToPointer = UnsafeMutablePointer<UnsafeMutablePointer<SwiftObject.SdkObject>?>.allocate(capacity: 1)

    // Store deallocation of pointer to pointer, after deinitialization
    defer {
        pointerManager.onDeinit {
            pointerToPointer.deallocate()
        }
    }

    // Initialize pointer to pointer
    pointerToPointer.initialize(to: nil)

    // Store deintialization of pointer to pointer
    pointerManager.onDeinit {
        pointerToPointer.deinitialize(count: 1)
    }

    // With nested closure receiving pointer to nil pointer
    try nest(pointerToPointer)


    // Return nil if sdk set or kept nil
    guard let sdkObjectPointer = pointerToPointer.pointee else {
        return nil
    }

    // Build swift object from sdk object
    let swiftObject = try SwiftObject(sdkObject: sdkObjectPointer.pointee)

    // Release sdk object if needed
    release(sdkObjectPointer)

    // Return swift object
    return swiftObject
}

public func withSdkObjectOptionalPointerFromInOutOptionalSwiftObject<SwiftObject: SwiftEOSObject, R>(
    _ inoutSwiftObject: inout SwiftObject?,
    managedBy pointerManager: SwiftEOS__PointerManager,
    nested: (UnsafeMutablePointer<SwiftObject.SdkObject>?) throws -> R
) throws -> R {

    // Allocate space for object that's independent from input
    let pointer = UnsafeMutablePointer<SwiftObject.SdkObject>.allocate(capacity: 1)

    // Store deallocation, after deinitialization
    defer {
        pointerManager.onDeinit {
            pointer.deallocate()
        }
    }

    // When input provided
    if let inoutValue = inoutSwiftObject {

        // Build sdk object
        let sdkObject: SwiftObject.SdkObject = try inoutValue.buildSdkObject(pointerManager: pointerManager)

        // Initialize to input
        pointer.initialize(to: sdkObject)

        // Store deintialization of pointer
        pointerManager.onDeinit {
            pointer.deinitialize(count: 1)
        }
    } else {

        // Zero initialize
        pointer.zeroInitialize()
    }

    // With nested closure receiving pointer to allocated and initialized pointee
    let result = try nested(pointer)

    // Update to swift object
    inoutSwiftObject = try SwiftObject(sdkObject: pointer.pointee)

    // Return result of nested closure
    return result
}

public func withSdkObjectOptionalPointerFromOptionalSwiftObject<SwiftObject: SwiftEOSObject, R>(
    _ swiftObject: SwiftObject?,
    managedBy pointerManager: SwiftEOS__PointerManager,
    nested: (UnsafePointer<SwiftObject.SdkObject>?) throws -> R
) throws -> R {

    // Allocate space for object that's independent from input
    let pointer = UnsafeMutablePointer<SwiftObject.SdkObject>.allocate(capacity: 1)

    // Store deallocation, after deinitialization
    defer {
        pointerManager.onDeinit {
            pointer.deallocate()
        }
    }

    // When input provided
    if let swiftObject = swiftObject {

        // Build sdk object
        let sdkObject: SwiftObject.SdkObject = try swiftObject.buildSdkObject(pointerManager: pointerManager)

        // Initialize to input
        pointer.initialize(to: sdkObject)

        // Store deintialization of pointer
        pointerManager.onDeinit {
            pointer.deinitialize(count: 1)
        }
    } else {

        // Zero initialize
        pointer.zeroInitialize()
    }

    // With nested closure receiving pointer to allocated and initialized pointee
    return try nested(pointer)
}

public func withSdkObjectOptionalMutablePointerFromSwiftObject<SwiftObject: SwiftEOSObject, R>(
    _ swiftObject: SwiftObject,
    managedBy pointerManager: SwiftEOS__PointerManager,
    nested: (UnsafeMutablePointer<SwiftObject.SdkObject>?) throws -> R
) throws -> R {

    // Allocate space for object that's independent from input
    let pointer = UnsafeMutablePointer<SwiftObject.SdkObject>.allocate(capacity: 1)

    // Store deallocation, after deinitialization
    defer {
        pointerManager.onDeinit {
            pointer.deallocate()
        }
    }

    // Build sdk object
    let sdkObject: SwiftObject.SdkObject = try swiftObject.buildSdkObject(pointerManager: pointerManager)

    // Initialize to input
    pointer.initialize(to: sdkObject)

    // Store deintialization of pointer
    pointerManager.onDeinit {
        pointer.deinitialize(count: 1)
    }

    // With nested closure receiving pointer to allocated and initialized pointee
    return try nested(pointer)
}


public func withSdkObjectOptionalPointerFromInOutOptionalSdkObject<SdkObject, R>(
    _ inoutOptionalSdkObject: inout SdkObject?,
    managedBy pointerManager: SwiftEOS__PointerManager,
    nested: (UnsafeMutablePointer<SdkObject>?) throws -> R
) throws -> R {

    // Allocate space for object that's independent from input
    let pointer = UnsafeMutablePointer<SdkObject>.allocate(capacity: 1)

    // Store deallocation, after deinitialization
    defer {
        pointerManager.onDeinit {
            pointer.deallocate()
        }
    }

    // When input provided
    if let sdkObject = inoutOptionalSdkObject {

        // Initialize to input
        pointer.initialize(to: sdkObject)

        // Store deintialization of pointer
        pointerManager.onDeinit {
            pointer.deinitialize(count: 1)
        }
    } else {

        // Zero initialize
        pointer.zeroInitialize()
    }

    // With nested closure receiving pointer to allocated and initialized pointee
    let result = try nested(pointer)

    // Update to pointee
    inoutOptionalSdkObject = pointer.pointee

    // Return result of nested closure
    return result
}


public func withSdkObjectOptionalPointerFromInOutSdkObject<SdkObject, R>(
    _ inoutSdkObject: inout SdkObject,
    managedBy pointerManager: SwiftEOS__PointerManager,
    nested: (UnsafeMutablePointer<SdkObject>?) throws -> R
) throws -> R {

    // Allocate space for object that's independent from input
    let pointer = UnsafeMutablePointer<SdkObject>.allocate(capacity: 1)

    // Store deallocation, after deinitialization
    defer {
        pointerManager.onDeinit {
            pointer.deallocate()
        }
    }

    // Initialize to input
    pointer.initialize(to: inoutSdkObject)

    // Store deintialization of pointer
    pointerManager.onDeinit {
        pointer.deinitialize(count: 1)
    }

    // With nested closure receiving pointer to allocated and initialized pointee
    let result = try nested(pointer)

    // Update to pointee
    inoutSdkObject = pointer.pointee

    // Return result of nested closure
    return result
}
