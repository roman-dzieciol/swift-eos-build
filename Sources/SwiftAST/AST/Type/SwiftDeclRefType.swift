
import Foundation

final public class SwiftDeclRefType: SwiftType {

    public let decl: SwiftDecl

    public override var debugDescriptionDetails: String {
        "\(super.debugDescriptionDetails), " +
        "\(decl.debugDescription)"
    }

    public override var canonical: SwiftType {
        decl.canonicalType?.copy { $0.with(isOptional: $0.isOptional != false || qual.isOptional != false) } ?? self
    }

    public init(decl: SwiftDecl, qual: SwiftQual = .none) {
        self.decl = decl
        super.init(qual: qual)
    }

    public override func isEqual(rhs: SwiftType) -> Bool {
        guard let rhs = rhs as? Self else { return false }
        return super.isEqual(rhs: rhs) &&
        decl === rhs.decl
    }

    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(decl.uuid)
    }

    public override func copy(_ adjust: (SwiftQual) -> SwiftQual) -> SwiftType {
        SwiftDeclRefType(decl: decl, qual: adjust(qual))
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(name: decl.name)
        swift.write(text: SwiftName.token(isOptional: isOptional))
    }

    public override var isTrivial: Bool {
        decl.canonical is SwiftEnum
    }

    public override var nilExpr: SwiftExpr? {
        if let nilExpr = super.nilExpr {
            return nilExpr
        }
        if decl.canonical is SwiftEnum {
            return .string(".zero")
        }
        return nil
    }
}


extension SwiftType {

    final public var asDeclRef: SwiftDeclRefType? {
        self as? SwiftDeclRefType
    }

    final public var asEnumDecl: SwiftEnum? {
        asDeclRef?.decl.canonical as? SwiftEnum
    }
    
    final public var asTypealiasRef: SwiftDeclRefType? {
        (asDeclRef?.decl is SwiftTypealias) ? asDeclRef : nil
    }

}
