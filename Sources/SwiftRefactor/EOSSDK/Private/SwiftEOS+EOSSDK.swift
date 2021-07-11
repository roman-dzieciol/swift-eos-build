
import Foundation

public typealias EOS_Bool = Int32

public var EOS_TRUE: EOS_Bool { 1 }
public var EOS_FALSE: EOS_Bool { 0 }

public typealias EOS_NotificationId = UInt64


/** A structure representing a log message */
public struct EOS_LogMessage {
    /** A string representation of the log message category, encoded in UTF-8. Only valid during the life of the callback, so copy the string if you need it later. */
    let Category: UnsafePointer<CChar>
    /** The log message, encoded in UTF-8. Only valid during the life of the callback, so copy the string if you need it later. */
    let Message: UnsafePointer<CChar>
    /** The log level associated with the message */
    let Level: EOS_ELogLevel
}


public struct EOS_ELogLevel : Equatable, RawRepresentable {

    public var rawValue: UInt32

    public init(_ rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static var EOS_LOG_Fatal: Self { .init(100) }
    public static var EOS_LOG_Error: Self { .init(200) }
    public static var EOS_LOG_Warning: Self { .init(300) }
    public static var EOS_LOG_Info: Self { .init(400) }
    public static var EOS_LOG_Verbose: Self { .init(500) }
    public static var EOS_LOG_VeryVerbose: Self { .init(600) }
}


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
