
import Foundation
import os.log

#if canImport(EOSSDK)
import EOSSDK
#endif

extension OSLogType {

    public static func from(eosLogLevel: EOS_ELogLevel) -> OSLogType {
        switch eosLogLevel {
        case .EOS_LOG_Fatal: return .fault
        case .EOS_LOG_Error: return .error
        case .EOS_LOG_Warning: return .error
        case .EOS_LOG_Info: return .info
        case .EOS_LOG_Verbose: return .info
        case .EOS_LOG_VeryVerbose: return .info
        default: return .default
        }
    }
}

extension Logger {

    public static func log(subsystem: String = "dev.roman.eos", _ eosLogMessagePtr: UnsafePointer<EOS_LogMessage>?) {
        guard let eosLogMessage = eosLogMessagePtr?.pointee else { return }
        Logger(subsystem: subsystem, category: String(cString: eosLogMessage.Category))
            .log(level: .from(eosLogLevel: eosLogMessage.Level), "\(String(cString: eosLogMessage.Message), privacy: .public)")
    }
}
