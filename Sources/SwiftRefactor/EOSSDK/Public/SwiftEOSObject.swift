

public protocol SwiftEOSObject {

    associatedtype SdkObject

    init?(sdkObject: SdkObject?) throws

    func buildSdkObject(pointerManager: SwiftEOS__PointerManager) throws -> SdkObject
}
