
import Foundation

#if canImport(EOSSDK)
import EOSSDK
#endif

public enum SwiftEOSError: Error {
    case result(EOS_EResult)
    case unexpectedNilResult
    case unexpectedBoolResult
    case intResultNotTypecastable
    case bufferCapacity(Int,EOS_EResult)

    public static func from(result: EOS_EResult) -> Self? {
        guard result != .EOS_Success else { return nil }
        return .result(result)
    }
}
