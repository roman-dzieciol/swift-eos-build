
import Foundation

#if canImport(EOSSDK)
import EOSSDK
#endif

public func withCompletionResult<SwiftCallbackInfo, R>(
    completion: @escaping (Result<SwiftCallbackInfo, Error>) -> Void,
    managedBy pointerManager: SwiftEOS__PointerManager,
    nested: (UnsafeMutableRawPointer) throws -> R
) rethrows -> R {
    let callback = __SwiftEOS__CompletionCallbackWithResult(
        managedBy: pointerManager,
        completion: completion
    )
    return try withExtendedLifetime(callback) { callback in
        let clientData = callback.retainedPointer()
        return try nested(clientData)
    }
}

class __SwiftEOS__CompletionCallbackWithResult<SwiftCallbackInfo> {

    let pointerManager: SwiftEOS__PointerManager

    let completion: (Result<SwiftCallbackInfo, Error>) -> Void

    init(managedBy pointerManager: SwiftEOS__PointerManager, completion: @escaping (Result<SwiftCallbackInfo, Error>) -> Void) {
        self.pointerManager = pointerManager
        self.completion = completion
    }

    func retainedPointer() -> UnsafeMutableRawPointer {
        UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
    }

    static func from(pointer: UnsafeMutableRawPointer?) -> Self? {
        guard let pointer = pointer else { return nil }
        return Unmanaged<Self>.fromOpaque(pointer).takeRetainedValue()
    }
}

public func withCompletion<SwiftCallbackInfo, R>(
    completion: @escaping (SwiftCallbackInfo) -> Void,
    managedBy pointerManager: SwiftEOS__PointerManager,
    nested: (UnsafeMutableRawPointer) throws -> R
) rethrows -> R {
    let callback = __SwiftEOS__CompletionCallback(
        managedBy: pointerManager,
        completion: completion
    )
    return try withExtendedLifetime(callback) { callback in
        let clientData = callback.retainedPointer()
        return try nested(clientData)
    }
}

class __SwiftEOS__CompletionCallback<SwiftCallbackInfo> {

    let pointerManager: SwiftEOS__PointerManager

    let completion: (SwiftCallbackInfo) -> Void

    init(
        managedBy pointerManager: SwiftEOS__PointerManager,
        completion: @escaping (SwiftCallbackInfo) -> Void
    ) {
        self.pointerManager = pointerManager
        self.completion = completion
    }

    func retainedPointer() -> UnsafeMutableRawPointer {
        UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
    }

    static func from(pointer: UnsafeMutableRawPointer?) -> Self? {
        guard let pointer = pointer else { return nil }
        return Unmanaged<Self>.fromOpaque(pointer).takeRetainedValue()
    }
}
