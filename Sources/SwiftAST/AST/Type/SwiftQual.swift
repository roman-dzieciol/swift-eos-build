
import Foundation

public struct SwiftQual: Equatable, Hashable, CustomDebugStringConvertible {

    public let isOptional: Bool?
    public let attributes: Set<String>

    public static let none = SwiftQual(isOptional: false,
                                       attributes: [])

    public var debugDescription: String {
        attributes.joined(separator: " ") +
        (isOptional == nil ? "!" : (isOptional == true ? "?" : ""))
    }

    public init(isOptional: Bool? = false,
                attributes: Set<String> = []) {
        self.isOptional = isOptional
        self.attributes = attributes
    }

    public func with(isOptional: Bool?) -> Self {
        SwiftQual(isOptional: isOptional, attributes: attributes)
    }

    public func with(attributes: Set<String>) -> Self {
        SwiftQual(isOptional: isOptional, attributes: attributes)
    }

    public static func with(isOptional: Bool?) -> Self {
        SwiftQual().with(isOptional: isOptional)
    }

    public static func with(attributes: Set<String>) -> Self {
        SwiftQual().with(attributes: attributes)
    }

    public static var optional: Self {
        SwiftQual().with(isOptional: true)
    }

    public var optional: Self {
        self.with(isOptional: true)
    }

    public var nonOptional: Self {
        self.with(isOptional: false)
    }

    public var explicitlyOptional: Self {
        self.with(isOptional: isOptional == true)
    }
}
