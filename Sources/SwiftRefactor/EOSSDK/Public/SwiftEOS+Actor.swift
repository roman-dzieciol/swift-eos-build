
import Foundation

/// With `Actor` result from`() -> Handle`
public func withActorFromHandle<A: SwiftEOSActor>(
    _ nested: () throws -> A.HandleType
) rethrows -> A {
    return A(Handle: try nested())
}
