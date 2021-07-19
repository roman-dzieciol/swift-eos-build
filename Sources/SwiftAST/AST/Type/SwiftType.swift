
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

    public let qual: SwiftQual
    public var baseType: SwiftType { self }
    public var withoutTypealias: SwiftType { self }
    public var withoutDecls: SwiftType { self }
    public var canonical: SwiftType { self }
    public var innerType: SwiftType { self }

    public var isOptional: Bool? {
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

    public init(qual: SwiftQual = .none) {
        self.qual = qual
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

    public static func token(isOptional: Bool?) -> String {
        isOptional == true ? "?" : (isOptional == false ? "" : "!")
    }

    public func handle(visitor: SwiftVisitor) throws -> SwiftType {
        self
    }

    public func outer(type: SwiftType) -> SwiftType? {
        sequence(first: self, next: { $0 != $0.innerType ? $0.innerType : nil })
            .first(where: { $0.innerType.innerType == type })
    }

    public func outerTypealias(type: SwiftType) -> SwiftDeclRefType? {
        if let outerType = outer(type: type)?.asDeclRef, outerType.decl is SwiftTypealias {
            return outerType
        }
        return nil
    }

    public func withAlias(in rootType: SwiftType) -> SwiftType {
        sequence(first: rootType, next: { $0 != $0.innerType ? $0.innerType : nil })
            .first(where: { $0.innerType == self }) ?? self
    }

    public var immutable: SwiftType { self }
    public var mutable: SwiftType { self }

    public var optional: SwiftType {
        isOptional != true ? copy({ $0.optional }) : self
    }

    public var nonOptional: SwiftType {
        isOptional != false ? copy({ $0.nonOptional }) : self
    }

    public var explicitlyOptional: SwiftType {
        isOptional == nil ? copy({ $0.explicitlyOptional }) : self
    }

    public var isHandlePointer: Bool {
        canonical.asOpaquePointer?.pointeeType.asOpaque?.typeName.hasSuffix("Handle") == true
    }

    public var nilExpr: SwiftExpr? {
        isOptional == false ? nil : SwiftExpr.nil
    }
}
