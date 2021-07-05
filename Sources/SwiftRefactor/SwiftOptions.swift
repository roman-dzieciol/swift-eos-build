
import Foundation

public struct SwiftOptions: OptionSet {

    public static let allowCastingAwayConst = SwiftOptions(rawValue: 1 << 0)
    public static let allowImplicitPointerCasts = SwiftOptions(rawValue: 1 << 1)
    public static let withPointerManager = SwiftOptions(rawValue: 1 << 2)
    public static let allowUnions = SwiftOptions(rawValue: 1 << 3)

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
