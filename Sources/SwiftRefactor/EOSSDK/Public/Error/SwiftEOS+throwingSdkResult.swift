
import Foundation

#if canImport(EOSSDK)
import EOSSDK
#endif

public func throwingSdkResult(
    _ nested: () throws -> EOS_EResult
) throws {
    let result = try nested()
    guard result == .EOS_Success else {
        throw SwiftEOSError.result(result)
    }
}
