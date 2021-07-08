
public protocol SwiftEOSActor: AnyObject {

    associatedtype HandleType

    init(Handle: HandleType)
}
