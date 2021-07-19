
import Foundation

public class SwiftGenericType: SwiftType {

    public let genericType: SwiftType
    public let specializationTypes: [SwiftType]

    public override var canonical: SwiftType {
        SwiftGenericType(genericType: genericType.canonical,
                         specializationTypes: specializationTypes.map { $0.canonical },
                         qual: qual)
    }

    public override var debugDescriptionDetails: String {
        "\(super.debugDescriptionDetails), " +
        "\(genericType.debugDescription)" +
        "<\(specializationTypes.map { $0.debugDescription }.joined(separator: ",") )>"
    }

    public init(genericType: SwiftType, specializationTypes: [SwiftType], qual: SwiftQual) {
        self.genericType = genericType
        self.specializationTypes = specializationTypes
        super.init(qual: qual)
    }

    public override func handle(visitor: SwiftVisitor) throws -> SwiftType {
        let newGenericType = try visitor.visit(type: genericType)
        let newSpecializationTypes = try specializationTypes.map { try visitor.visit(type: $0) }

        if newGenericType != genericType || newSpecializationTypes != specializationTypes {
            return SwiftGenericType(genericType: newGenericType, specializationTypes: newSpecializationTypes, qual: qual)
        }
        return self
    }

    public override func isEqual(rhs: SwiftType) -> Bool {
        guard let rhs = rhs as? Self else { return false }
        return super.isEqual(rhs: rhs) &&
        genericType == rhs.genericType &&
        specializationTypes == rhs.specializationTypes
    }

    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(genericType)
        hasher.combine(specializationTypes)
    }

    public override func copy(_ adjust: (SwiftQual) -> SwiftQual) -> SwiftGenericType {
        SwiftGenericType(genericType: genericType, specializationTypes: specializationTypes, qual: adjust(qual))
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(genericType)
        swift.write(nested: "<", ">") {
            swift.write(specializationTypes, separated: ",")
        }
        swift.write(text: Self.token(isOptional: isOptional))
    }
}

extension SwiftType {

    public var asGeneric: SwiftGenericType? {
        self as? SwiftGenericType
    }
}
