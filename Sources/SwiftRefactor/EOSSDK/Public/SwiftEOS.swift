
import Foundation

#if canImport(EOSSDK)
import EOSSDK


public func asserting<R>(
    _ nested: () throws -> R
) -> R {
    do {
        return try nested()
    } catch SwiftEOSError.result(let result) {
        fatalError(SwiftEOS_EResult_ToString(Result: result) ?? "")
    } catch {
        fatalError("\(error)")
    }
}

extension EOS_EResult: CustomStringConvertible {

    public var description: String {
        SwiftEOS_EResult_ToString(Result: self) ?? "nil"
    }

    public func isComplete() throws -> Bool {
        try SwiftEOS_EResult_IsOperationComplete(Result: self)
    }

    public func shouldProceed() throws -> Bool {
        guard try isComplete() else { return false }
        guard self == .EOS_Success else { throw SwiftEOSError.result(self) }
        return true
    }
}

#endif
