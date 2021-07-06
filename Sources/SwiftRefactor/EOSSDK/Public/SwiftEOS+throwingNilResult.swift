
import Foundation

public func throwingNilResult<R>(
    _ nested: () throws -> R?
) throws -> R {
    guard let result = try nested() else {
        throw SwiftEOSError.unexpectedNilResult
    }
    return result
}
