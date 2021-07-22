
import Foundation

final public class SwiftFunctionParmType: SwiftType {

    public let label: String?

    public let isMutable: Bool

    public let parmType: SwiftType

    public override var canonical: SwiftType {
        parmType.canonical.copy { _ in qual }
    }

    public override var debugDescriptionDetails: String {
        "\(super.debugDescriptionDetails), " +
        (label.map { $0 + ": " } ?? "") +
        "\(parmType.debugDescription)"
    }

    public init(label: String?, isMutable: Bool, parmType: SwiftType) {
        self.label = label
        self.parmType = parmType
        self.isMutable = isMutable
        super.init(qual: parmType.qual)
    }

    public override func isEqual(rhs: SwiftType) -> Bool {
        guard let rhs = rhs as? Self else { return false }
        return super.isEqual(rhs: rhs) &&
        label == rhs.label &&
        isMutable == rhs.isMutable &&
        parmType == rhs.parmType
    }

    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(label)
        hasher.combine(isMutable)
        hasher.combine(parmType)
    }

    public override func handle(visitor: SwiftVisitor) throws -> SwiftType {
        let newParmType = try visitor.visit(type: parmType)
        if newParmType != parmType {
            return SwiftFunctionParmType(label: label, isMutable: isMutable, parmType: newParmType)
        }
        return self
    }

    public override func copy(_ adjust: (SwiftQual) -> SwiftQual) -> SwiftType {
        SwiftFunctionParmType(label: label, isMutable: isMutable, parmType: parmType.copy(adjust))
    }

    public override func write(to swift: SwiftOutputStream) {

        if isMutable {
            swift.write(name: "inout")
        }

        if let label = label {
            swift.write(name: "_")
            swift.write(name: label)
            swift.write(token: ":")
        }

        swift.write(parmType)
    }
}
