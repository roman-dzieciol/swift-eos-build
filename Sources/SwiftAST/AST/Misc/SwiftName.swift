
import Foundation

public struct SwiftName {

    static func token(isOptional: Bool?) -> String {
        if isOptional == true {
            return "?"
        } else if isOptional == nil {
            return "!"
        } else {
            return ""
        }
    }

}
