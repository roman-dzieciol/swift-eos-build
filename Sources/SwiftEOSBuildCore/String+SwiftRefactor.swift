
import Foundation

public extension String {

    @inlinable mutating func removePrefix<Prefix>(_ prefix: Prefix) where Prefix : StringProtocol {
        guard hasPrefix(prefix) else { return }
        removeFirst(prefix.count)
    }

    @inlinable mutating func removeSuffix<Suffix>(_ suffix: Suffix) where Suffix : StringProtocol {
        guard hasSuffix(suffix) else { return }
        removeLast(suffix.count)
    }

    @inlinable func dropPrefix<Prefix>(_ prefix: Prefix) -> Substring where Prefix : StringProtocol {
        guard hasPrefix(prefix) else { return Substring(self) }
        return dropFirst(prefix.count)
    }

    @inlinable func dropSuffix<Suffix>(_ suffix: Suffix) -> Substring where Suffix : StringProtocol {
        guard hasSuffix(suffix) else { return Substring(self) }
        return dropLast(suffix.count)
    }

    @inlinable var quoted: String {
        "\"\(self)\""
    }
    
}

public extension Substring {

    @inlinable func dropPrefix<Prefix>(_ prefix: Prefix) -> Substring where Prefix : StringProtocol {
        guard hasPrefix(prefix) else { return self }
        return dropFirst(prefix.count)
    }

    @inlinable func dropSuffix<Suffix>(_ suffix: Suffix) -> Substring where Suffix : StringProtocol {
        guard hasSuffix(suffix) else { return self }
        return dropLast(suffix.count)
    }
}
