
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
}

extension EOS_EpicAccountId: CustomStringConvertible {

    public var description: String {
        (try? SwiftEOS_EpicAccountId_ToString(AccountId: self)) ?? "nil"
    }
}

extension EOS_EpicAccountId: Identifiable {
    public var id: Int { Int(bitPattern: UnsafeRawPointer(self)) }
}

extension EOS_EAuthTokenType: CustomStringConvertible {

    public var description: String {
        switch self {
        case .EOS_ATT_Client: return "EOS_ATT_Client"
        case .EOS_ATT_User: return "EOS_ATT_User"
        default: return "\(self.rawValue)"
        }
    }
}

extension EOS_ELoginStatus: CustomStringConvertible {

    public var description: String {
        switch self {
        case .EOS_LS_NotLoggedIn: return "EOS_LS_NotLoggedIn"
        case .EOS_LS_UsingLocalProfile: return "EOS_LS_UsingLocalProfile"
        case .EOS_LS_LoggedIn: return "EOS_LS_LoggedIn"
        default: return "\(self.rawValue)"
        }
    }
}

#endif
