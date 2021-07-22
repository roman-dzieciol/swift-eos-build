
import Foundation

extension SwiftType {

    public static var bool: SwiftBuiltinType { SwiftBuiltinType(name: "Bool", qual: .none) }
    public static var void: SwiftBuiltinType { SwiftBuiltinType(name: "Void", qual: .none) }
    public static var string: SwiftBuiltinType { SwiftBuiltinType(name: "String", qual: .none) }
    public static var error: SwiftBuiltinType { SwiftBuiltinType(name: "Error", qual: .none) }

    public static func result(successType: SwiftType, failureType: SwiftType = .error) -> SwiftGenericType {
        SwiftGenericType(genericType: SwiftBuiltinType(name: "Result", qual: .none),
                         specializationTypes: [successType, failureType],
                         qual: .none)
    }
}

public class SwiftType: SwiftOutputStreamable, CustomDebugStringConvertible, Equatable, Hashable {

    final public let qual: SwiftQual

    private weak var _nonCanonical: SwiftType?

    public var nonCanonical: Self? { _nonCanonical as? Self }

    public var canonical: SwiftType { self }

    final public var isOptional: Bool? {
        qual.isOptional
    }

    public var isTrivial: Bool {
        false
    }

    public var debugDescription: String {
        "\(type(of: self))(\(debugDescriptionDetails))"
    }

    var debugDescriptionDetails: String { 
        "\(qual)"
    }

    public init(qual: SwiftQual = .none, nonCanonical: SwiftType? = nil) {
        self.qual = qual
        self._nonCanonical = nonCanonical ?? self
    }

    public func isEqual(rhs: SwiftType) -> Bool {
        type(of: self) == type(of: rhs) &&
        qual == rhs.qual
    }

    public static func == (lhs: SwiftType, rhs: SwiftType) -> Bool {
        lhs.isEqual(rhs: rhs)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(qual)
    }

    public func copy(_ adjust: (SwiftQual) -> SwiftQual) -> SwiftType {
        fatalError()
    }

    public func write(to swift: SwiftOutputStream) {

    }

    public func handle(visitor: SwiftVisitor) throws -> SwiftType {
        self
    }

    public var immutable: SwiftType { self }
    public var mutable: SwiftType { self }

    final public var optional: SwiftType {
        isOptional != true ? copy({ $0.optional }) : self
    }

    final public var nonOptional: SwiftType {
        isOptional != false ? copy({ $0.nonOptional }) : self
    }

    final public var explicitlyOptional: SwiftType {
        isOptional == nil ? copy({ $0.explicitlyOptional }) : self
    }

    public var nilExpr: SwiftExpr? {
        isOptional == false ? nil : SwiftExpr.nil
    }
}
