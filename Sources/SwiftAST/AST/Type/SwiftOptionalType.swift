
import Foundation

final public class SwiftOptionalType: SwiftType {

    public let nonOptionalType: SwiftType

    public let isImplicit: Bool

    public override var baseType: SwiftType {
        nonOptionalType.baseType
    }

    public override var canonical: SwiftType {
        self
    }

    public override var innerType: SwiftType {
        nonOptionalType
    }

    public override var debugDescriptionDetails: String {
        "\(super.debugDescriptionDetails), \(nonOptionalType.debugDescription)"
    }

    public init(nonOptionalType: SwiftType, isImplicit: Bool = false, qual: SwiftQual = .none) {
        self.nonOptionalType = nonOptionalType
        self.isImplicit = isImplicit
        super.init(qual: qual)
    }

    public override func handle(visitor: SwiftVisitor) throws -> SwiftType {
        let newNonOptionalType = try visitor.visit(type: nonOptionalType)
        if newNonOptionalType != nonOptionalType {
            return SwiftOptionalType(nonOptionalType: newNonOptionalType, isImplicit: isImplicit, qual: qual)
        }
        return self
    }

    public override func isEqual(rhs: SwiftType) -> Bool {
        guard let rhs = rhs as? Self else { return false }
        return super.isEqual(rhs: rhs) &&
        nonOptionalType == rhs.nonOptionalType &&
        isImplicit == rhs.isImplicit
    }

    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(nonOptionalType)
        hasher.combine(isImplicit)
    }

    public override func copy(_ adjust: (SwiftQual) -> SwiftQual) -> SwiftType {
        SwiftOptionalType(nonOptionalType: nonOptionalType, isImplicit: isImplicit, qual: adjust(qual))
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(name: "Optional")
        swift.write(nested: "<", ">") {
            swift.write(nonOptionalType)
        }
    }
}

extension SwiftType {

    public var asOptional: SwiftOptionalType? {
        self as? SwiftOptionalType
    }
}
