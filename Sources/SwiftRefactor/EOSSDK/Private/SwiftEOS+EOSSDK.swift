
import Foundation

public typealias EOS_Bool = Int32

public var EOS_TRUE: EOS_Bool { 1 }
public var EOS_FALSE: EOS_Bool { 0 }

public typealias EOS_NotificationId = UInt64

public struct EOS_EResult : Equatable, RawRepresentable {

    public var rawValue: UInt32
    
    public init(_ rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static var EOS_Success: EOS_EResult { EOS_EResult(0) }
    public static var EOS_LimitExceeded: EOS_EResult { EOS_EResult(1) }
}
