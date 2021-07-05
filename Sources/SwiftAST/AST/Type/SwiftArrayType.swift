
import Foundation

public class SwiftArrayType: SwiftType {

    public let elementType: SwiftType

    public override var canonical: SwiftType {
        SwiftArrayType(elementType: elementType.canonical, qual: qual)
    }

    public override var debugDescriptionDetails: String {
        "\(super.debugDescriptionDetails), " +
        "\(elementType.debugDescription)"
    }

    public override var baseType: SwiftType {
        elementType.baseType
    }

    public init(elementType: SwiftType, qual: SwiftQual = .none) {
        self.elementType = elementType
        super.init(qual: qual)
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
        swift.write(text: Self.token(isOptional: isOptional))
    }
}


extension SwiftType {

    public var asArray: SwiftArrayType? {
        self as? SwiftArrayType
    }

    public var isArray: Bool {
        self is SwiftArrayType
    }

    public var asArrayElement: SwiftType? {
        asArray?.elementType
    }

}
