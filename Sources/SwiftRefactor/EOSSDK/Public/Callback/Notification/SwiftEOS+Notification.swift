
import Foundation

#if canImport(EOSSDK)
import EOSSDK
#endif


public func withNotification<SwiftCallbackInfo>(
    notification: @escaping (SwiftCallbackInfo) -> Void,
    managedBy pointerManager: SwiftEOS__PointerManager,
    nested: (UnsafeMutableRawPointer) throws -> EOS_NotificationId,
    onDeinit: @escaping (EOS_NotificationId) -> Void
) rethrows -> SwiftEOS_Notification<SwiftCallbackInfo> {
    let callback = __SwiftEOS__NotificationCallback(notification)
    return try withExtendedLifetime(callback) { callback in
        let clientData = callback.retainedPointer()
        let notificationId = try nested(clientData)
        return SwiftEOS_Notification(callback: callback,
                                     notificationId: notificationId,
                                     pointerManager: pointerManager,
                                     onDeinit: onDeinit)
    }
}

public class SwiftEOS_Notification<SwiftCallbackInfo> {

    let pointerManager: SwiftEOS__PointerManager
    let callback: __SwiftEOS__NotificationCallback<SwiftCallbackInfo>
    let notificationId: EOS_NotificationId
    let onDeinit: (EOS_NotificationId) -> Void

    init(callback: __SwiftEOS__NotificationCallback<SwiftCallbackInfo>,
         notificationId: EOS_NotificationId,
         pointerManager: SwiftEOS__PointerManager,
         onDeinit: @escaping (EOS_NotificationId) -> Void) {
        self.pointerManager = pointerManager
        self.callback = callback
        self.notificationId = notificationId
        self.onDeinit = onDeinit
    }

    deinit {
        onDeinit(notificationId)
    }
}

class __SwiftEOS__NotificationCallback<SwiftCallbackInfo> {

    let notify: (SwiftCallbackInfo) -> Void

    init(_ notify: @escaping (SwiftCallbackInfo) -> Void) {
        self.notify = notify
    }

    func retainedPointer() -> UnsafeMutableRawPointer {
        UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
    }

    static func from(pointer: UnsafeMutableRawPointer?) -> Self? {
        guard let pointer = pointer else { return nil }
        return Unmanaged<Self>.fromOpaque(pointer).takeUnretainedValue()
    }
}
