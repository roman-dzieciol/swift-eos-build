
import Foundation

final public class SwiftArrayType: SwiftType {

    public let elementType: SwiftType

    public override var canonical: SwiftType {
        SwiftArrayType(elementType: elementType.canonical, qual: qual, nonCanonical: self)
    }

    public override var debugDescriptionDetails: String {
        "\(super.debugDescriptionDetails), " +
        "\(elementType.debugDescription)"
    }

    public init(elementType: SwiftType, qual: SwiftQual = .none, nonCanonical: SwiftType? = nil) {
        self.elementType = elementType
        super.init(qual: qual, nonCanonical: nonCanonical)
    }

    public override func handle(visitor: SwiftVisitor) throws -> SwiftType {
        let newElementType = try visitor.visit(type: elementType)
        if newElementType != elementType {
            return SwiftArrayType(elementType: newElementType, qual: qual)
        }
        return self
    }

    public override func isEqual(rhs: SwiftType) -> Bool {
        guard let rhs = rhs as? Self else { return false }
        return super.isEqual(rhs: rhs) &&
        elementType == rhs.elementType
    }

    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(elementType)
    }

    public override func copy(_ adjust: (SwiftQual) -> SwiftQual) -> SwiftType {
        SwiftArrayType(elementType: elementType, qual: adjust(qual))
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(nested: "[", "]") {
            swift.write(elementType)
        }
        swift.write(text: SwiftName.token(isOptional: isOptional))
    }

    public override var nilExpr: SwiftExpr? {
        super.nilExpr ?? .string("[]")
    }
}


extension SwiftType {

    final public var asArray: SwiftArrayType? {
        self as? SwiftArrayType
    }

    final public var isArray: Bool {
        self is SwiftArrayType
    }

}
